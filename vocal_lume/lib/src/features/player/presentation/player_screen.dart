import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../application/player_notifier.dart';
import '../domain/now_playing_state.dart';
import 'widgets/playback_error_banner.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  /// Progress value while the user is dragging the slider; null when idle.
  double? _dragProgress;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerProvider);
    final theme = Theme.of(context);

    if (!state.hasEpisode) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.headphones_outlined,
                size: 56,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text('Nothing playing', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Pick an episode to start listening',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFF2A1B45),
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _Header(showTitle: showTitle),
                    const SizedBox(height: 24),
                    _Artwork(artwork: artwork),
                    const SizedBox(height: 28),
                    Text(
                      episode.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showTitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.errorMessage != null) ...[
                      PlaybackErrorBanner(
                        message: state.errorMessage!,
                        onRetry: () =>
                            ref.read(playerProvider.notifier).retry(),
                        onDismiss: () =>
                            ref.read(playerProvider.notifier).dismissError(),
                      ),
                      const SizedBox(height: 16),
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
                          overlayRadius: 18,
                        ),
                      ),
                      child: Slider(
                        value: displayedProgress,
                        secondaryTrackValue:
                            state.bufferedProgress.clamp(0.0, 1.0),
                        onChanged: state.duration.inMilliseconds > 0
                            ? (value) => setState(() => _dragProgress = value)
                            : null,
                        onChangeEnd: (value) {
                          final position = Duration(
                            milliseconds:
                                (value * state.duration.inMilliseconds)
                                    .round(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatClock(displayedPosition),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceMuted,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          Text(
                            '-${formatClock(displayedRemaining)}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceMuted,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Controls(state: state),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String formatClock(Duration duration) {
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

class _Header extends StatelessWidget {
  const _Header({required this.showTitle});

  final String showTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'NOW PLAYING',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                  letterSpacing: 2,
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
        // Balances the leading icon so the header text stays centred.
        const SizedBox(width: 48),
      ],
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.artwork});

  final String artwork;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Hero(
        tag: 'now-playing-artwork',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 48,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: artwork.isEmpty
                ? Container(
                    color: AppColors.surfaceHigh,
                    child: const Icon(Icons.podcasts, size: 80),
                  )
                : CachedNetworkImage(
                    imageUrl: artwork,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.surfaceHigh),
                    errorWidget: (_, _, _) => Container(
                      color: AppColors.surfaceHigh,
                      child: const Icon(Icons.podcasts, size: 80),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.state});

  final NowPlayingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(playerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SpeedButton(speed: state.speed, enabled: !state.isLoading),
        Row(
          children: [
            IconButton(
              onPressed: notifier.skipBackward,
              icon: const Icon(Icons.replay_10_rounded),
              iconSize: 36,
              tooltip: 'Back 10 seconds',
            ),
            const SizedBox(width: 12),
            _PlayPauseButton(state: state),
            const SizedBox(width: 12),
            IconButton(
              onPressed: notifier.skipForward,
              icon: const Icon(Icons.forward_30_rounded),
              iconSize: 36,
              tooltip: 'Forward 30 seconds',
            ),
          ],
        ),
        IconButton(
          onPressed: () async {
            await notifier.clear();
            if (context.mounted && context.canPop()) context.pop();
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
        padding: const EdgeInsets.all(22),
        backgroundColor:
            state.hasError ? AppColors.danger : AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
      ),
      child: state.isLoading
          ? const SizedBox(
              width: 36,
              height: 36,
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
                size: 36,
                color: AppColors.background,
              ),
            ),
    );
  }
}

class _SpeedButton extends ConsumerWidget {
  const _SpeedButton({required this.speed, required this.enabled});

  final double speed;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: enabled ? () => _showSpeedSheet(context, ref) : null,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.surfaceHigh,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary)
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
      height: 44,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: const Size(double.infinity, 44),
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
