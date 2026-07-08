import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/player_notifier.dart';

class PlayerErrorListener extends ConsumerStatefulWidget {
  const PlayerErrorListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PlayerErrorListener> createState() =>
      _PlayerErrorListenerState();
}

class _PlayerErrorListenerState extends ConsumerState<PlayerErrorListener> {
  String? _lastSnackBarError;

  @override
  Widget build(BuildContext context) {
    ref.listen(playerProvider, (previous, next) {
      final error = next.errorMessage;
      if (error == null) {
        _lastSnackBarError = null;
        return;
      }
      if (error == previous?.errorMessage || error == _lastSnackBarError) {
        return;
      }

      _lastSnackBarError = error;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => ref.read(playerProvider.notifier).retry(),
          ),
        ),
      );
    });

    return widget.child;
  }
}
