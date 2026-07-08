/// All Podcast Index API path segments.
///
/// The base URL is held in [PodcastIndexConfig.baseUrl] and is combined
/// with these segments by Dio automatically.
///
/// Usage inside the remote datasource:
/// ```dart
/// final response = await _dio.get(ApiEndpoints.searchByTerm, ...);
/// ```
abstract final class ApiEndpoints {
  // ── Search ──────────────────────────────────────────────────────────────
  /// Search podcasts by term.
  /// Params: `q` (String), `max` (int, default 20)
  static const String searchByTerm = '/search/byterm';

  /// Search podcasts by title only.
  /// Params: `q` (String), `max` (int)
  static const String searchByTitle = '/search/bytitle';

  /// Search podcasts by Person.
  /// Params: `q` (String), `max` (int)
  static const String searchByPerson = '/search/byperson';

  /// Search Music Podcasts
  /// Params: `q` (String), `max` (int)
  static const String searchMusicPodcasts = '/search/music/byterm';

  // ── Podcasts ─────────────────────────────────────────────────────────────
  /// Get a single podcast feed by its Podcast Index feed ID.
  /// Params: `id` (int)
  static const String podcastByFeedId = '/podcasts/byfeedid';

  /// Get a single podcast feed by its iTunes ID.
  /// Params: `id` (int)
  static const String podcastByItunesId = '/podcasts/byitunesid';

  /// Get a podcast feed by its RSS feed URL.
  /// Params: `url` (String)
  static const String podcastByFeedUrl = '/podcasts/byfeedurl';

  /// Trending podcasts (global or by category).
  /// Params: `max` (int), `cat` (String?, comma-separated category slugs),
  ///         `lang` (String?), `since` (int? Unix timestamp)
  static const String trendingPodcasts = '/podcasts/trending';

  // ── Episodes ──────────────────────────────────────────────────────────────
  /// Get episodes for a feed by feed ID.
  /// Params: `id` (int), `max` (int, default 10), `since` (int? Unix timestamp)
  static const String episodesByFeedId = '/episodes/byfeedid';

  /// Get a single episode by its Podcast Index episode ID.
  /// Params: `id` (int)
  static const String episodeById = '/episodes/byid';

  // ── Recent ────────────────────────────────────────────────────────────────
  /// Most recent episodes across all podcasts.
  /// Params: `max` (int, default 10), `excludeString` (String?)
  static const String recentEpisodes = '/recent/episodes';

  /// Most recently updated podcast feeds.
  /// Params: `max` (int, default 10), `since` (int? Unix timestamp)
  static const String recentFeeds = '/recent/feeds';
}
