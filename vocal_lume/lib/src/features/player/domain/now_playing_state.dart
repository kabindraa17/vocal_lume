import '../../podcast/data/models/podcast_episode.dart';
import '../../podcast/data/models/podcast_feed.dart';

class NowPlayingState {
  const NowPlayingState({
    this.episode,
    this.feed,
    this.position = Duration.zero,
    this.buffered = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isLoading = false,
    this.isCompleted = false,
    this.speed = 1.0,
    this.errorMessage,
  });

  final PodcastEpisode? episode;
  final PodcastFeed? feed;
  final Duration position;
  final Duration buffered;
  final Duration duration;
  final bool isPlaying;
  final bool isLoading;
  final bool isCompleted;
  final double speed;
  final String? errorMessage;

  bool get hasEpisode => episode != null;

  bool get hasError => errorMessage != null;

  double get progress {
    if (duration.inMilliseconds <= 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  double get bufferedProgress {
    if (duration.inMilliseconds <= 0) return 0;
    return (buffered.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  Duration get remaining {
    final value = duration - position;
    return value.isNegative ? Duration.zero : value;
  }

  NowPlayingState copyWith({
    PodcastEpisode? episode,
    PodcastFeed? feed,
    Duration? position,
    Duration? buffered,
    Duration? duration,
    bool? isPlaying,
    bool? isLoading,
    bool? isCompleted,
    double? speed,
    String? errorMessage,
    bool clearEpisode = false,
    bool clearErrorMessage = false,
  }) {
    return NowPlayingState(
      episode: clearEpisode ? null : (episode ?? this.episode),
      feed: clearEpisode ? null : (feed ?? this.feed),
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      speed: speed ?? this.speed,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
