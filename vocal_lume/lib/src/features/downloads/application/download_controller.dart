import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/providers/database_providers.dart';
import '../../podcast/data/models/podcast_episode.dart';
import '../../podcast/data/models/podcast_feed.dart';
import '../data/download_repository.dart';
import '../domain/download_item.dart';
import '../domain/download_live_stats.dart';

final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  return DownloadRepository(ref.watch(appDatabaseProvider));
});

final downloadsProvider = StreamProvider<List<DownloadItem>>((ref) {
  return ref.watch(downloadRepositoryProvider).watchDownloads();
});

final downloadForEpisodeProvider =
    StreamProvider.family<DownloadItem?, int>((ref, episodeId) {
  return ref.watch(downloadRepositoryProvider).watchDownload(episodeId);
});

/// Live ETA / speed / percent for in-flight downloads (episodeId → stats).
final downloadControllerProvider = NotifierProvider<DownloadController,
    Map<int, DownloadLiveStats>>(DownloadController.new);

final downloadLiveStatsProvider =
    Provider.family<DownloadLiveStats?, int>((ref, episodeId) {
  return ref.watch(downloadControllerProvider)[episodeId];
});

class DownloadController extends Notifier<Map<int, DownloadLiveStats>> {
  static const _group = 'episode_downloads';
  static const _directory = 'episode_downloads';

  DownloadRepository get _repo => ref.read(downloadRepositoryProvider);

  StreamSubscription<TaskUpdate>? _updatesSub;
  bool _started = false;

  @override
  Map<int, DownloadLiveStats> build() {
    ref.onDispose(() {
      unawaited(_updatesSub?.cancel());
    });
    unawaited(_ensureStarted());
    return const {};
  }

  Future<void> _ensureStarted() async {
    if (_started) return;
    _started = true;

    final downloader = FileDownloader();
    await downloader.start();
    downloader.configureNotification(
      running: const TaskNotification(
        'Downloading episode',
        '{displayName} · {progress} · {timeRemaining}',
      ),
      complete: const TaskNotification(
        'Download complete',
        '{displayName}',
      ),
      error: const TaskNotification(
        'Download failed',
        '{displayName}',
      ),
      progressBar: true,
    );

    _updatesSub = downloader.updates.listen(_onUpdate);
  }

  Future<void> enqueue({
    required PodcastEpisode episode,
    required PodcastFeed feed,
  }) async {
    await _ensureStarted();

    final url = episode.enclosureUrl;
    if (url == null || url.isEmpty) {
      throw ArgumentError('Episode has no audio URL to download.');
    }

    final existing = await _repo.getDownload(episode.id);
    if (existing?.status.isCompleted == true) return;
    if (existing?.status.isActive == true) return;

    final filename = _filenameFor(episode, url);
    final meta = jsonEncode({
      'episodeId': episode.id,
      'feedId': feed.id,
    });

    final task = DownloadTask(
      url: url,
      filename: filename,
      directory: _directory,
      baseDirectory: BaseDirectory.applicationSupport,
      group: _group,
      updates: Updates.statusAndProgress,
      retries: 3,
      allowPause: true,
      metaData: meta,
      displayName: episode.title,
    );

    await _repo.upsertQueued(
      episode: episode,
      feed: feed,
      taskId: task.taskId,
    );
    _setLive(
      episode.id,
      const DownloadLiveStats(progress: 0),
    );

    final enqueued = await FileDownloader().enqueue(task);
    if (!enqueued) {
      _clearLive(episode.id);
      await _repo.markFailed(episode.id);
      throw StateError('Could not start download.');
    }
  }

  Future<void> cancel(int episodeId) async {
    await _ensureStarted();
    final item = await _repo.getDownload(episodeId);
    if (item?.taskId != null) {
      await FileDownloader().cancelTaskWithId(item!.taskId!);
    }
    _clearLive(episodeId);
    await _repo.remove(episodeId);
  }

  Future<void> delete(int episodeId) async {
    await cancel(episodeId);
  }

  Future<void> pause(int episodeId) async {
    await _ensureStarted();
    final item = await _repo.getDownload(episodeId);
    if (item?.taskId == null) return;
    final task = await FileDownloader().taskForId(item!.taskId!);
    if (task is DownloadTask) {
      await FileDownloader().pause(task);
    }
  }

  Future<void> resume(int episodeId) async {
    await _ensureStarted();
    final item = await _repo.getDownload(episodeId);
    if (item?.taskId == null) return;
    final task = await FileDownloader().taskForId(item!.taskId!);
    if (task is DownloadTask) {
      await FileDownloader().resume(task);
    }
  }

  void _onUpdate(TaskUpdate update) {
    unawaited(_handleUpdate(update));
  }

  Future<void> _handleUpdate(TaskUpdate update) async {
    final episodeId = _episodeIdFromMeta(update.task.metaData);
    if (episodeId == null) return;

    switch (update) {
      case TaskStatusUpdate():
        await _handleStatus(episodeId, update);
      case TaskProgressUpdate():
        final progress = update.progress.clamp(0.0, 1.0);
        _setLive(
          episodeId,
          DownloadLiveStats(
            progress: progress,
            expectedFileSize:
                update.hasExpectedFileSize ? update.expectedFileSize : null,
            networkSpeedMBps:
                update.hasNetworkSpeed ? update.networkSpeed : null,
            timeRemaining:
                update.hasTimeRemaining ? update.timeRemaining : null,
          ),
        );
        await _repo.updateProgress(
          episodeId: episodeId,
          progress: progress,
          status: EpisodeDownloadStatus.downloading,
          expectedFileSize:
              update.hasExpectedFileSize ? update.expectedFileSize : null,
        );
    }
  }

  Future<void> _handleStatus(int episodeId, TaskStatusUpdate update) async {
    switch (update.status) {
      case TaskStatus.enqueued:
        _setLive(episodeId, const DownloadLiveStats(progress: 0));
        await _repo.updateProgress(
          episodeId: episodeId,
          progress: 0,
          status: EpisodeDownloadStatus.queued,
        );
      case TaskStatus.running:
        _setLive(
          episodeId,
          state[episodeId] ?? const DownloadLiveStats(progress: 0),
        );
        await _repo.updateProgress(
          episodeId: episodeId,
          progress: state[episodeId]?.progress ?? 0,
          status: EpisodeDownloadStatus.downloading,
        );
      case TaskStatus.complete:
        _clearLive(episodeId);
        final path = await _absolutePath(update.task);
        int? size;
        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            size = await file.length();
          }
        }
        if (path == null) {
          await _repo.markFailed(episodeId);
          return;
        }
        await _repo.markCompleted(
          episodeId: episodeId,
          localPath: path,
          fileSizeBytes: size,
        );
      case TaskStatus.failed:
      case TaskStatus.notFound:
      case TaskStatus.canceled:
        AppLogger.error(
          'Download ended with ${update.status}',
          tag: 'Download',
          error: update.exception,
        );
        _clearLive(episodeId);
        if (update.status == TaskStatus.canceled) {
          await _repo.remove(episodeId);
        } else {
          await _repo.markFailed(episodeId);
        }
      case TaskStatus.paused:
        await _repo.markPaused(episodeId);
      case TaskStatus.waitingToRetry:
        await _repo.updateProgress(
          episodeId: episodeId,
          progress: state[episodeId]?.progress ?? 0,
          status: EpisodeDownloadStatus.queued,
        );
    }
  }

  void _setLive(int episodeId, DownloadLiveStats stats) {
    state = {...state, episodeId: stats};
  }

  void _clearLive(int episodeId) {
    if (!state.containsKey(episodeId)) return;
    final next = Map<int, DownloadLiveStats>.from(state)..remove(episodeId);
    state = next;
  }

  Future<String?> _absolutePath(Task task) async {
    try {
      return await task.filePath();
    } catch (_) {
      final support = await getApplicationSupportDirectory();
      return p.join(support.path, _directory, task.filename);
    }
  }

  int? _episodeIdFromMeta(String metaData) {
    if (metaData.isEmpty) return null;
    try {
      final decoded = jsonDecode(metaData);
      if (decoded is Map<String, dynamic>) {
        final id = decoded['episodeId'];
        if (id is int) return id;
        if (id is num) return id.toInt();
      }
    } catch (_) {
      // Older / unexpected metadata — ignore.
    }
    return null;
  }

  String _filenameFor(PodcastEpisode episode, String url) {
    final uri = Uri.tryParse(url);
    final ext = uri == null
        ? '.mp3'
        : p.extension(uri.path).isEmpty
            ? '.mp3'
            : p.extension(uri.path);
    final safeExt = ext.length > 8 ? '.mp3' : ext;
    return 'episode_${episode.id}$safeExt';
  }
}
