import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_lume/src/core/widgets/app_root.dart';
import 'package:vocal_lume/src/features/player/application/audio_handler_provider.dart';
import 'package:vocal_lume/src/features/player/application/podcast_audio_handler.dart';
import 'package:vocal_lume/src/features/player/application/player_expansion_notifier.dart';
import 'package:vocal_lume/src/features/player/presentation/widgets/draggable_player_overlay.dart';

void main() {
  testWidgets('always includes draggable player overlay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          podcastAudioHandlerProvider.overrideWithValue(PodcastAudioHandler()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AppRoot(child: SizedBox()),
          ),
        ),
      ),
    );

    expect(find.byType(DraggablePlayerOverlay), findsOneWidget);
  });

  testWidgets('renders provided child when non-null', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          podcastAudioHandlerProvider.overrideWithValue(PodcastAudioHandler()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AppRoot(child: Text('Root Child')),
          ),
        ),
      ),
    );

    expect(find.text('Root Child'), findsOneWidget);
  });

  testWidgets('handles null child safely', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          podcastAudioHandlerProvider.overrideWithValue(PodcastAudioHandler()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AppRoot(child: null),
          ),
        ),
      ),
    );

    expect(find.byType(AppRoot), findsOneWidget);
    expect(find.byType(DraggablePlayerOverlay), findsOneWidget);
  });

  testWidgets('blocks pop and collapses when player is expanded', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.updateOverrides([
      podcastAudioHandlerProvider.overrideWithValue(PodcastAudioHandler()),
    ]);
    container.read(playerExpansionProvider.notifier).expand();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: AppRoot(child: SizedBox()),
          ),
        ),
      ),
    );

    final popScopeFinder = find.byWidgetPredicate((widget) => widget is PopScope);
    expect(popScopeFinder, findsOneWidget);
    final popScope = tester.widget<PopScope<Object?>>(popScopeFinder);
    expect(popScope.canPop, isFalse);

    popScope.onPopInvokedWithResult?.call(false, null);
    await tester.pump();

    expect(container.read(playerExpansionProvider), PlayerExpansion.mini);
  });

  testWidgets('allows pop when player is not expanded', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.updateOverrides([
      podcastAudioHandlerProvider.overrideWithValue(PodcastAudioHandler()),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: AppRoot(child: SizedBox()),
          ),
        ),
      ),
    );

    final popScopeFinder = find.byWidgetPredicate((widget) => widget is PopScope);
    expect(popScopeFinder, findsOneWidget);
    final popScope = tester.widget<PopScope<Object?>>(popScopeFinder);
    expect(popScope.canPop, isTrue);
  });
}
