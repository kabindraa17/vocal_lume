import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/curated_podcast_navigation.dart';
import '../../application/top_ranked_podcasts_provider.dart';
import '../../domain/top_ranked_podcast.dart';

enum TopRankedView { grid, list, categories }

class TopRankedSection extends ConsumerStatefulWidget {
  const TopRankedSection({super.key});

  @override
  ConsumerState<TopRankedSection> createState() => _TopRankedSectionState();
}

class _TopRankedSectionState extends ConsumerState<TopRankedSection> {
  TopRankedView _view = TopRankedView.grid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final podcasts = ref.watch(topRankedPodcastsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Top-Ranked',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _ViewToggle(
                selected: _view,
                onSelected: (view) => setState(() => _view = view),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ViewContent(view: _view, podcasts: podcasts),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.selected, required this.onSelected});

  final TopRankedView selected;
  final ValueChanged<TopRankedView> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ViewChip(
          icon: Icons.grid_view_rounded,
          selected: selected == TopRankedView.grid,
          onTap: () => onSelected(TopRankedView.grid),
        ),
        const SizedBox(width: 8),
        _ViewChip(
          icon: Icons.view_list_rounded,
          selected: selected == TopRankedView.list,
          onTap: () => onSelected(TopRankedView.list),
        ),
        const SizedBox(width: 8),
        _ViewChip(
          icon: Icons.category_rounded,
          selected: selected == TopRankedView.categories,
          onTap: () => onSelected(TopRankedView.categories),
        ),
      ],
    );
  }
}

class _ViewChip extends StatelessWidget {
  const _ViewChip({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: selected ? AppColors.background : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ViewContent extends StatelessWidget {
  const _ViewContent({required this.view, required this.podcasts});

  final TopRankedView view;
  final List<TopRankedPodcast> podcasts;

  @override
  Widget build(BuildContext context) {
    return switch (view) {
      TopRankedView.grid => _GridView(podcasts: podcasts),
      TopRankedView.list => _ListView(podcasts: podcasts),
      TopRankedView.categories => _CategoriesView(podcasts: podcasts),
    };
  }
}

class _GridView extends StatelessWidget {
  const _GridView({required this.podcasts});

  final List<TopRankedPodcast> podcasts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (var i = 0; i < podcasts.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _TopRankedHeroCard(
              podcast: podcasts[i],
              rank: i + 1,
              compact: false,
            ),
          ],
        ],
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({required this.podcasts});

  final List<TopRankedPodcast> podcasts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: podcasts
            .map(
              (podcast) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopRankedHeroCard(
                  podcast: podcast,
                  rank: podcasts.indexOf(podcast) + 1,
                  compact: true,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView({required this.podcasts});

  final List<TopRankedPodcast> podcasts;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<TopRankedPodcast>>{};
    for (final podcast in podcasts) {
      grouped.putIfAbsent(podcast.category, () => []).add(podcast);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: entry.value.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: 280,
                    child: _TopRankedHeroCard(
                      podcast: entry.value[index],
                      rank: index + 1,
                      compact: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Editor's Choice–style hero card for top-ranked podcasts.
class _TopRankedHeroCard extends ConsumerWidget {
  const _TopRankedHeroCard({
    required this.podcast,
    required this.rank,
    required this.compact,
  });

  final TopRankedPodcast podcast;
  final int rank;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openTopRankedPodcast(context, ref, podcast),
        child: AspectRatio(
          aspectRatio: compact ? 2.4 : 1.55,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _HeroBackground(podcast: podcast),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(compact ? 14 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RankBadge(rank: rank),
                    const Spacer(),
                    Text(
                      podcast.displayTitle,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 6),
                      Text(
                        podcast.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () =>
                            openTopRankedPodcast(context, ref, podcast),
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text('Listen Now'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: const Color(0xFF150C22),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text(
                        podcast.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        rank == 1 ? 'TOP RANKED' : '#$rank TOP RANKED',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.podcast});

  final TopRankedPodcast podcast;

  @override
  Widget build(BuildContext context) {
    final url = podcast.artworkUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => _gradientFallback(),
        errorWidget: (_, _, _) => _gradientFallback(),
      );
    }
    return _gradientFallback();
  }

  Widget _gradientFallback() {
    final colors = _categoryGradient(podcast.category);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Text(
          podcast.displayTitle.characters.first.toUpperCase(),
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}

List<Color> _categoryGradient(String category) {
  return switch (category.toLowerCase()) {
    'comedy' => const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    'news' => const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    'true crime' => const [Color(0xFFEF4444), Color(0xFFB91C1C)],
    _ => const [Color(0xFF14B8A6), Color(0xFF0F766E)],
  };
}
