import 'package:dio/dio.dart';

import '../logging/app_logger.dart';
import 'network_exception.dart';
import 'podcast_index_auth_helper.dart';

/// A Dio [Interceptor] that:
///   1. **onRequest** — injects fresh auth headers into every outgoing call.
///   2. **onResponse** — logs the status code and body length in debug mode.
///   3. **onError** — converts raw [DioException] into a typed
///      [PodcastIndexException] before re-throwing, so upper layers never
///      deal with raw Dio errors.
class PodcastIndexInterceptor extends Interceptor {
  const PodcastIndexInterceptor({
    required String apiKey,
    required String apiSecret,
  }) : _apiKey = apiKey,
       _apiSecret = apiSecret;

  final String _apiKey;
  final String _apiSecret;

  // ── onRequest ──────────────────────────────────────────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final authHeaders = PodcastIndexAuthHelper.buildHeaders(
      apiKey: _apiKey,
      apiSecret: _apiSecret,
    );
    options.headers.addAll(authHeaders);
    AppLogger.info(
      '-> ${options.method} ${options.path} '
      'query=${AppLogger.toPrettyJson(options.queryParameters)}',
      tag: 'HTTP',
    );
    super.onRequest(options, handler);
  }

  // ── onResponse ─────────────────────────────────────────────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info(
      '<- ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.path} '
      '(${_bodyLength(response.data)} bytes)',
      tag: 'HTTP',
    );
    AppLogger.debug(
      'response body: ${AppLogger.toPrettyJson(response.data)}',
      tag: 'HTTP',
    );
    super.onResponse(response, handler);
  }

  // ── onError ────────────────────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final typedError = _mapToTypedException(err);
    AppLogger.error(
      '<!> ${err.requestOptions.method} ${err.requestOptions.path} '
      'failed: $typedError',
      tag: 'HTTP',
      error: err.error ?? err,
      stackTrace: err.stackTrace,
    );
    AppLogger.debug(
      'error response: ${AppLogger.toPrettyJson(err.response?.data)}',
      tag: 'HTTP',
    );
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: typedError,
        message: err.message,
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  PodcastIndexException _mapToTypedException(DioException err) {
    final status = err.response?.statusCode;

    // Auth errors
    if (status == 401 || status == 403) {
      return PodcastIndexAuthException(
        message:
            'Authentication failed (HTTP $status). '
            'Check your API key and secret.',
        statusCode: status,
        cause: err,
      );
    }

    // Not found
    if (status == 404) {
      return const PodcastIndexNotFoundException(
        message: 'The requested resource was not found (HTTP 404).',
      );
    }

    // Server errors
    if (status != null && status >= 500) {
      return PodcastIndexServerException(
        message: 'Podcast Index server error (HTTP $status).',
        statusCode: status,
        cause: err,
      );
    }

    // Network / timeout errors
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return PodcastIndexNetworkException(
          message: 'Network error: ${err.message ?? 'No internet connection.'}',
          cause: err,
        );
      default:
        break;
    }

    // JSON parse failure
    if (err.error is FormatException) {
      return PodcastIndexParseException(
        message: 'Failed to parse API response.',
        cause: err.error,
      );
    }

    // Fallback — wrap in network exception
    return PodcastIndexNetworkException(
      message: err.message ?? 'An unknown network error occurred.',
      cause: err,
    );
  }

  int _bodyLength(dynamic data) {
    if (data == null) return 0;
    if (data is String) return data.length;
    return data.toString().length;
  }
}
