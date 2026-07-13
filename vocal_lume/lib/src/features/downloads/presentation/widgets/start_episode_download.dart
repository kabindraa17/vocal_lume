import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_connection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../podcast/data/models/podcast_episode.dart';
import '../../../podcast/data/models/podcast_feed.dart';
import '../../application/download_controller.dart';

/// Confirms mobile-data usage when needed, then enqueues the download.
///
/// Returns `true` if the download was started, `false` if cancelled / skipped.
Future<bool> startEpisodeDownload(
  BuildContext context,
  WidgetRef ref, {
  required PodcastEpisode episode,
  required PodcastFeed feed,
}) async {
  final connection = await checkNetworkConnection();
  if (!context.mounted) return false;

  if (!connection.hasConnection) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No connection'),
        content: const Text(
          'Connect to Wi‑Fi or mobile data to download this episode.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return false;
  }

  if (connection.isMobileData) {
    final proceed = await showMobileDataDownloadDialog(context);
    if (!context.mounted || proceed != true) return false;
  }

  try {
    await ref.read(downloadControllerProvider.notifier).enqueue(
          episode: episode,
          feed: feed,
        );
    if (!context.mounted) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          connection.isMobileData
              ? 'Download started on mobile data'
              : 'Download started on ${connection.label}',
        ),
      ),
    );
    return true;
  } catch (error) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not start download: $error')),
    );
    return false;
  }
}

/// Warns that the device is on cellular before starting a download.
Future<bool?> showMobileDataDownloadDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        icon: Icon(
          Icons.signal_cellular_alt_rounded,
          color: theme.colorScheme.primary,
          size: 36,
        ),
        title: const Text('Using mobile data'),
        content: const Text(
          'You are connected to mobile data, not Wi‑Fi.\n\n'
          'Downloading this episode may use cellular data and count '
          'toward your plan. Continue anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.onSurfaceMuted),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Download anyway'),
          ),
        ],
      );
    },
  );
}
