import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/network_exception.dart';
import '../models/podcast_detail.dart';
import '../models/podcast_episode.dart';
import '../models/podcast_feed.dart';

/// Low-level Podcast Index HTTP calls.
class PodcastIndexRemoteDataSource {
  const PodcastIndexRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<PodcastFeed>> searchByTerm(String query, {int max = 20}) async {
    final data = await _get(ApiEndpoints.searchByTerm, {
      'q': query,
      'max': max,
    });
    return _parseFeeds(data);
  }

  Future<List<PodcastFeed>> getTrending({int max = 20}) async {
    final data = await _get(ApiEndpoints.trendingPodcasts, {'max': max});
    return _parseFeeds(data);
  }

  Future<PodcastFeed> getPodcastByFeedId(int feedId) async {
    final data = await _get(ApiEndpoints.podcastByFeedId, {'id': feedId});
    final feeds = _parseFeeds(data);
    if (feeds.isEmpty) {
      final episodes = await getEpisodesByFeedId(feedId, max: 1);
      if (episodes.isNotEmpty) {
        AppLogger.warning(
          'Feed lookup failed for id=$feedId; building fallback from episode data.',
          tag: 'PodcastAPI',
        );
        return _buildFallbackFeed(feedId, episodes.first);
      }
      throw const PodcastIndexNotFoundException(message: 'Podcast not found.');
    }
    return feeds.first;
  }

  Future<List<PodcastEpisode>> getEpisodesByFeedId(
    int feedId, {
    int max = 50,
  }) async {
    final data = await _get(ApiEndpoints.episodesByFeedId, {
      'id': feedId,
      'max': max,
    });
    return _parseEpisodes(data);
  }

  Future<PodcastEpisode> getEpisodeById(int episodeId) async {
    final data = await _get(ApiEndpoints.episodeById, {'id': episodeId});
    final episodes = _parseEpisodes(data);
    if (episodes.isEmpty) {
      throw const PodcastIndexNotFoundException(message: 'Episode not found.');
    }
    return episodes.first;
  }

  Future<PodcastDetail> getPodcastDetail(int feedId) async {
    final feedFuture = getPodcastByFeedId(feedId);
    final episodesFuture = getEpisodesByFeedId(feedId);

    PodcastFeed? feed;
    PodcastIndexNotFoundException? notFoundError;
    try {
      feed = await feedFuture;
    } on PodcastIndexNotFoundException catch (error) {
      notFoundError = error;
    }

    final episodes = await episodesFuture;
    if (feed == null) {
      if (episodes.isNotEmpty) {
        AppLogger.warning(
          'Feed lookup failed for id=$feedId; building fallback from episode data.',
          tag: 'PodcastAPI',
        );
        feed = _buildFallbackFeed(feedId, episodes.first);
      } else {
        throw notFoundError ??
            const PodcastIndexNotFoundException(message: 'Podcast not found.');
      }
    }

    return PodcastDetail(
      feed: feed,
      episodes: episodes,
    );
  }

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, dynamic> queryParameters,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data == null) {
        AppLogger.warning(
          'Received empty response body for "$path".',
          tag: 'PodcastAPI',
        );
        throw const PodcastIndexParseException(
          message: 'Empty response from Podcast Index.',
        );
      }
      _ensureSuccess(data);
      return data;
    } on DioException catch (error) {
      AppLogger.error(
        'Request failed at "$path".',
        tag: 'PodcastAPI',
        error: error.error ?? error,
        stackTrace: error.stackTrace,
      );
      if (error.error is PodcastIndexException) {
        throw error.error as PodcastIndexException;
      }
      rethrow;
    }
  }

  void _ensureSuccess(Map<String, dynamic> data) {
    final status = data['status'];
    if (status == false || status == 'false') {
      AppLogger.warning(
        'Podcast Index returned status=false: '
        '${data['description'] ?? 'no description'}',
        tag: 'PodcastAPI',
      );
      throw PodcastIndexApiException(
        message: data['description'] as String? ?? 'API request failed.',
      );
    }
  }

  List<PodcastFeed> _parseFeeds(Map<String, dynamic> data) {
    final raw = data['feeds'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(PodcastFeed.fromJson)
        .toList();
  }

  List<PodcastEpisode> _parseEpisodes(Map<String, dynamic> data) {
    final raw = data['items'];
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(PodcastEpisode.fromJson)
          .toList();
    }

    // `/episodes/byid` may return a single `episode` object instead of `items`.
    final single = data['episode'];
    if (single is Map<String, dynamic>) {
      return [PodcastEpisode.fromJson(single)];
    }

    return const [];
  }

  PodcastFeed _buildFallbackFeed(int feedId, PodcastEpisode episode) {
    return PodcastFeed(
      id: feedId,
      title: (episode.feedTitle ?? '').trim().isEmpty
          ? 'Podcast #$feedId'
          : episode.feedTitle!,
      author: episode.feedAuthor,
      image: episode.feedImage,
      artwork: episode.feedImage,
    );
  }
}
