import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/player_expansion_notifier.dart';
import '../../application/player_notifier.dart';
import '../../domain/now_playing_state.dart';

/// Compact player bar shown when the draggable panel is collapsed.
class MiniPlayerContent extends ConsumerWidget {
  const MiniPlayerContent({
    super.key,
    required this.onExpand,
    this.bottomInset = 0,
  });

  final VoidCallback onExpand;
  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final theme = Theme.of(context);
    final episode = state.episode!;
    final feed = state.feed;
    final artwork = episode.artworkUrl.isNotEmpty
        ? episode.artworkUrl
        : feed?.artworkUrl ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 6 + bottomInset),
      child: Material(
        color: AppColors.surfaceElevated,
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onExpand,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! < -4) {
                  onExpand();
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.onSurfaceMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 4, 6),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: artwork.isEmpty
                              ? Container(
                                  width: 44,
                                  height: 44,
                                  color: AppColors.surfaceHigh,
                                  child: const Icon(Icons.podcasts, size: 22),
                                )
                              : CachedNetworkImage(
                                  imageUrl: artwork,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                episode.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.hasError
                                    ? 'Playback failed — tap to retry'
                                    : (feed?.displayTitle ??
                                        episode.feedTitle?.trim() ??
                                        'Podcast'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: state.hasError
                                      ? AppColors.danger
                                      : AppColors.onSurfaceMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: () => ref
                                .read(playerProvider.notifier)
                                .togglePlayPause(),
                            icon: Icon(
                              state.hasError
                                  ? Icons.refresh_rounded
                                  : state.isCompleted
                                      ? Icons.replay_rounded
                                      : state.isPlaying
                                          ? Icons.pause_circle_filled_rounded
                                          : Icons.play_circle_filled_rounded,
                              color: state.hasError
                                  ? AppColors.danger
                                  : AppColors.primary,
                              size: 38,
                            ),
                            tooltip: state.isPlaying ? 'Pause' : 'Play',
                          ),
                        IconButton(
                          onPressed: () async {
                            await ref.read(playerProvider.notifier).clear();
                            ref
                                .read(playerExpansionProvider.notifier)
                                .collapse();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                          tooltip: 'Dismiss',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: state.progress,
              minHeight: 3,
              backgroundColor: AppColors.surfaceHigh,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Full player controls used inside the expanded draggable panel.
class ExpandedPlayerContent extends ConsumerStatefulWidget {
  const ExpandedPlayerContent({
    super.key,
    required this.onCollapse,
    this.collapseProgress = 0,
  });

  final VoidCallback onCollapse;
  final double collapseProgress;

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
    final artworkScale = lerpDouble(0.55, 1.0, 1 - widget.collapseProgress)!;

    return Container(
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
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: widget.collapseProgress > 0.2
                ? const NeverScrollableScrollPhysics()
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  _ExpandedHeader(
                    showTitle: showTitle,
                    onCollapse: widget.onCollapse,
                  ),
                  const SizedBox(height: 16),
                  Transform.scale(
                    scale: artworkScale,
                    child: _ExpandedArtwork(artwork: artwork),
                  ),
                  const SizedBox(height: 20),
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
                  if (state.errorMessage != null)
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.danger,
                      ),
                    )
                  else
                    const SizedBox(height: 44),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  const SizedBox(height: 16),
                  _ExpandedControls(state: state, onCollapse: widget.onCollapse),
                  const SizedBox(height: 24),
                ],
              ),
            ),
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
  });

  final String showTitle;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null && details.primaryDelta! > 6) {
          onCollapse();
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.onSurfaceMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: onCollapse,
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
    return AspectRatio(
      aspectRatio: 1,
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
                  placeholder: (_, _) => Container(color: AppColors.surfaceHigh),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.surfaceHigh,
                    child: const Icon(Icons.podcasts, size: 80),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ExpandedControls extends ConsumerWidget {
  const _ExpandedControls({
    required this.state,
    required this.onCollapse,
  });

  final NowPlayingState state;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(playerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SpeedChip(speed: state.speed, enabled: !state.isLoading),
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
          : Icon(icon, size: 36, color: AppColors.background),
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
