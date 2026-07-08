import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/player/application/player_expansion_notifier.dart';
import '../../features/player/presentation/widgets/draggable_player_overlay.dart';
import '../../features/player/presentation/widgets/player_error_listener.dart';

/// Wraps the router with a persistent draggable player and back handling.
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlayerExpanded =
        ref.watch(playerExpansionProvider) == PlayerExpansion.expanded;

    return PopScope(
      canPop: !isPlayerExpanded,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && isPlayerExpanded) {
          ref.read(playerExpansionProvider.notifier).collapse();
        }
      },
      child: PlayerErrorListener(
        child: Stack(
          children: [
            if (child != null) child!,
            const DraggablePlayerOverlay(),
          ],
        ),
      ),
    );
  }
}
