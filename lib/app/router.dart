import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/artist/artist_screen.dart';
import '../features/downloads/downloads_screen.dart';
import '../features/home/home_screen.dart';
import '../features/library/library_screen.dart';
import '../features/local_files/local_files_screen.dart';
import '../features/playback_ui/everyday_play_screen.dart';
import '../features/playback_ui/immersive_play_screen.dart';
import '../features/playback_ui/queue_screen.dart';
import '../features/playlist/playlist_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import 'theme.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/persistent_player_overlay.dart';

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

/// Maps a swipe-up's release velocity (pixels/second, signed negative for
/// "upward") to how long the Everyday Play slide-up transition takes — a
/// fast fling should feel like it's still carrying the gesture's own
/// momentum, not waiting out a fixed animation. `null` (a plain tap, or a
/// swipe that didn't clear the fling-velocity threshold on its own) gets
/// a calm, fixed default. Linear between the clamped speed bounds is
/// enough here; this isn't trying to model real physics, just to make a
/// fast flick visibly quicker than a slow one.
@visibleForTesting
Duration everydayPlayTransitionDuration(double? velocityPxPerSecond) {
  const defaultDuration = Duration(milliseconds: 320);
  if (velocityPxPerSecond == null) return defaultDuration;

  const minMs = 140.0;
  const maxMs = 380.0;
  const minSpeed = 200.0;
  const maxSpeed = 2500.0;

  final speed = velocityPxPerSecond.abs().clamp(minSpeed, maxSpeed);
  final t = (speed - minSpeed) / (maxSpeed - minSpeed);
  final ms = maxMs - t * (maxMs - minMs);
  return Duration(milliseconds: ms.round());
}

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
            path: '/local-files',
            builder: (context, state) => const LocalFilesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/artist/:name',
            // go_router already percent-decodes path parameters -- an
            // extra Uri.decodeComponent here double-decodes, which throws
            // on a name containing a literal '%' (e.g. one already
            // encoded) instead of just passing it through.
            builder: (context, state) => ArtistScreen(
              artistName: state.pathParameters['name']!,
            ),
          ),
          GoRoute(
            path: '/playlist/:id',
            builder: (context, state) => PlaylistScreen(
              playlistId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/everyday-play',
        // A custom transition, not the platform-default push, per
        // docs/architecture.md §6 ("slide up from bottom"): the duration
        // scales with `state.extra` -- the vertical fling velocity
        // (px/s) the mini-player's swipe-up gesture was released at (see
        // widgets/persistent_player_overlay.dart) -- so a fast flick
        // arrives quickly and a slow drag (or a plain tap, `extra: null`)
        // gets a calmer, fixed-duration slide.
        pageBuilder: (context, state) {
          final velocity = state.extra as double?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: const EverydayPlayScreen(),
            transitionDuration: everydayPlayTransitionDuration(velocity),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/immersive-play',
        builder: (context, state) => const ImmersivePlayScreen(),
      ),
      // Reached only from Everyday Play (which is itself outside the
      // outer ShellRoute, so it has no mini-player either) — nested
      // alongside it rather than inside the ShellRoute above. Pushing
      // from a route outside that shell into one of its nested routes
      // trips a Navigator duplicate-page-key assertion; a sibling
      // top-level route avoids crossing between the two Navigators.
      GoRoute(
        path: '/queue',
        builder: (context, state) => const QueueScreen(),
      ),
    ],
  );
});

/// The outer, persistent shell: floats the mini-player above [child],
/// offset to sit above the nav bar on a root-tab route or flush with the
/// screen edge otherwise. One instance is built by the `ShellRoute` and
/// stays mounted across all navigation within it.
class AppShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const AppShell({required this.state, required this.child, super.key});

  bool get _isRootTabRoute => _rootTabPaths.contains(state.uri.path);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.void_,
      child: Stack(
        children: [
          Positioned.fill(child: child),
          // Unconditional -- unlike the plain MiniPlayerBar this replaced,
          // this widget's own `State` holds the bubble's drag/snap
          // animation controllers, which must never be torn down just
          // because the current route changed (see
          // PersistentPlayerOverlay's own doc comment). It renders nothing
          // itself once nothing is loaded (see that class's `build`).
          Positioned.fill(
            child: PersistentPlayerOverlay(isRootTabRoute: _isRootTabRoute),
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
