import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

import 'network_exception.dart';
import 'podcast_index_interceptor.dart';

/// Configuration for the Podcast Index API client.
///
/// Credentials are supplied via `--dart-define-from-file=dart_defines.json`
/// or individual `--dart-define` flags at build time.
///
/// Copy [dart_defines.example.json] to `dart_defines.json` and fill in your
/// Podcast Index key and secret from https://api.podcastindex.org
class PodcastIndexConfig {
  const PodcastIndexConfig({
    required this.apiKey,
    required this.apiSecret,
    this.baseUrl = 'https://api.podcastindex.org/api/1.0',
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 10),
  });

  final String apiKey;
  final String apiSecret;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  /// Read credentials from compile-time environment variables.
  factory PodcastIndexConfig.fromEnvironment() {
    const apiKey = String.fromEnvironment('PODCAST_INDEX_API_KEY');
    const apiSecret = String.fromEnvironment('PODCAST_INDEX_API_SECRET');
    return PodcastIndexConfig(apiKey: apiKey, apiSecret: apiSecret);
  }
}

/// Creates and configures a [Dio] instance for the Podcast Index API.
///
/// Registers:
///   - [PodcastIndexInterceptor] for auth + logging + error mapping
///   - [RetryInterceptor] (dio_smart_retry) for 3-attempt exponential backoff
///     (1 s → 2 s → 4 s) on timeouts and 5xx only.
abstract final class PodcastIndexClient {
  /// Returns a fully configured [Dio] instance.
  static Dio create(PodcastIndexConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: const {'Content-Type': 'application/json'},
        responseType: ResponseType.json,
      ),
    );

    // Auth + logging + error-mapping interceptor (must be first)
    dio.interceptors.add(
      PodcastIndexInterceptor(
        apiKey: config.apiKey,
        apiSecret: config.apiSecret,
      ),
    );

    // Retry logic: 3 retries, exponential backoff, only on timeout / 5xx.
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 4),
        ],
        retryEvaluator: (DioException error, int attempt) =>
            _shouldRetry(error),
      ),
    );

    return dio;
  }

  /// Only retry on connection-level timeouts and server (5xx) errors.
  /// 4xx errors must never be retried.
  static bool _shouldRetry(DioException error) {
    // Check if the mapped error is a server or network exception
    if (error.error is PodcastIndexServerException) return true;
    if (error.error is PodcastIndexNetworkException) return true;

    // Also catch raw Dio timeout types before the interceptor maps them
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return true;
      default:
        break;
    }

    final status = error.response?.statusCode;
    if (status != null && status >= 500) return true;

    return false;
  }
}
