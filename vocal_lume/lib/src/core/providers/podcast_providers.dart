import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/podcast_index_client.dart';
import '../../features/podcast/data/datasources/podcast_index_remote_datasource.dart';
import '../../features/podcast/data/models/podcast_episode.dart';
import '../../features/podcast/data/models/podcast_feed.dart';
import '../../features/podcast/data/repositories/podcast_repository.dart';

final podcastIndexConfigProvider = Provider<PodcastIndexConfig>((ref) {
  return PodcastIndexConfig.fromEnvironment();
});

final podcastIndexDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(podcastIndexConfigProvider);
  return PodcastIndexClient.create(config);
});

final podcastRemoteDataSourceProvider =
    Provider<PodcastIndexRemoteDataSource>((ref) {
  return PodcastIndexRemoteDataSource(ref.watch(podcastIndexDioProvider));
});

final podcastRepositoryProvider = Provider<PodcastRepository>((ref) {
  return PodcastRepository(ref.watch(podcastRemoteDataSourceProvider));
});

final trendingPodcastsProvider = FutureProvider<List<PodcastFeed>>((ref) {
  return ref.watch(podcastRepositoryProvider).trending();
});

final podcastSearchProvider =
    FutureProvider.family<List<PodcastFeed>, String>((ref, query) {
  if (query.trim().isEmpty) return Future.value(const []);
  return ref.watch(podcastRepositoryProvider).search(query.trim());
});

final podcastFeedProvider = FutureProvider.family<PodcastFeed, int>((
  ref,
  feedId,
) {
  return ref.watch(podcastRepositoryProvider).podcastFeed(feedId);
});

final podcastEpisodeProvider = FutureProvider.family<PodcastEpisode, int>((
  ref,
  episodeId,
) {
  return ref.watch(podcastRepositoryProvider).episodeById(episodeId);
});
