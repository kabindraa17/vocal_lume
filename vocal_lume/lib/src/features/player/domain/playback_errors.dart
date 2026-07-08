import 'package:just_audio/just_audio.dart';

/// Maps audio engine errors to short user-facing copy.
abstract final class PlaybackErrors {
  static String message(Object error) {
    if (error is PlayerException) {
      final text = error.message?.trim();
      if (text != null && text.isNotEmpty) return text;
      return 'Playback failed for this episode.';
    }

    if (error is PlayerInterruptedException) {
      return 'Playback was interrupted.';
    }

    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('Failed host lookup') ||
        text.contains('NetworkException')) {
      return 'Network error. Check your connection and try again.';
    }

    return 'Could not play this episode. Please try again.';
  }
}
