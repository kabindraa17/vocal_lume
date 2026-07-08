import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../player/presentation/widgets/play_episode.dart';
import '../application/library_providers.dart';
import '../data/library_repository.dart';
import '../domain/recent_activity.dart';

enum LibraryFilter { all, inProgress }

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibraryFilter _filter = LibraryFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recentAsync = ref.watch(recentActivityProvider);
    final subscriptionsAsync = ref.watch(subscriptionsProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: AppTopBar()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'Library',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          subscriptionsAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (subscriptions) {
              if (subscriptions.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        'Following',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 112,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: subscriptions.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final feed = subscriptions[index];
                          return _SubscriptionChip(
                            feed: feed,
                            onTap: () => context.push('/podcast/${feed.feedId}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filter == LibraryFilter.all,
                    onTap: () => setState(() => _filter = LibraryFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'In progress',
                    selected: _filter == LibraryFilter.inProgress,
                    onTap: () =>
                        setState(() => _filter = LibraryFilter.inProgress),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Recent Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          recentAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load recent activity: $error'),
              ),
            ),
            data: (items) {
              final filtered = _filterActivity(items);
              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Text(
                      _emptyMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _RecentActivityTile(item: filtered[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<RecentActivityItem> _filterActivity(List<RecentActivityItem> items) {
    return switch (_filter) {
      LibraryFilter.all => items,
      LibraryFilter.inProgress => items.where((i) => !i.isCompleted).toList(),
    };
  }

  String get _emptyMessage {
    return switch (_filter) {
      LibraryFilter.all =>
        'Play an episode to see your listening history here.',
      LibraryFilter.inProgress => 'No in-progress episodes yet.',
    };
  }
}

class _SubscriptionChip extends StatelessWidget {
  const _SubscriptionChip({
    required this.feed,
    required this.onTap,
  });

  final SubscribedFeedItem feed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 88,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: feed.artworkUrl != null && feed.artworkUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: feed.artworkUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          color: AppColors.surface,
                          child: const Icon(Icons.podcasts_outlined),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  feed.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.background : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityTile extends ConsumerWidget {
  const _RecentActivityTile({required this.item});

  final RecentActivityItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => playEpisodeById(
          ref,
          feedId: item.feedId,
          episodeId: item.episodeId,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.episodeTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.showTitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: item.progress,
                        minHeight: 4,
                        backgroundColor: AppColors.surfaceHigh,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.isCompleted
                          ? 'Completed'
                          : '${item.minutesLeft} mins left',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                item.isCompleted
                    ? Icons.check_circle_outline
                    : Icons.play_circle_outline,
                color: item.isCompleted
                    ? AppColors.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
