import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/podcast_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../player/application/player_notifier.dart';
import '../../player/presentation/widgets/play_episode.dart';
import '../data/models/podcast_episode.dart';
import '../data/models/podcast_feed.dart';
import 'widgets/podcast_artwork.dart';

class EpisodeDetailScreen extends ConsumerWidget {
  const EpisodeDetailScreen({
    super.key,
    required this.feedId,
    required this.episodeId,
  });

  final int feedId;
  final int episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(podcastFeedProvider(feedId));
    final episode = ref.watch(podcastEpisodeProvider(episodeId));
    final nowPlaying = ref.watch(playerProvider);
    final theme = Theme.of(context);
    final fallbackEpisode = nowPlaying.episode?.id == episodeId
        ? nowPlaying.episode
        : null;
    final fallbackFeed = nowPlaying.feed?.id == feedId ? nowPlaying.feed : null;

    final feedData = feed.value ?? fallbackFeed;
    final episodeData = episode.value ?? fallbackEpisode;

    if (feedData == null && episodeData == null && (feed.isLoading || episode.isLoading)) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final feedError = feed.error;
    final episodeError = episode.error;
    if ((feedError != null || episodeError != null) &&
        (feedData == null || episodeData == null)) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _ErrorBody(
          message: (feedError ?? episodeError).toString(),
          onRetry: () {
            ref.invalidate(podcastFeedProvider(feedId));
            ref.invalidate(podcastEpisodeProvider(episodeId));
          },
        ),
      );
    }
    if (feedData == null || episodeData == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _ErrorBody(
          message: 'Episode not found.',
          onRetry: () => context.pop(),
          retryLabel: 'Go back',
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _EpisodeDetailBody(
        episode: episodeData,
        feed: feedData,
      ),
    );
  }
}

class _EpisodeDetailBody extends ConsumerWidget {
  const _EpisodeDetailBody({
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
    final canPlay = episode.enclosureUrl != null && episode.enclosureUrl!.isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            feed.displayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: artwork.isEmpty
                        ? PodcastArtwork(feed: feed, size: 200)
                        : CachedNetworkImage(
                            imageUrl: artwork,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  episode.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      Formatters.duration(episode.duration),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (episode.datePublished != null)
                      Text(
                        Formatters.publishedDate(episode.datePublished),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    if (episode.explicit)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'EXPLICIT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: canPlay
                        ? () => playEpisode(
                              ref,
                              episode: episode,
                              feed: feed,
                              expandPlayer: true,
                            )
                        : null,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Play episode'),
                  ),
                ),
                if (episode.descriptionText.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Text(
                    'About this episode',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    episode.descriptionText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
