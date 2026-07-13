import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../podcast/data/models/podcast_episode.dart';
import '../../podcast/data/models/podcast_feed.dart';
import '../domain/download_item.dart';

class DownloadRepository {
  DownloadRepository(this._db);

  final AppDatabase _db;

  Stream<List<DownloadItem>> watchDownloads() {
    final query = _db.select(_db.downloadedEpisodes)
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);
    return query.watch().map((rows) => rows.map(_mapRow).toList());
  }

  Stream<DownloadItem?> watchDownload(int episodeId) {
    final query = _db.select(_db.downloadedEpisodes)
      ..where((t) => t.episodeId.equals(episodeId));
    return query.watch().map((rows) => rows.isEmpty ? null : _mapRow(rows.first));
  }

  Future<DownloadItem?> getDownload(int episodeId) async {
    final row = await (_db.select(_db.downloadedEpisodes)
          ..where((t) => t.episodeId.equals(episodeId)))
        .getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  Future<String?> getCompletedLocalPath(int episodeId) async {
    final item = await getDownload(episodeId);
    if (item == null || !item.canPlayOffline) return null;
    final file = File(item.localPath!);
    if (!await file.exists()) return null;
    return item.localPath;
  }

  Future<Set<int>> getDownloadedEpisodeIds() async {
    final rows = await (_db.select(_db.downloadedEpisodes)
          ..where(
            (t) => t.status.equals(EpisodeDownloadStatus.completed.name),
          ))
        .get();
    return rows.map((row) => row.episodeId).toSet();
  }

  Future<void> upsertQueued({
    required PodcastEpisode episode,
    required PodcastFeed feed,
    required String taskId,
  }) {
    return _db.into(_db.downloadedEpisodes).insertOnConflictUpdate(
          DownloadedEpisodesCompanion.insert(
            episodeId: Value(episode.id),
            feedId: episode.feedId,
            episodeTitle: episode.title,
            feedTitle: feed.title,
            artworkUrl: Value(_artwork(episode, feed)),
            enclosureUrl: episode.enclosureUrl!,
            taskId: Value(taskId),
            status: EpisodeDownloadStatus.queued.name,
            progress: const Value(0),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> updateProgress({
    required int episodeId,
    required double progress,
    EpisodeDownloadStatus? status,
    int? expectedFileSize,
  }) {
    return (_db.update(_db.downloadedEpisodes)
          ..where((t) => t.episodeId.equals(episodeId)))
        .write(
      DownloadedEpisodesCompanion(
        progress: Value(progress.clamp(0.0, 1.0)),
        status: status != null ? Value(status.name) : const Value.absent(),
        fileSizeBytes: expectedFileSize != null
            ? Value(expectedFileSize)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markCompleted({
    required int episodeId,
    required String localPath,
    int? fileSizeBytes,
  }) {
    return (_db.update(_db.downloadedEpisodes)
          ..where((t) => t.episodeId.equals(episodeId)))
        .write(
      DownloadedEpisodesCompanion(
        localPath: Value(localPath),
        status: Value(EpisodeDownloadStatus.completed.name),
        progress: const Value(1),
        fileSizeBytes: Value(fileSizeBytes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markFailed(int episodeId) {
    return (_db.update(_db.downloadedEpisodes)
          ..where((t) => t.episodeId.equals(episodeId)))
        .write(
      DownloadedEpisodesCompanion(
        status: Value(EpisodeDownloadStatus.failed.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markPaused(int episodeId) {
    return (_db.update(_db.downloadedEpisodes)
          ..where((t) => t.episodeId.equals(episodeId)))
        .write(
      DownloadedEpisodesCompanion(
        status: Value(EpisodeDownloadStatus.paused.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> remove(int episodeId) async {
    final item = await getDownload(episodeId);
    if (item?.localPath != null) {
      final file = File(item!.localPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await (_db.delete(_db.downloadedEpisodes)
          ..where((t) => t.episodeId.equals(episodeId)))
        .go();
  }

  DownloadItem _mapRow(DownloadedEpisode row) {
    return DownloadItem(
      episodeId: row.episodeId,
      feedId: row.feedId,
      episodeTitle: row.episodeTitle,
      feedTitle: row.feedTitle,
      enclosureUrl: row.enclosureUrl,
      artworkUrl: row.artworkUrl,
      localPath: row.localPath,
      taskId: row.taskId,
      status: EpisodeDownloadStatus.fromStorage(row.status),
      progress: row.progress,
      fileSizeBytes: row.fileSizeBytes,
      updatedAt: row.updatedAt,
    );
  }

  String? _artwork(PodcastEpisode episode, PodcastFeed feed) {
    final url = episode.artworkUrl.isNotEmpty
        ? episode.artworkUrl
        : feed.artworkUrl;
    return url.isEmpty ? null : url;
  }
}
