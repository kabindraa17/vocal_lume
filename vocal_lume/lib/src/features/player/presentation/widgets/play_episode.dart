import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/podcast_providers.dart';
import '../../application/player_expansion_notifier.dart';
import '../../application/player_notifier.dart';
import '../../../podcast/data/models/podcast_episode.dart';
import '../../../podcast/data/models/podcast_feed.dart';

/// Starts playback and optionally expands the draggable player.
///
/// Expands immediately (when requested) so the UI feels instant; audio load
/// continues in the background.
Future<void> playEpisode(
  WidgetRef ref, {
  required PodcastEpisode episode,
  required PodcastFeed feed,
  bool expandPlayer = false,
}) async {
  // Kick off playback first so the mini player appears immediately.
  final playFuture = ref.read(playerProvider.notifier).play(
        episode: episode,
        feed: feed,
      );
  if (expandPlayer) {
    ref.read(playerExpansionProvider.notifier).expand();
  }
  await playFuture;
}

/// Resumes or starts an episode from library activity using stored IDs.
///
/// Only fetches the episode (one network call). Feed metadata is taken from
/// the episode payload so playback can start sooner.
Future<void> playEpisodeById(
  WidgetRef ref, {
  required int feedId,
  required int episodeId,
  bool expandPlayer = false,
}) async {
  final repository = ref.read(podcastRepositoryProvider);
  final episode = await repository.episodeById(episodeId);
  final feed = PodcastFeed(
    id: feedId,
    title: episode.feedTitle?.trim().isNotEmpty == true
        ? episode.feedTitle!.trim()
        : 'Podcast',
    author: episode.feedAuthor,
    image: episode.feedImage,
    artwork: episode.feedImage,
  );
  await playEpisode(
    ref,
    episode: episode,
    feed: feed,
    expandPlayer: expandPlayer,
  );
}
