import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/player_expansion_notifier.dart';
import '../../application/player_notifier.dart';
import 'player_panel_content.dart';

/// Apple Podcasts-style draggable player that persists across all routes.
class DraggablePlayerOverlay extends ConsumerStatefulWidget {
  const DraggablePlayerOverlay({super.key});

  @override
  ConsumerState<DraggablePlayerOverlay> createState() =>
      _DraggablePlayerOverlayState();
}

class _DraggablePlayerOverlayState extends ConsumerState<DraggablePlayerOverlay>
    with SingleTickerProviderStateMixin {
  static const _miniBarHeight = 72.0;
  static const _animationDuration = Duration(milliseconds: 320);

  late final AnimationController _controller;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    ref.listenManual(playerExpansionProvider, (previous, next) {
      if (next == PlayerExpansion.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    ref.listenManual(playerProvider, (previous, next) {
      if (!next.hasEpisode) {
        _controller.value = 0;
        _dragOffset = 0;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isTabRoute(String path) {
    return path == '/' ||
        path == '/search' ||
        path == '/library' ||
        path == '/profile';
  }

  void _expand() => ref.read(playerExpansionProvider.notifier).expand();

  void _collapse() => ref.read(playerExpansionProvider.notifier).collapse();

  void _onDragUpdate(DragUpdateDetails details, double screenHeight) {
    final delta = -(details.primaryDelta ?? 0) / (screenHeight * 0.75);
    setState(() {
      _dragOffset = (_dragOffset + delta).clamp(-_controller.value, 1 - _controller.value);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final current = (_controller.value + _dragOffset).clamp(0.0, 1.0);
    setState(() => _dragOffset = 0);

    if (velocity < -400 || current > 0.45) {
      _expand();
    } else {
      _collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerProvider);
    if (!state.hasEpisode) return const SizedBox.shrink();

    // This overlay is mounted above route pages, so there may be no modal
    // route in its build context. Read location from the router delegate
    // instead of GoRouterState.of(context), which requires a modal route.
    final path = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final tabBarHeight = _isTabRoute(path) ? 64.0 : 0.0;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final collapsedHeight = _miniBarHeight + tabBarHeight + safeBottom;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress =
            (_controller.value + _dragOffset).clamp(0.0, 1.0);
        final panelHeight =
            lerpDouble(collapsedHeight, screenHeight, progress)!;
        final borderRadius = lerpDouble(16, 0, progress)!;
        final showExpanded = progress > 0.35;

        return Stack(
          children: [
            if (progress > 0.02)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _collapse,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5 * progress),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: panelHeight,
              child: showExpanded
                  ? GestureDetector(
                      onVerticalDragUpdate: (details) =>
                          _onDragUpdate(details, screenHeight),
                      onVerticalDragEnd: _onDragEnd,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(borderRadius),
                        ),
                        child: Material(
                          color: const Color(0xFF171022),
                          child: ExpandedPlayerContent(
                            onCollapse: _collapse,
                            collapseProgress: 1 - progress,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        const Expanded(
                          child: IgnorePointer(
                            ignoring: true,
                            child: SizedBox.expand(),
                          ),
                        ),
                        MiniPlayerContent(
                          onExpand: _expand,
                          bottomInset: tabBarHeight + safeBottom,
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
