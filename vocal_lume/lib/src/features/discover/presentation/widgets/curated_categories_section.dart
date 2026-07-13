import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/curated_categories_provider.dart';
import '../../application/curated_podcast_navigation.dart';
import '../../domain/curated_category.dart';
import '../../domain/curated_podcast.dart';

const double _kCardWidth = 155;
const double _kCardHeight = 220;

class CuratedCategoriesSection extends ConsumerWidget {
  const CuratedCategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(curatedCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < categories.length; i++) ...[
          if (i > 0) const SizedBox(height: 20),
          _CuratedCategoryRow(category: categories[i]),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CuratedCategoryRow extends StatelessWidget {
  const _CuratedCategoryRow({required this.category});

  final CuratedCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _kCardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: category.podcasts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _CuratedPodcastCard(
              podcast: category.podcasts[index],
              category: category.title,
            ),
          ),
        ),
      ],
    );
  }
}

class _CuratedPodcastCard extends ConsumerWidget {
  const _CuratedPodcastCard({
    required this.podcast,
    required this.category,
  });

  final CuratedPodcast podcast;
  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => openCuratedPodcast(context, ref, podcast),
        child: SizedBox(
          width: _kCardWidth,
          height: _kCardHeight,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: Center(
                    child: _CategoryArtwork(
                      title: podcast.displayTitle,
                      category: category,
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
                          podcast.displayTitle,
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
                        podcast.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                          height: 1.25,
                        ),
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

class _CategoryArtwork extends StatelessWidget {
  const _CategoryArtwork({required this.title, required this.category});

  final String title;
  final String category;

  @override
  Widget build(BuildContext context) {
    final colors = _categoryGradient(category);
    final initial = title.trim().isNotEmpty
        ? title.trim().characters.first.toUpperCase()
        : '?';

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

List<Color> _categoryGradient(String category) {
  return switch (category.toLowerCase()) {
    'comedy / variety' => const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    'news & politics' => const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    'true crime' => const [Color(0xFFEF4444), Color(0xFFB91C1C)],
    'society & culture' => const [Color(0xFFEC4899), Color(0xFFBE185D)],
    'science & education' => const [Color(0xFF10B981), Color(0xFF047857)],
    'historical & deep dives' => const [Color(0xFFD97706), Color(0xFF92400E)],
    _ => const [Color(0xFF14B8A6), Color(0xFF0F766E)],
  };
}
