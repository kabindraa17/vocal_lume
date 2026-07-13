import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/download_item.dart';
import '../../domain/download_live_stats.dart';

/// Linear progress bar with percent, optional ETA, and speed.
class EpisodeDownloadProgressBar extends StatelessWidget {
  const EpisodeDownloadProgressBar({
    super.key,
    required this.download,
    this.live,
    this.onCancel,
    this.compact = false,
  });

  final DownloadItem download;
  final DownloadLiveStats? live;
  final VoidCallback? onCancel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = live?.progress ?? download.progress;
    final percent = Formatters.downloadPercent(progress);
    final hasDeterminate = progress > 0;

    final parts = <String>[percent];
    final eta = live?.hasTimeRemaining == true
        ? Formatters.downloadEta(live!.timeRemaining!)
        : '';
    if (eta.isNotEmpty) parts.add(eta);

    final speed = live?.hasNetworkSpeed == true
        ? Formatters.downloadSpeed(live!.networkSpeedMBps!)
        : '';
    if (speed.isNotEmpty) parts.add(speed);

    final expected = live?.expectedFileSize ?? download.fileSizeBytes;
    if (expected != null && expected > 0 && hasDeterminate) {
      final downloaded = (expected * progress).round();
      parts.add(
        '${Formatters.fileSize(downloaded)} / ${Formatters.fileSize(expected)}',
      );
    }

    final statusLabel = switch (download.status) {
      EpisodeDownloadStatus.queued => 'Queued',
      EpisodeDownloadStatus.paused => 'Paused',
      EpisodeDownloadStatus.downloading => 'Downloading',
      EpisodeDownloadStatus.failed => 'Failed',
      EpisodeDownloadStatus.completed => 'Downloaded',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                compact ? parts.join(' · ') : '$statusLabel · ${parts.join(' · ')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onCancel != null)
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: compact ? 4 : 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: hasDeterminate ? progress.clamp(0.0, 1.0) : null,
            minHeight: compact ? 4 : 6,
            backgroundColor: AppColors.surfaceHigh,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
