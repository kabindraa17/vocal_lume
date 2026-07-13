import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/player_expansion_notifier.dart';
import '../../application/player_notifier.dart';
import 'player_panel_content.dart';

/// Spotify-style floating player: compact bar above the tab bar that morphs
/// into a full-screen now-playing sheet via tap or vertical drag.
class DraggablePlayerOverlay extends ConsumerStatefulWidget {
  const DraggablePlayerOverlay({super.key});

  static const miniHeight = 64.0;
  static const miniHorizontalInset = 8.0;
  static const miniBottomGap = 8.0;

  @override
  ConsumerState<DraggablePlayerOverlay> createState() =>
      _DraggablePlayerOverlayState();
}

class _DraggablePlayerOverlayState extends ConsumerState<DraggablePlayerOverlay>
    with SingleTickerProviderStateMixin {
  static const _spring =
      SpringDescription(mass: 1, stiffness: 420, damping: 38);

  late final AnimationController _controller;
  RouterDelegate<Object>? _routerDelegate;
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, value: 0);

    ref.listenManual(playerExpansionProvider, (previous, next) {
      if (_isDragging) return;
      final target = next == PlayerExpansion.expanded ? 1.0 : 0.0;
      if ((_controller.value - target).abs() > 0.02) {
        _animateTo(target);
      }
    });

    // Only reset when playback fully stops — never force-collapse on a new
    // episode, or expand-on-play races the animation back to mini.
    ref.listenManual(playerProvider, (previous, next) {
      if (next.hasEpisode) return;
      _controller.stop();
      _controller.value = 0;
      _dragOffset = 0;
      if (ref.read(playerExpansionProvider) != PlayerExpansion.mini) {
        ref.read(playerExpansionProvider.notifier).collapse();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _routerDelegate = GoRouter.maybeOf(context)?.routerDelegate;
      _routerDelegate?.addListener(_onRouteChanged);
    });
  }

  void _onRouteChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _routerDelegate?.removeListener(_onRouteChanged);
    _controller.dispose();
    super.dispose();
  }

  bool _isTabRoute(String path) {
    return path == '/' ||
        path == '/search' ||
        path == '/library' ||
        path == '/profile';
  }

  double get _progress =>
      (_controller.value + _dragOffset).clamp(0.0, 1.0).toDouble();

  void _expand() {
    HapticFeedback.selectionClick();
    _setExpanded(true);
  }

  void _collapse() {
    HapticFeedback.selectionClick();
    _setExpanded(false);
  }

  void _setExpanded(bool expanded, {double velocity = 0}) {
    final notifier = ref.read(playerExpansionProvider.notifier);
    if (expanded) {
      notifier.expand();
    } else {
      notifier.collapse();
    }
    _animateTo(expanded ? 1.0 : 0.0, velocity: velocity);
  }

  void _animateTo(double target, {double velocity = 0}) {
    _controller.animateWith(
      SpringSimulation(_spring, _controller.value, target, velocity),
    );
  }

  void _onDragUpdate(double deltaPixels, double screenHeight) {
    final delta = -deltaPixels / (screenHeight * 0.9);
    setState(() {
      _isDragging = true;
      _dragOffset = (_dragOffset + delta)
          .clamp(-_controller.value, 1 - _controller.value);
    });
  }

  void _onDragEnd(double velocityPixels, double screenHeight) {
    final velocity = -velocityPixels / (screenHeight * 0.9);
    final current = _progress;
    _controller.value = current;
    setState(() => _dragOffset = 0);

    // Snap like Spotify: fling velocity wins, otherwise midpoint bias.
    final shouldExpand = velocity > 0.55 ||
        (velocity < -0.55
            ? false
            : current > 0.38);

    _isDragging = true;
    if (shouldExpand) {
      ref.read(playerExpansionProvider.notifier).expand();
    } else {
      ref.read(playerExpansionProvider.notifier).collapse();
    }
    HapticFeedback.lightImpact();
    _animateTo(shouldExpand ? 1.0 : 0.0, velocity: velocity);
    _isDragging = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerProvider);
    if (!state.hasEpisode) return const SizedBox.shrink();

    final router = GoRouter.maybeOf(context);
    final path = router?.routerDelegate.currentConfiguration.uri.path ?? '/';
    final size = MediaQuery.sizeOf(context);
    final screenHeight = size.height;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final tabBarHeight = _isTabRoute(path) ? 64.0 : 0.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _progress;
        final miniOpacity = (1 - progress * 1.35).clamp(0.0, 1.0);
        final expandedOpacity = ((progress - 0.12) / 0.55).clamp(0.0, 1.0);

        final bottom = lerpDouble(
          tabBarHeight + safeBottom + DraggablePlayerOverlay.miniBottomGap,
          0,
          progress,
        )!;
        final height = lerpDouble(
          DraggablePlayerOverlay.miniHeight,
          screenHeight,
          progress,
        )!;
        final horizontal = lerpDouble(
          DraggablePlayerOverlay.miniHorizontalInset,
          0,
          progress,
        )!;
        final radius = lerpDouble(12, 0, progress)!;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (progress > 0.02)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _collapse,
                  behavior: HitTestBehavior.opaque,
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.55 * progress),
                  ),
                ),
              ),
            Positioned(
              left: horizontal,
              right: horizontal,
              bottom: bottom,
              height: height,
              child: Material(
                color: progress < 0.5
                    ? Color.lerp(
                        AppColors.surfaceElevated,
                        AppColors.background,
                        (progress * 2).clamp(0.0, 1.0),
                      )
                    : AppColors.background,
                elevation: lerpDouble(10, 0, progress)!,
                shadowColor: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(radius),
                  bottom: Radius.circular(
                    lerpDouble(12, 0, progress)!,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (expandedOpacity > 0.01)
                      Opacity(
                        opacity: expandedOpacity,
                        child: IgnorePointer(
                          ignoring: progress < 0.45,
                          child: ExpandedPlayerContent(
                            onCollapse: _collapse,
                            onDragUpdate: (delta) =>
                                _onDragUpdate(delta, screenHeight),
                            onDragEnd: (velocity) =>
                                _onDragEnd(velocity, screenHeight),
                          ),
                        ),
                      ),
                    if (miniOpacity > 0.01)
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          height: DraggablePlayerOverlay.miniHeight,
                          child: Opacity(
                            opacity: miniOpacity,
                            child: IgnorePointer(
                              ignoring: progress > 0.2,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onVerticalDragUpdate: (details) =>
                                    _onDragUpdate(
                                  details.primaryDelta ?? 0,
                                  screenHeight,
                                ),
                                onVerticalDragEnd: (details) => _onDragEnd(
                                  details.primaryVelocity ?? 0,
                                  screenHeight,
                                ),
                                child: MiniPlayerContent(onExpand: _expand),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
