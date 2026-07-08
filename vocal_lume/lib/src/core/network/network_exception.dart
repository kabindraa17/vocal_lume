/// Typed exception hierarchy for the Podcast Index API client.
/// All exceptions implement [Exception] and carry a human-readable [message]
/// plus an optional [cause] for stack-trace chaining.
library;

// ─────────────────────────────────────────────────────────────────────────────
// Base
// ─────────────────────────────────────────────────────────────────────────────

sealed class PodcastIndexException implements Exception {
  const PodcastIndexException({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'PodcastIndexException($runtimeType): $message';
}

// ─────────────────────────────────────────────────────────────────────────────
// Subtypes
// ─────────────────────────────────────────────────────────────────────────────

/// 401 / 403 — invalid or missing API credentials.
final class PodcastIndexAuthException extends PodcastIndexException {
  const PodcastIndexAuthException({
    required super.message,
    super.cause,
    this.statusCode,
  });

  final int? statusCode;
}

/// 404 — the requested resource was not found.
final class PodcastIndexNotFoundException extends PodcastIndexException {
  const PodcastIndexNotFoundException({required super.message, super.cause});
}

/// 5xx — server-side error; [statusCode] is always present.
final class PodcastIndexServerException extends PodcastIndexException {
  const PodcastIndexServerException({
    required super.message,
    required this.statusCode,
    super.cause,
  });

  final int statusCode;
}

/// Timeout or no-internet-connection errors.
final class PodcastIndexNetworkException extends PodcastIndexException {
  const PodcastIndexNetworkException({required super.message, super.cause});
}

/// JSON decoding failure; [offendingField] names the field that caused it.
final class PodcastIndexParseException extends PodcastIndexException {
  const PodcastIndexParseException({
    required super.message,
    this.offendingField,
    super.cause,
  });

  /// The JSON field key that triggered the parse failure, if known.
  final String? offendingField;
}

/// HTTP 200 but the API body contained `"status": "false"`.
final class PodcastIndexApiException extends PodcastIndexException {
  const PodcastIndexApiException({required super.message, super.cause});
}
