import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../player/presentation/widgets/play_episode.dart';
import '../../data/models/podcast_episode.dart';
import '../../data/models/podcast_feed.dart';
import 'podcast_artwork.dart';

/// Shows episode details in a bottom sheet instead of a full-screen route.
Future<void> showEpisodeInfoSheet(
  BuildContext context, {
  required PodcastEpisode episode,
  required PodcastFeed feed,
}) {
  return AppSheet.dynamic<void>(
    context,
    child: _EpisodeInfoSheetBody(episode: episode, feed: feed),
  );
}

class _EpisodeInfoSheetBody extends ConsumerWidget {
  const _EpisodeInfoSheetBody({
    required this.episode,
    required this.feed,
  });

  final PodcastEpisode episode;
  final PodcastFeed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final artwork = episode.artworkUrl.isNotEmpty
        ? episode.artworkUrl
        : feed.artworkUrl;
    final canPlay =
        episode.enclosureUrl != null && episode.enclosureUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: artwork.isEmpty
                    ? PodcastArtwork(feed: feed, size: 88)
                    : CachedNetworkImage(
                        imageUrl: artwork,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feed.displayTitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        Text(
                          Formatters.duration(episode.duration),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (episode.datePublished != null)
                          Text(
                            Formatters.publishedDate(episode.datePublished),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canPlay
                  ? () async {
                      Navigator.of(context).pop();
                      await playEpisode(
                        ref,
                        episode: episode,
                        feed: feed,
                        expandPlayer: true,
                      );
                    }
                  : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Play episode'),
            ),
          ),
          if (episode.descriptionText.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'About this episode',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.35,
              ),
              child: SingleChildScrollView(
                child: Text(
                  episode.descriptionText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
