import '../datasources/podcast_index_remote_datasource.dart';
import '../models/podcast_detail.dart';
import '../models/podcast_episode.dart';
import '../models/podcast_feed.dart';

/// Domain-facing API for podcast data.
class PodcastRepository {
  const PodcastRepository(this._remote);

  final PodcastIndexRemoteDataSource _remote;

  Future<List<PodcastFeed>> search(String query) =>
      _remote.searchByTerm(query);

  Future<List<PodcastFeed>> trending() => _remote.getTrending();

  Future<PodcastDetail> podcastDetail(int feedId) =>
      _remote.getPodcastDetail(feedId);

  Future<PodcastFeed> podcastFeed(int feedId) => _remote.getPodcastByFeedId(feedId);

  Future<List<PodcastEpisode>> episodesByFeedId(int feedId, {int max = 20}) =>
      _remote.getEpisodesByFeedId(feedId, max: max);

  Future<PodcastEpisode> episodeById(int episodeId) =>
      _remote.getEpisodeById(episodeId);
}
