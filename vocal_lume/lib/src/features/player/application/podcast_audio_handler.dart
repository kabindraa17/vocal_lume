import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../podcast/data/models/podcast_episode.dart';
import '../../podcast/data/models/podcast_feed.dart';

class PodcastAudioHandler extends BaseAudioHandler with SeekHandler {
  PodcastAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  final _player = AudioPlayer();

  AudioPlayer get player => _player;

  PodcastEpisode? get currentEpisode => _episode;
  PodcastFeed? get currentFeed => _feed;

  PodcastEpisode? _episode;
  PodcastFeed? _feed;

  Future<void> playEpisode({
    required PodcastEpisode episode,
    required PodcastFeed feed,
    Duration? initialPosition,
  }) async {
    final url = episode.enclosureUrl;
    if (url == null || url.isEmpty) {
      throw ArgumentError('Episode has no playable audio URL.');
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw ArgumentError('Episode audio URL is invalid.');
    }

    _episode = episode;
    _feed = feed;

    final artwork = _artworkUrl(episode, feed);
    mediaItem.add(
      MediaItem(
        id: url,
        title: episode.title,
        artist: feed.title,
        album: feed.title,
        artUri: artwork != null ? Uri.tryParse(artwork) : null,
        duration: episode.duration != null
            ? Duration(seconds: episode.duration!)
            : null,
        extras: {
          'episodeId': episode.id,
          'feedId': feed.id,
        },
      ),
    );

    // Loading with an initial position avoids the audible jump of
    // load-then-seek when resuming a partially played episode.
    await _player.setAudioSource(
      AudioSource.uri(uri),
      initialPosition: initialPosition,
    );

    await _player.play();
  }

  static const skipForwardInterval = Duration(seconds: 30);
  static const skipBackwardInterval = Duration(seconds: 10);

  Future<void> skipForward() async {
    final duration = _player.duration ?? Duration.zero;
    final next = _player.position + skipForwardInterval;
    await seek(next > duration ? duration : next);
  }

  Future<void> skipBackward() async {
    final next = _player.position - skipBackwardInterval;
    await seek(next < Duration.zero ? Duration.zero : next);
  }

  Future<void> setPlaybackSpeed(double speed) => _player.setSpeed(speed);

  Future<void> clear() async {
    await _player.stop();
    _episode = null;
    _feed = null;
    mediaItem.add(null);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    _episode = null;
    _feed = null;
    mediaItem.add(null);
    return super.stop();
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  String? _artworkUrl(PodcastEpisode episode, PodcastFeed feed) {
    final url = episode.artworkUrl.isNotEmpty
        ? episode.artworkUrl
        : feed.artworkUrl;
    return url.isEmpty ? null : url;
  }
}
