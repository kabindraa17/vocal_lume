import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../podcast/data/models/podcast_episode.dart';
import '../../../podcast/data/models/podcast_feed.dart';
import '../../application/download_controller.dart';
import '../../domain/download_item.dart';
import 'start_episode_download.dart';

/// Compact download / progress / delete control for an episode.
class EpisodeDownloadButton extends ConsumerWidget {
  const EpisodeDownloadButton({
    super.key,
    required this.episode,
    required this.feed,
    this.iconSize = 22,
  });

  final PodcastEpisode episode;
  final PodcastFeed feed;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final download = ref.watch(downloadForEpisodeProvider(episode.id)).value;
    final canDownload = episode.hasPlayableAudio;

    if (!canDownload && download == null) {
      return const SizedBox.shrink();
    }

    if (download?.status.isActive == true) {
      final active = download!;
      final live = ref.watch(downloadLiveStatsProvider(episode.id));
      final progress = live?.progress ?? active.progress;
      final percent = live?.percent ?? (progress * 100).clamp(0, 100).round();
      return IconButton(
        tooltip: percent > 0 ? 'Cancel · $percent%' : 'Cancel download',
        onPressed: () =>
            ref.read(downloadControllerProvider.notifier).cancel(episode.id),
        icon: SizedBox(
          width: iconSize,
          height: iconSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress > 0 ? progress : null,
                strokeWidth: 2.4,
                color: AppColors.primary,
              ),
              if (percent > 0)
                Text(
                  '$percent',
                  style: TextStyle(
                    fontSize: iconSize * 0.32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1,
                  ),
                )
              else
                Icon(Icons.close_rounded, size: iconSize * 0.55),
            ],
          ),
        ),
      );
    }

    if (download?.status.isCompleted == true) {
      return IconButton(
        tooltip: 'Remove download',
        onPressed: () => _confirmDelete(context, ref),
        icon: Icon(
          Icons.download_done_rounded,
          size: iconSize,
          color: AppColors.primary,
        ),
      );
    }

    return IconButton(
      tooltip: download?.status == EpisodeDownloadStatus.failed
          ? 'Retry download'
          : 'Download for offline',
      onPressed: canDownload
          ? () => startEpisodeDownload(
                context,
                ref,
                episode: episode,
                feed: feed,
              )
          : null,
      icon: Icon(
        download?.status == EpisodeDownloadStatus.failed
            ? Icons.refresh_rounded
            : Icons.download_rounded,
        size: iconSize,
        color: canDownload
            ? AppColors.onSurfaceMuted
            : AppColors.onSurfaceMuted.withValues(alpha: 0.3),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove download?'),
        content: const Text(
          'This episode will be removed from offline storage. '
          'You can download it again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(downloadControllerProvider.notifier).delete(episode.id);
  }
}
