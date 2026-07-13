import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/discover/presentation/discover_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/player/application/player_notifier.dart';
import '../../features/podcast/domain/podcast_feed_preview.dart';
import '../../features/podcast/presentation/episode_detail_screen.dart';
import '../../features/podcast/presentation/podcast_detail_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../theme/app_colors.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: kDebugMode,
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DiscoverScreen(),
          ),
        ),
        GoRoute(
          path: '/search',
          name: AppRoutes.podcastSearch,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        GoRoute(
          path: '/library',
          name: AppRoutes.library,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LibraryScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          name: AppRoutes.profile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/podcast/:id',
      name: AppRoutes.podcastDetail,
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final preview = state.extra is PodcastFeedPreview
            ? state.extra! as PodcastFeedPreview
            : null;
        return _slideUpPage(
          state: state,
          child: PodcastDetailScreen(
            feedId: id,
            preview: preview,
          ),
        );
      },
      routes: [
        GoRoute(
          path: 'episode/:episodeId',
          name: AppRoutes.episodeDetail,
          pageBuilder: (context, state) {
            final feedId = int.parse(state.pathParameters['id']!);
            final episodeId = int.parse(state.pathParameters['episodeId']!);
            return _slideUpPage(
              state: state,
              child: EpisodeDetailScreen(
                feedId: feedId,
                episodeId: episodeId,
              ),
            );
          },
        ),
      ],
    ),
  ],
);

class _AppShell extends ConsumerWidget {
  const _AppShell({required this.child});
  final Widget child;

  static const _tabs = [
    (icon: Icons.explore_outlined, active: Icons.explore, label: 'Explore', path: '/'),
    (
      icon: Icons.search_outlined,
      active: Icons.search,
      label: 'Search',
      path: '/search',
    ),
    (
      icon: Icons.library_music_outlined,
      active: Icons.library_music,
      label: 'Library',
      path: '/library',
    ),
    (
      icon: Icons.person_outline,
      active: Icons.person,
      label: 'Profile',
      path: '/profile',
    ),
  ];

  int _indexForLocation(String location) {
    final index = _tabs.indexWhere((t) => t.path == location);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _indexForLocation(location);
    final hasMiniPlayer = ref.watch(playerProvider).hasEpisode;

    return Scaffold(
      body: Padding(
        // Mini player (64) + gap above nav (8) + breathing room.
        padding: EdgeInsets.only(bottom: hasMiniPlayer ? 72 : 0),
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.active, color: AppColors.primary),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

CustomTransitionPage<void> _slideUpPage({
  required GoRouterState state,
  required Widget child,
}) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
