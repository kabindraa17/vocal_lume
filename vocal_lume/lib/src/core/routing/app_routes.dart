/// Route name constants used with [AppRouter] and GoRouter's named navigation.
///
/// Usage:
/// ```dart
/// context.goNamed(AppRoutes.home);
/// context.openPodcastDetail(feedId: 42, preview: PodcastFeedPreview.fromFeed(feed));
/// ```
abstract final class AppRoutes {
  // ── Root ──────────────────────────────────────────────────────────────────
  static const String home = 'home';

  // ── Podcast ───────────────────────────────────────────────────────────────
  static const String podcastSearch = 'podcast-search';
  static const String podcastDetail = 'podcast-detail';
  static const String episodeDetail = 'episode-detail';

  // ── Library ───────────────────────────────────────────────────────────────
  static const String library = 'library';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profile = 'profile';
}
