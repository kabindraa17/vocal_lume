import 'curated_podcast.dart';

/// A browse category with a fixed list of curated podcast highlights.
class CuratedCategory {
  const CuratedCategory({
    required this.title,
    required this.subtitle,
    required this.podcasts,
  });

  final String title;
  final String subtitle;
  final List<CuratedPodcast> podcasts;
}
