import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/player_expansion_notifier.dart';
import '../../application/player_notifier.dart';
import '../../domain/now_playing_state.dart';
import 'playback_error_banner.dart';

/// Compact floating bar — artwork, title, play/pause, bottom progress.
class MiniPlayerContent extends ConsumerWidget {
  const MiniPlayerContent({
    super.key,
    required this.onExpand,
  });

  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final episode = state.episode!;
    final feed = state.feed;
    final artwork = episode.artworkUrl.isNotEmpty
        ? episode.artworkUrl
        : feed?.artworkUrl ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onExpand,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 4, 4),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: artwork.isEmpty
                          ? Container(
                              width: 48,
                              height: 48,
                              color: AppColors.surfaceHigh,
                              child: const Icon(
                                Icons.podcasts,
                                size: 22,
                                color: Colors.white70,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: artwork,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.hasError
                                ? 'Tap to retry'
                                : (feed?.displayTitle ??
                                    episode.feedTitle?.trim() ??
                                    'Podcast'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: state.hasError
                                  ? AppColors.danger
                                  : AppColors.onSurfaceMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _MiniPlayButton(
                      isLoading: state.isLoading,
                      isPlaying: state.isPlaying,
                      isCompleted: state.isCompleted,
                      hasError: state.hasError,
                      onTap: () =>
                          ref.read(playerProvider.notifier).togglePlayPause(),
                    ),
                  ],
                ),
              ),
            ),
            LinearProgressIndicator(
              value: state.isLoading ? null : state.progress.clamp(0.0, 1.0),
              minHeight: 2,
              backgroundColor: AppColors.surfaceHigh,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayButton extends StatelessWidget {
  const _MiniPlayButton({
    required this.isLoading,
    required this.isPlaying,
    required this.isCompleted,
    required this.hasError,
    required this.onTap,
  });

  final bool isLoading;
  final bool isPlaying;
  final bool isCompleted;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      );
    }

    final icon = hasError
        ? Icons.refresh_rounded
        : isCompleted
            ? Icons.replay_rounded
            : isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded;

    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 30,
        color: hasError ? AppColors.danger : Colors.white,
      ),
      tooltip: isPlaying ? 'Pause' : 'Play',
    );
  }
}

/// Full-screen now playing view inside the morphing sheet.
class ExpandedPlayerContent extends ConsumerStatefulWidget {
  const ExpandedPlayerContent({
    super.key,
    required this.onCollapse,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final VoidCallback onCollapse;
  final ValueChanged<double>? onDragUpdate;
  final ValueChanged<double>? onDragEnd;

  @override
  ConsumerState<ExpandedPlayerContent> createState() =>
      _ExpandedPlayerContentState();
}

class _ExpandedPlayerContentState extends ConsumerState<ExpandedPlayerContent> {
  double? _dragProgress;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerProvider);
    final theme = Theme.of(context);
    final episode = state.episode!;
    final feed = state.feed;
    final artwork = episode.artworkUrl.isNotEmpty
        ? episode.artworkUrl
        : feed?.artworkUrl ?? '';
    final showTitle =
        feed?.displayTitle ?? episode.feedTitle?.trim() ?? 'Podcast';

    final displayedProgress =
        _dragProgress ?? state.progress.clamp(0.0, 1.0);
    final displayedPosition = _dragProgress != null
        ? Duration(
            milliseconds:
                (_dragProgress! * state.duration.inMilliseconds).round(),
          )
        : state.position;
    final displayedRemaining = state.duration - displayedPosition;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.4, 1.0],
          colors: [
            Color(0xFF2A1B45),
            AppColors.background,
            AppColors.background,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _ExpandedHeader(
                showTitle: showTitle,
                onCollapse: widget.onCollapse,
                onDragUpdate: widget.onDragUpdate,
                onDragEnd: widget.onDragEnd,
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: widget.onDragUpdate == null
                      ? null
                      : (details) =>
                          widget.onDragUpdate!(details.primaryDelta ?? 0),
                  onVerticalDragEnd: widget.onDragEnd == null
                      ? null
                      : (details) =>
                          widget.onDragEnd!(details.primaryVelocity ?? 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: _ExpandedArtwork(artwork: artwork),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        episode.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        showTitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.errorMessage != null) ...[
                PlaybackErrorBanner(
                  message: state.errorMessage!,
                  onRetry: () => ref.read(playerProvider.notifier).retry(),
                  onDismiss: () =>
                      ref.read(playerProvider.notifier).dismissError(),
                ),
                const SizedBox(height: 12),
              ] else
                _Waveform(
                  isPlaying: state.isPlaying,
                  progress: displayedProgress,
                ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                    elevation: 2,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                ),
                child: Slider(
                  value: displayedProgress,
                  secondaryTrackValue: state.bufferedProgress.clamp(0.0, 1.0),
                  onChanged: state.duration.inMilliseconds > 0
                      ? (value) => setState(() => _dragProgress = value)
                      : null,
                  onChangeEnd: (value) {
                    final position = Duration(
                      milliseconds:
                          (value * state.duration.inMilliseconds).round(),
                    );
                    ref.read(playerProvider.notifier).seek(position);
                    setState(() => _dragProgress = null);
                  },
                  activeColor: AppColors.primary,
                  secondaryActiveColor:
                      AppColors.primary.withValues(alpha: 0.25),
                  inactiveColor: AppColors.surfaceHigh,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatClock(displayedPosition),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      '-${_formatClock(displayedRemaining)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ExpandedControls(state: state),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatClock(Duration duration) {
    var totalSeconds = duration.inSeconds;
    if (totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$mm:$ss' : '$minutes:$ss';
  }
}

class _ExpandedHeader extends StatelessWidget {
  const _ExpandedHeader({
    required this.showTitle,
    required this.onCollapse,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final String showTitle;
  final VoidCallback onCollapse;
  final ValueChanged<double>? onDragUpdate;
  final ValueChanged<double>? onDragEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onDragUpdate == null
          ? null
          : (details) => onDragUpdate!(details.primaryDelta ?? 0),
      onVerticalDragEnd: onDragEnd == null
          ? null
          : (details) => onDragEnd!(details.primaryVelocity ?? 0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.onSurfaceMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                onPressed: onCollapse,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
                tooltip: 'Minimize',
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'NOW PLAYING',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      showTitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpandedArtwork extends StatelessWidget {
  const _ExpandedArtwork({required this.artwork});

  final String artwork;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(
          320.0,
          math.min(constraints.maxWidth, constraints.maxHeight),
        );

        if (size <= 0) {
          return const SizedBox.shrink();
        }

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: artwork.isEmpty
                    ? Container(
                        color: AppColors.surfaceHigh,
                        child: const Icon(Icons.podcasts, size: 72),
                      )
                    : CachedNetworkImage(
                        imageUrl: artwork,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: AppColors.surfaceHigh),
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.surfaceHigh,
                          child: const Icon(Icons.podcasts, size: 72),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExpandedControls extends ConsumerWidget {
  const _ExpandedControls({required this.state});

  final NowPlayingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(playerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _SpeedChip(speed: state.speed, enabled: !state.isLoading),
        IconButton(
          onPressed: notifier.skipBackward,
          icon: const Icon(Icons.replay_10_rounded),
          iconSize: 34,
          tooltip: 'Back 10 seconds',
        ),
        _PlayPauseButton(state: state),
        IconButton(
          onPressed: notifier.skipForward,
          icon: const Icon(Icons.forward_30_rounded),
          iconSize: 34,
          tooltip: 'Forward 30 seconds',
        ),
        IconButton(
          onPressed: () async {
            await notifier.clear();
            ref.read(playerExpansionProvider.notifier).collapse();
          },
          icon: const Icon(Icons.stop_rounded),
          iconSize: 28,
          color: AppColors.onSurfaceMuted,
          tooltip: 'Stop',
        ),
      ],
    );
  }
}

class _PlayPauseButton extends ConsumerWidget {
  const _PlayPauseButton({required this.state});

  final NowPlayingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final IconData icon;
    if (state.hasError) {
      icon = Icons.refresh_rounded;
    } else if (state.isCompleted) {
      icon = Icons.replay_rounded;
    } else if (state.isPlaying) {
      icon = Icons.pause_rounded;
    } else {
      icon = Icons.play_arrow_rounded;
    }

    return FilledButton(
      onPressed: state.isLoading
          ? null
          : () => ref.read(playerProvider.notifier).togglePlayPause(),
      style: FilledButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: state.hasError ? AppColors.danger : AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
      ),
      child: state.isLoading
          ? const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.background,
              ),
            )
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                icon,
                key: ValueKey(icon),
                size: 34,
                color: AppColors.background,
              ),
            ),
    );
  }
}

class _SpeedChip extends ConsumerWidget {
  const _SpeedChip({required this.speed, required this.enabled});

  final double speed;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: enabled ? () => _showSpeedSheet(context, ref) : null,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.surfaceHigh,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(52, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: Text(
        _speedLabel(speed),
        style: theme.textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showSpeedSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Playback speed',
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            for (final option in PlayerNotifier.playbackSpeeds)
              ListTile(
                title: Text(_speedLabel(option)),
                trailing: option == speed
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(playerProvider.notifier).setPlaybackSpeed(option);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static String _speedLabel(double speed) {
    if (speed == speed.roundToDouble()) {
      return '${speed.toInt()}x';
    }
    return '${speed}x';
  }
}

class _Waveform extends StatefulWidget {
  const _Waveform({required this.isPlaying, required this.progress});

  final bool isPlaying;
  final double progress;

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform>
    with SingleTickerProviderStateMixin {
  static const _barCount = 36;

  late final AnimationController _controller;
  late final List<double> _heights;

  @override
  void initState() {
    super.initState();
    final random = math.Random(7);
    _heights = List.generate(
      _barCount,
      (_) => 0.25 + random.nextDouble() * 0.75,
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.isPlaying) _controller.repeat();
  }

  @override
  void didUpdateWidget(_Waveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: const Size(double.infinity, 40),
          painter: _WaveformPainter(
            heights: _heights,
            phase: _controller.value,
            isPlaying: widget.isPlaying,
            progress: widget.progress,
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.heights,
    required this.phase,
    required this.isPlaying,
    required this.progress,
  });

  final List<double> heights;
  final double phase;
  final bool isPlaying;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = heights.length;
    const barWidth = 4.0;
    final gap =
        (size.width - barCount * barWidth) / math.max(barCount - 1, 1);
    final playedBars = (progress * barCount).floor();

    for (var i = 0; i < barCount; i++) {
      final animated = isPlaying
          ? 0.6 +
              0.4 *
                  math.sin(
                    (phase * 2 * math.pi) + i * 0.7,
                  ).abs()
          : 0.55;
      final barHeight =
          (heights[i] * animated * size.height).clamp(4.0, size.height);
      final x = i * (barWidth + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          (size.height - barHeight) / 2,
          barWidth,
          barHeight,
        ),
        const Radius.circular(999),
      );
      final paint = Paint()
        ..color = i <= playedBars
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.22);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.isPlaying != isPlaying ||
      oldDelegate.progress != progress;
}
