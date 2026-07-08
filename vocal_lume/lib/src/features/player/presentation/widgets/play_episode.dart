import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/podcast_providers.dart';
import '../../application/player_expansion_notifier.dart';
import '../../application/player_notifier.dart';
import '../../../podcast/data/models/podcast_episode.dart';
import '../../../podcast/data/models/podcast_feed.dart';

/// Starts playback and optionally expands the draggable player.
Future<void> playEpisode(
  WidgetRef ref, {
  required PodcastEpisode episode,
  required PodcastFeed feed,
  bool expandPlayer = false,
}) async {
  await ref.read(playerProvider.notifier).play(
        episode: episode,
        feed: feed,
      );
  if (expandPlayer) {
    ref.read(playerExpansionProvider.notifier).expand();
  }
}

/// Resumes or starts an episode from library activity using stored IDs.
Future<void> playEpisodeById(
  WidgetRef ref, {
  required int feedId,
  required int episodeId,
  bool expandPlayer = true,
}) async {
  final repository = ref.read(podcastRepositoryProvider);
  final results = await Future.wait<dynamic>([
    repository.podcastFeed(feedId),
    repository.episodeById(episodeId),
  ]);
  final feed = results[0] as PodcastFeed;
  final episode = results[1] as PodcastEpisode;
  await playEpisode(
    ref,
    episode: episode,
    feed: feed,
    expandPlayer: expandPlayer,
  );
}
