import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/player_notifier.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: !state.hasEpisode
          ? const SizedBox.shrink()
          : const _MiniPlayerContent(),
    );
  }
}

class _MiniPlayerContent extends ConsumerWidget {
  const _MiniPlayerContent();

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
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: Material(
        color: AppColors.surfaceElevated,
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.pushNamed(AppRoutes.player),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 4, 6),
                child: Row(
                  children: [
                    Hero(
                      tag: 'now-playing-artwork',
                      child: ClipRRect(
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
                        onPressed: () =>
                            ref.read(playerProvider.notifier).togglePlayPause(),
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
                      onPressed: () =>
                          ref.read(playerProvider.notifier).clear(),
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
              LinearProgressIndicator(
                value: state.progress,
                minHeight: 3,
                backgroundColor: AppColors.surfaceHigh,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
