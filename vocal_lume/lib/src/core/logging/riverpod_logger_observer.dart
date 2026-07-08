import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_logger.dart';

/// Logs provider updates and failures for easier debugging.
final class RiverpodLoggerObserver extends ProviderObserver {
  const RiverpodLoggerObserver();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (newValue is AsyncError) {
      AppLogger.error(
        'Provider "${context.provider.name ?? context.provider.runtimeType}" '
        'emitted AsyncError.',
        tag: 'Riverpod',
        error: newValue.error,
        stackTrace: newValue.stackTrace,
      );
    }
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    AppLogger.error(
      'Provider "${context.provider.name ?? context.provider.runtimeType}" '
      'failed.',
      tag: 'Riverpod',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
