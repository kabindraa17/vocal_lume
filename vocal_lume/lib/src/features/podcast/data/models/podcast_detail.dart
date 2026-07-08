import 'podcast_episode.dart';
import 'podcast_feed.dart';

/// A podcast feed with its episodes, used on the detail screen.
class PodcastDetail {
  const PodcastDetail({
    required this.feed,
    required this.episodes,
  });

  final PodcastFeed feed;
  final List<PodcastEpisode> episodes;
}
