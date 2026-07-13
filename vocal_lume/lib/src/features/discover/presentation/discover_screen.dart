import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/podcast_providers.dart';
import '../../../core/routing/podcast_navigation.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../podcast/data/models/podcast_feed.dart';
import '../../podcast/domain/podcast_feed_preview.dart';
import '../../podcast/presentation/widgets/podcast_artwork.dart';
import 'widgets/curated_categories_section.dart';
import 'widgets/top_ranked_section.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingPodcastsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppTopBar(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text(
                      'Explore podcasts',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: TopRankedSection()),
            const SliverToBoxAdapter(child: CuratedCategoriesSection()),
            trending.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: _ErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(trendingPodcastsProvider),
                ),
              ),
              data: (feeds) {
                if (feeds.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No trending podcasts found.')),
                  );
                }
                final homeSections = _buildHomeSections(feeds);
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final section = homeSections[index];
                      return _HomeSection(section: section);
                    }, childCount: homeSections.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSectionData {
  const _HomeSectionData({
    required this.title,
    required this.subtitle,
    required this.feeds,
  });

  final String title;
  final String subtitle;
  final List<PodcastFeed> feeds;
}

List<_HomeSectionData> _buildHomeSections(List<PodcastFeed> feeds) {
  final uniqueFeeds = <int, PodcastFeed>{
    for (final feed in feeds) feed.id: feed,
  };
  final feedList = uniqueFeeds.values.toList();
  final sections = <_HomeSectionData>[
    _HomeSectionData(
      title: 'Trending now',
      subtitle: 'What everyone is listening to right now.',
      feeds: feedList.take(10).toList(),
    ),
  ];

  final discovery = [...feedList]
    ..sort((a, b) {
      final aScore = (a.episodeCount ?? 0) + (a.categoryTags.length * 5);
      final bScore = (b.episodeCount ?? 0) + (b.categoryTags.length * 5);
      return bScore.compareTo(aScore);
    });
  sections.add(
    _HomeSectionData(
      title: 'Discovery picks',
      subtitle: 'Fresh podcasts to discover based on rich catalog metadata.',
      feeds: discovery.take(10).toList(),
    ),
  );

  final feedsByGenre = <String, List<PodcastFeed>>{};
  for (final feed in feedList) {
    for (final rawTag in feed.categoryTags) {
      final tag = rawTag.trim();
      if (tag.isEmpty) continue;
      feedsByGenre.putIfAbsent(tag, () => []).add(feed);
    }
  }

  final topGenres = feedsByGenre.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));
  for (final genreEntry in topGenres.take(5)) {
    sections.add(
      _HomeSectionData(
        title: genreEntry.key,
        subtitle: 'Top podcasts in ${genreEntry.key}.',
        feeds: genreEntry.value.take(10).toList(),
      ),
    );
  }

  return sections.where((section) => section.feeds.isNotEmpty).toList();
}

const double _kFeedCardHeight = 236;

class _HomeSection extends StatelessWidget {
  const _HomeSection({required this.section});

  final _HomeSectionData section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  section.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: _kFeedCardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: section.feeds.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _FeedPreviewCard(feed: section.feeds[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedPreviewCard extends StatelessWidget {
  const _FeedPreviewCard({required this.feed});

  final PodcastFeed feed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.openPodcastDetail(
          feedId: feed.id,
          preview: PodcastFeedPreview.fromFeed(feed),
        ),
        child: SizedBox(
          width: 155,
          height: _kFeedCardHeight,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: Center(
                    child: FittedBox(
                      child: PodcastArtwork(feed: feed, size: 110),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          feed.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feed.hostName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _CategoryTagsRow(
                        tags: feed.categoryTags.take(2).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTagsRow extends StatelessWidget {
  const _CategoryTagsRow({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 28,
      child: Row(
        children: [
          for (var i = 0; i < tags.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Flexible(child: _GenreChip(label: tags[i])),
          ],
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 48),
          const SizedBox(height: 16),
          Text(
            'Could not load podcasts',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
