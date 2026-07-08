import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vocal_lume/main.dart';
import 'package:vocal_lume/src/core/providers/podcast_providers.dart';
import 'package:vocal_lume/src/features/player/application/audio_handler_provider.dart';
import 'package:vocal_lume/src/features/player/application/podcast_audio_handler.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // The real handler is created via AudioService.init() in main(),
          // which is unavailable in tests; a bare handler is enough for UI.
          podcastAudioHandlerProvider.overrideWithValue(
            PodcastAudioHandler(),
          ),
          trendingPodcastsProvider.overrideWith((ref) async => const []),
        ],
        child: const VocalLumeApp(),
      ),
    );
    // GoRouter needs a frame to settle
    await tester.pumpAndSettle();
    expect(find.text('VocaLume'), findsOneWidget);
  });
}
