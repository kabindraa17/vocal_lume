import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlayerExpansion { mini, expanded }

final playerExpansionProvider =
    NotifierProvider<PlayerExpansionNotifier, PlayerExpansion>(
  PlayerExpansionNotifier.new,
);

class PlayerExpansionNotifier extends Notifier<PlayerExpansion> {
  @override
  PlayerExpansion build() => PlayerExpansion.mini;

  void expand() => state = PlayerExpansion.expanded;

  void collapse() => state = PlayerExpansion.mini;

  void toggle() {
    state = state == PlayerExpansion.mini
        ? PlayerExpansion.expanded
        : PlayerExpansion.mini;
  }
}
