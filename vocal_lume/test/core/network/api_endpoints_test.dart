import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_lume/src/core/network/api_endpoints.dart';

void main() {
  const endpoints = <String>[
    ApiEndpoints.searchByTerm,
    ApiEndpoints.searchByTitle,
    ApiEndpoints.searchByPerson,
    ApiEndpoints.searchMusicPodcasts,
    ApiEndpoints.podcastByFeedId,
    ApiEndpoints.podcastByItunesId,
    ApiEndpoints.podcastByFeedUrl,
    ApiEndpoints.trendingPodcasts,
    ApiEndpoints.episodesByFeedId,
    ApiEndpoints.episodeById,
    ApiEndpoints.recentEpisodes,
    ApiEndpoints.recentFeeds,
  ];

  test('all endpoints start with a forward slash', () {
    for (final endpoint in endpoints) {
      expect(endpoint, startsWith('/'));
    }
  });

  test('all endpoint constants are unique', () {
    expect(endpoints.toSet().length, endpoints.length);
  });

  test('critical endpoint values stay stable', () {
    expect(ApiEndpoints.searchByTerm, '/search/byterm');
    expect(ApiEndpoints.trendingPodcasts, '/podcasts/trending');
    expect(ApiEndpoints.episodeById, '/episodes/byid');
    expect(ApiEndpoints.recentFeeds, '/recent/feeds');
  });
}
