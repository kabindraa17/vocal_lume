import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/podcast_providers.dart';
import '../../../core/providers/database_providers.dart';
import '../../downloads/application/download_controller.dart';
import '../../downloads/presentation/widgets/episode_download_button.dart';
import '../../downloads/presentation/widgets/episode_download_progress_bar.dart';
import '../../library/application/library_providers.dart';
import '../../../core/utils/formatters.dart';
import '../data/models/podcast_episode.dart';
import '../data/models/podcast_feed.dart';
import '../domain/podcast_feed_preview.dart';
import '../../player/presentation/widgets/play_episode.dart';
import 'widgets/episode_info_sheet.dart';
import 'widgets/podcast_artwork.dart';

class PodcastDetailScreen extends ConsumerWidget {
  const PodcastDetailScreen({
    super.key,
    required this.feedId,
    this.preview,
  });

  final int feedId;
  final PodcastFeedPreview? preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(podcastFeedProvider(feedId));
    final theme = Theme.of(context);

    return Scaffold(
      body: feed.when(
        loading: () {
          if (preview != null) {
            return _PodcastDetailBody(
              feed: _previewFeed(preview!),
              feedId: feedId,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, _) => _ErrorBody(
          message: error.toString(),
          onRetry: () => ref.invalidate(podcastFeedProvider(feedId)),
        ),
        data: (feedData) => _PodcastDetailBody(
          feed: feedData.withPreview(preview),
          feedId: feedId,
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }
}

PodcastFeed _previewFeed(PodcastFeedPreview preview) {
  return PodcastFeed(
    id: preview.feedId,
    title: preview.title,
    author: preview.author,
    image: preview.artworkUrl,
    artwork: preview.artworkUrl,
  );
}

class _PodcastDetailBody extends ConsumerStatefulWidget {
  const _PodcastDetailBody({
    required this.feed,
    required this.feedId,
  });

  final PodcastFeed feed;
  final int feedId;

  @override
  ConsumerState<_PodcastDetailBody> createState() => _PodcastDetailBodyState();
}

class _PodcastDetailBodyState extends ConsumerState<_PodcastDetailBody> {
  static const int _pageSize = 20;
  int _maxEpisodes = _pageSize;
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  List<PodcastEpisode> _episodes = const [];

  @override
  void initState() {
    super.initState();
    _loadEpisodes(isInitialLoad: true);
  }

  Future<void> _loadEpisodes({required bool isInitialLoad}) async {
    if (_isLoadingMore || (!isInitialLoad && _isInitialLoading)) return;
    if (isInitialLoad) {
      setState(() {
        _isInitialLoading = true;
        _error = null;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
        _error = null;
      });
    }

    try {
      final episodes = await ref
          .read(podcastRepositoryProvider)
          .episodesByFeedId(widget.feedId, max: _maxEpisodes);
      if (!mounted) return;
      setState(() {
        _episodes = episodes;
        _hasMore = episodes.length >= _maxEpisodes;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isInitialLoading || _isLoadingMore || !_hasMore) return;
    _maxEpisodes += _pageSize;
    await _loadEpisodes(isInitialLoad: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscribedIds = ref.watch(subscribedFeedIdsProvider).value ?? {};
    final isFollowing = subscribedIds.contains(widget.feedId);
    final library = ref.read(libraryRepositoryProvider);
    final feed = widget.feed;
    final host = feed.author?.trim();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 300) {
          _loadMore();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            feed.displayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (feed.artworkUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: feed.artworkUrl,
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.55),
                    colorBlendMode: BlendMode.darken,
                  )
                else
                  Container(color: const Color(0xFF1A1228)),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'PODCAST',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  feed.displayTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                if (host != null && host.isNotEmpty)
                  Text(
                    'Hosted by $host',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                if (host != null && host.isNotEmpty) const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        if (isFollowing) {
                          await library.unsubscribe(widget.feedId);
                        } else {
                          await library.subscribe(feed);
                        }
                      },
                      icon: Icon(
                        isFollowing ? Icons.check : Icons.add,
                        size: 18,
                      ),
                      label: Text(isFollowing ? 'Following' : 'Follow'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Text(
                  'Episodes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'NEWEST',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isInitialLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (_episodes.isEmpty && _error != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _ErrorBody(
              message: _error!,
              onRetry: () => _loadEpisodes(isInitialLoad: true),
            ),
          )
        else if (_episodes.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No episodes found.')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.separated(
              itemCount: _episodes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _EpisodeCard(episode: _episodes[index], feed: feed),
            ),
          ),
        if (_isLoadingMore || _error != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Center(
                child: _isLoadingMore
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          Text(
                            _error ?? 'Could not load more.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _loadMore,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        if ((feed.description ?? '').isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About the Show',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feed.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  if (feed.categoryTags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: feed.categoryTags
                          .take(6)
                          .map(
                            (tag) => Chip(
                              label: Text(tag.toUpperCase()),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeCard extends ConsumerWidget {
  const _EpisodeCard({required this.episode, required this.feed});

  final PodcastEpisode episode;
  final PodcastFeed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final artwork = episode.artworkUrl.isNotEmpty
        ? episode.artworkUrl
        : feed.artworkUrl;

    final canPlay = episode.hasPlayableAudio;
    final download =
        ref.watch(downloadForEpisodeProvider(episode.id)).value;
    final live = ref.watch(downloadLiveStatsProvider(episode.id));
    final canPlayOffline = download?.canPlayOffline == true;
    final isPlayable = canPlay || canPlayOffline;
    final isDownloading = download?.status.isActive == true;

    void handlePlay() {
      if (!isPlayable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No audio file available for this episode.'),
          ),
        );
        return;
      }
      // Open the player fully; the podcast detail page stays
      // underneath as the back destination when collapsed.
      playEpisode(
        ref,
        episode: episode,
        feed: feed,
        expandPlayer: true,
      );
    }

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: handlePlay,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: artwork.isEmpty
                    ? PodcastArtwork(feed: feed, size: 72)
                    : CachedNetworkImage(
                        imageUrl: artwork,
                        width: 72,
                        height: 72,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          Formatters.duration(episode.duration),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (canPlayOffline) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.offline_pin_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Offline',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      episode.shortDescription,
                      maxLines: isDownloading ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    if (isDownloading && download != null) ...[
                      const SizedBox(height: 10),
                      EpisodeDownloadProgressBar(
                        download: download,
                        live: live,
                        compact: true,
                        onCancel: () => ref
                            .read(downloadControllerProvider.notifier)
                            .cancel(episode.id),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Text(
                        Formatters.publishedDate(episode.datePublished),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              EpisodeDownloadButton(episode: episode, feed: feed),
              IconButton(
                onPressed: () => showEpisodeInfoSheet(
                  context,
                  episode: episode,
                  feed: feed,
                ),
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                tooltip: 'Episode details',
              ),
              IconButton(
                onPressed: handlePlay,
                icon: Icon(
                  Icons.play_circle_fill,
                  color: isPlayable
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 36,
                ),
                tooltip: 'Play episode',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
