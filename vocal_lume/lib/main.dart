import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/logging/app_logger.dart';
import 'src/core/logging/riverpod_logger_observer.dart';
import 'src/core/routing/app_router.dart';
import 'src/core/theme/app_colors.dart';
import 'src/core/widgets/app_root.dart';
import 'src/features/downloads/application/download_controller.dart';
import 'src/features/player/application/audio_handler_provider.dart';
import 'src/features/player/application/podcast_audio_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error(
      'Unhandled Flutter framework error.',
      tag: 'Crash',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error(
      'Unhandled platform error.',
      tag: 'Crash',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  await runZonedGuarded(
    () async {
      final handler = await AudioService.init<PodcastAudioHandler>(
        builder: () => PodcastAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.karki.vocalume.vocal_lume.audio',
          androidNotificationChannelName: 'VocaLume Playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          rewindInterval: Duration(seconds: 10),
          fastForwardInterval: Duration(seconds: 30),
        ),
      );

      runApp(
        ProviderScope(
          observers: const [RiverpodLoggerObserver()],
          overrides: [podcastAudioHandlerProvider.overrideWithValue(handler)],
          child: const VocalLumeApp(),
        ),
      );
    },
    (error, stackTrace) {
      AppLogger.error(
        'Unhandled zone error.',
        tag: 'Crash',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

class VocalLumeApp extends ConsumerWidget {
  const VocalLumeApp({super.key});

  static const _seed = AppColors.primary;
  static const _background = AppColors.background;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warm up the download engine so background tasks can resume.
    ref.watch(downloadControllerProvider);

    return MaterialApp.router(
      title: 'VocaLume',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.dark),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      builder: (context, child) => AppRoot(child: child),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      surface: const Color(0xFF171022),
    );

    final base = ThemeData(
      colorScheme: scheme.copyWith(
        surface: AppColors.surface,
        surfaceContainerHigh: AppColors.surfaceHigh,
      ),
      scaffoldBackgroundColor: _background,
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      splashFactory: InkSparkle.splashFactory,
      chipTheme: ChipThemeData(
        backgroundColor: scheme.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.onSurfaceMuted,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}
