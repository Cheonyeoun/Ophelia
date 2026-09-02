import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/downloads/downloads_screen.dart';
import '../features/home/home_screen.dart';
import '../features/library/library_screen.dart';
import '../features/playback_ui/everyday_play_screen.dart';
import '../features/playback_ui/immersive_play_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import 'playback_controller.dart';
import 'theme.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/mini_player_bar.dart';

/// Navigation shell composition root — implements the exact contract from
/// docs/architecture.md §6:
///
/// - Home, Library, Settings are root tabs with a bottom nav bar.
/// - Search, Downloads, Profile are pushed, full-screen, back-arrow
///   routes with no bottom nav bar.
/// - Everyday Play and Immersive Play are pushed with neither the nav
///   bar nor the mini-player.
/// - A persistent mini-player floats above the nav bar (or above the
///   screen edge, on a route with no nav bar) on every route except the
///   two player screens, hidden entirely when nothing is loaded.
///
/// This is achieved with two nested shells: an outer `ShellRoute` renders
/// the mini-player once — so it survives navigation without remounting —
/// around everything except the two player routes; an inner
/// `StatefulShellRoute.indexedStack`, nested inside it, renders the nav
/// bar around only the three root tabs and preserves each tab's own
/// navigation stack when switching between them.
final _rootTabPaths = ['/home', '/library', '/settings'];

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(state: state, child: child),
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                RootScaffold(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) => const HomeScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/library',
                    builder: (context, state) => const LibraryScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/downloads',
            builder: (context, state) => const DownloadsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/everyday-play',
        builder: (context, state) => const EverydayPlayScreen(),
      ),
      GoRoute(
        path: '/immersive-play',
        builder: (context, state) => const ImmersivePlayScreen(),
      ),
    ],
  );
});

/// The outer, persistent shell: floats the mini-player above [child],
/// offset to sit above the nav bar on a root-tab route or flush with the
/// screen edge otherwise. One instance is built by the `ShellRoute` and
/// stays mounted across all navigation within it.
class AppShell extends ConsumerWidget {
  final GoRouterState state;
  final Widget child;

  const AppShell({required this.state, required this.child, super.key});

  bool get _isRootTabRoute => _rootTabPaths.contains(state.uri.path);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(
      playbackControllerProvider.select((s) => s.playback.currentTrack),
    );
    final isPlaying = ref.watch(
      playbackControllerProvider.select((s) => s.isPlaying),
    );

    return Material(
      color: AppColors.void_,
      child: Stack(
        children: [
          Positioned.fill(child: child),
          if (track != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: (_isRootTabRoute ? kNavBarHeight : 0) + 8,
              child: MiniPlayerBar(
                track: track,
                isPlaying: isPlaying,
                onTap: () => context.push('/everyday-play'),
                onPlayPause: () =>
                    ref.read(playbackControllerProvider.notifier).togglePlayPause(),
              ),
            ),
        ],
      ),
    );
  }
}

/// The inner shell for the three root tabs: tab content above, the
/// bottom nav bar below. `StatefulShellRoute.indexedStack` preserves each
/// tab's own navigation state when switching between them.
class RootScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const RootScaffold({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: navigationShell),
        SizedBox(
          height: kNavBarHeight,
          child: BottomNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
          ),
        ),
      ],
    );
  }
}
