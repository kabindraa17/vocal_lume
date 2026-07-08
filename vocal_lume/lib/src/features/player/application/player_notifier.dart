import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/providers/database_providers.dart';
import '../../library/data/library_repository.dart';
import '../../podcast/data/models/podcast_episode.dart';
import '../../podcast/data/models/podcast_feed.dart';
import '../domain/now_playing_state.dart';
import '../domain/playback_errors.dart';
import 'audio_handler_provider.dart';
import 'podcast_audio_handler.dart';

final playerProvider = NotifierProvider<PlayerNotifier, NowPlayingState>(
  PlayerNotifier.new,
);

class PlayerNotifier extends Notifier<NowPlayingState> {
  static const playbackSpeeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  PodcastAudioHandler? _handler;
  LibraryRepository? _library;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _listenersAttached = false;

  /// Incremented on every play()/clear() so stale async completions from a
  /// previous episode load cannot overwrite the state of a newer one.
  int _playSession = 0;

  /// True while a new episode is being loaded into the audio engine; the
  /// position/state streams still emit values for the previous source during
  /// that window and must be ignored.
  bool _switchingSource = false;

  int _lastSavedPositionMs = -1;
  DateTime _lastSavedAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Snapshot of the latest state; `state` itself cannot be read inside
  /// onDispose, but progress still needs to be persisted there.
  NowPlayingState _latestState = const NowPlayingState();

  @override
  NowPlayingState build() {
    _handler = ref.read(podcastAudioHandlerProvider);
    _library = ref.read(libraryRepositoryProvider);
    listenSelf((_, next) => _latestState = next);
    ref.onDispose(_onDispose);
    return const NowPlayingState();
  }

  Future<void> play({
    required PodcastEpisode episode,
    required PodcastFeed feed,
  }) async {
    final session = ++_playSession;
    final url = episode.enclosureUrl;

    // Persist progress of the episode we are switching away from.
    if (state.hasEpisode && state.episode?.id != episode.id) {
      await _persistProgress(force: true);
    }

    state = NowPlayingState(
      episode: episode,
      feed: feed,
      isLoading: true,
      speed: state.speed,
      duration: Duration(seconds: episode.duration ?? 0),
    );

    if (url == null || url.isEmpty) {
      _setPlaybackError('This episode does not have a playable audio file.');
      return;
    }

    final handler = _handler;
    if (handler == null) {
      _setPlaybackError('Audio player is not ready yet.');
      return;
    }

    _attachListeners();
    _lastSavedPositionMs = -1;
    _switchingSource = true;

    try {
      final savedPositionMs = await _library?.getSavedPositionMs(episode.id);
      if (session != _playSession) return;

      final initialPosition = savedPositionMs != null && savedPositionMs > 0
          ? Duration(milliseconds: savedPositionMs)
          : null;

      await handler.playEpisode(
        episode: episode,
        feed: feed,
        initialPosition: initialPosition,
      );
      if (session != _playSession) return;

      final duration = handler.player.duration ??
          Duration(seconds: episode.duration ?? 0);

      _switchingSource = false;
      state = state.copyWith(
        duration: duration,
        position: initialPosition ?? Duration.zero,
        isLoading: false,
        isPlaying: true,
        clearErrorMessage: true,
      );
      await _persistProgress(force: true);
    } catch (error, _) {
      if (session != _playSession) return;
      _switchingSource = false;
      _setPlaybackError(error);
    }
  }

  Future<void> retry() async {
    final episode = state.episode;
    final feed = state.feed;
    if (episode == null || feed == null) return;
    await play(episode: episode, feed: feed);
  }

  void dismissError() {
    if (!state.hasError) return;
    state = state.copyWith(clearErrorMessage: true);
  }

  Future<void> togglePlayPause() async {
    final handler = _handler;
    if (handler == null || !state.hasEpisode) return;

    if (state.hasError) {
      await retry();
      return;
    }

    try {
      if (state.isPlaying) {
        await handler.pause();
        await _persistProgress(force: true);
      } else if (state.isCompleted) {
        // Episode finished: restart from the beginning.
        state = state.copyWith(isCompleted: false, position: Duration.zero);
        await handler.seek(Duration.zero);
        await handler.play();
      } else {
        await handler.play();
      }
    } catch (error, _) {
      _setPlaybackError(error);
    }
  }

  Future<void> seek(Duration position) async {
    final clamped = _clampToDuration(position);
    try {
      state = state.copyWith(
        position: clamped,
        isCompleted: false,
        clearErrorMessage: true,
      );
      await _handler?.seek(clamped);
      await _persistProgress(force: true);
    } catch (error, _) {
      _setPlaybackError(error);
    }
  }

  Future<void> skipForward() async {
    try {
      await _handler?.skipForward();
    } catch (error, _) {
      _setPlaybackError(error);
    }
  }

  Future<void> skipBackward() async {
    try {
      await _handler?.skipBackward();
    } catch (error, _) {
      _setPlaybackError(error);
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final handler = _handler;
    if (handler == null || !state.hasEpisode) return;

    try {
      await handler.setPlaybackSpeed(speed);
      state = state.copyWith(speed: speed);
    } catch (error, _) {
      _setPlaybackError(error);
    }
  }

  Future<void> cyclePlaybackSpeed() async {
    final currentIndex = playbackSpeeds.indexOf(state.speed);
    final nextIndex =
        currentIndex == -1 ? 0 : (currentIndex + 1) % playbackSpeeds.length;
    await setPlaybackSpeed(playbackSpeeds[nextIndex]);
  }

  Future<void> clear() async {
    _playSession++;
    _switchingSource = false;
    await _persistProgress(force: true);
    await _handler?.clear();
    state = const NowPlayingState();
  }

  void _attachListeners() {
    if (_listenersAttached) return;
    _listenersAttached = true;

    final handler = _handler!;
    final player = handler.player;

    _subscriptions.add(
      player.playbackEventStream.listen(
        null,
        onError: (Object error, StackTrace _) {
          if (!ref.mounted) return;
          _setPlaybackError(error);
        },
      ),
    );

    _subscriptions.add(
      player.positionStream.listen((position) {
        if (!ref.mounted || !state.hasEpisode || _switchingSource) return;
        state = state.copyWith(position: position);
        unawaited(_persistProgress());
      }),
    );

    _subscriptions.add(
      player.bufferedPositionStream.listen((buffered) {
        if (!ref.mounted || !state.hasEpisode || _switchingSource) return;
        state = state.copyWith(buffered: buffered);
      }),
    );

    _subscriptions.add(
      player.playerStateStream.listen((playerState) {
        if (!ref.mounted || !state.hasEpisode || _switchingSource) return;

        final completed =
            playerState.processingState == ProcessingState.completed;

        state = state.copyWith(
          isPlaying: playerState.playing && !completed,
          isLoading: playerState.processingState == ProcessingState.loading ||
              playerState.processingState == ProcessingState.buffering,
          isCompleted: completed,
        );

        if (completed && !state.hasError) {
          unawaited(_persistProgress(force: true, markCompleted: true));
        }
      }),
    );

    _subscriptions.add(
      player.durationStream.listen((duration) {
        if (!ref.mounted || duration == null) return;
        state = state.copyWith(duration: duration);
      }),
    );

    _subscriptions.add(
      player.speedStream.listen((speed) {
        if (!ref.mounted) return;
        state = state.copyWith(speed: speed);
      }),
    );

    _subscriptions.add(
      handler.mediaItem.listen((item) {
        if (!ref.mounted) return;
        // Playback stopped from the system notification.
        if (item == null && state.hasEpisode) {
          _playSession++;
          state = const NowPlayingState();
        }
      }),
    );
  }

  Duration _clampToDuration(Duration position) {
    if (position.isNegative) return Duration.zero;
    final duration = state.duration;
    if (duration > Duration.zero && position > duration) return duration;
    return position;
  }

  void _setPlaybackError(Object error) {
    state = state.copyWith(
      isLoading: false,
      isPlaying: false,
      errorMessage: error is String ? error : PlaybackErrors.message(error),
    );
  }

  Future<void> _persistProgress({
    bool force = false,
    bool markCompleted = false,
  }) async {
    // Read from the snapshot so this also works from onDispose, where
    // accessing `state` is forbidden.
    final snapshot = _latestState;
    final episode = snapshot.episode;
    final feed = snapshot.feed;
    final library = _library;
    if (episode == null || feed == null || library == null) return;

    final positionMs = snapshot.position.inMilliseconds;
    if (!force) {
      final elapsed = DateTime.now().difference(_lastSavedAt);
      final positionDelta = (positionMs - _lastSavedPositionMs).abs();
      if (elapsed.inSeconds < 10 && positionDelta < 5000) return;
    }

    _lastSavedAt = DateTime.now();
    _lastSavedPositionMs = positionMs;

    await library.savePlaybackProgress(
      episode: episode,
      feed: feed,
      position: snapshot.position,
      duration: snapshot.duration,
      markCompleted: markCompleted,
    );
  }

  Future<void> _onDispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _listenersAttached = false;
    await _persistProgress(force: true);
  }
}
