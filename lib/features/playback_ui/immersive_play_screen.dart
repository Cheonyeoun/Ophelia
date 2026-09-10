import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/responsive.dart';
import '../../app/theme.dart';
import '../../core/usecases/set_immersive_hud_auto_hide_delay.dart';
import 'playback_controller.dart';
import 'playback_scrubber.dart';

/// Immersive Play — pushed, no nav bar, no mini-player. Matches the
/// "Immersive play" frame in docs/design/ophelia-ui-mockup.html: full-
/// bleed art with a scrim, title/artist, flow-line, and a simpler
/// 3-button transport (no seek buttons, unlike Everyday Play — though
/// the flow-line is itself an interactive scrubber now, on both
/// screens). Both screens subscribe to the same playback state
/// (docs/architecture.md §7) — they differ only in which controls they
/// render.
///
/// Unlike Everyday Play's scrubber, this one's `lineAlwaysVisible` is
/// false — the entire scrubber, not just its thumb, stays invisible
/// until first touched, reinforcing this screen's minimal philosophy
/// (nothing at all is drawn over the art until the viewer asks for it).
///
/// The background art is already fully responsive (`Positioned.fill`),
/// but the scrim's own padding/gaps were fixed pixel values that could
/// overflow on a short screen — [compactScale] shrinks those together
/// instead, the same way Everyday Play does.
///
/// True full-screen while this is open, like a game's HUD: entering
/// switches to [SystemUiMode.immersiveSticky] (hides the status bar and
/// Android's own on-screen/gesture nav bar, temporarily revealed by a
/// swipe from the edge and auto-hidden again — the "sticky" part), and
/// leaving restores [SystemUiMode.edgeToEdge], the default modern Android
/// apps (including every other screen in this one) already draw under.
/// Without this, the system bars stayed on screen the whole time,
/// permanently eating into the "full-bleed" art this screen exists to
/// show — never actually hiding themselves the way this screen's own
/// content already does.
class ImmersivePlayScreen extends ConsumerStatefulWidget {
  const ImmersivePlayScreen({super.key});

  @override
  ConsumerState<ImmersivePlayScreen> createState() =>
      _ImmersivePlayScreenState();
}

class _ImmersivePlayScreenState extends ConsumerState<ImmersivePlayScreen> {
  static const _fadeDuration = Duration(milliseconds: 200);

  Timer? _hideTimer;
  bool _revealed = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// Called on every pointer-down anywhere on screen (see the top-level
  /// `Listener` in [build]) -- both to bring the HUD back once it's
  /// faded out, and to push the auto-hide countdown back out on each
  /// fresh interaction while it's already showing, mirroring
  /// `PlaybackScrubber`'s own `_reveal`/`_scheduleHide` pair.
  void _reveal() {
    if (!_revealed) setState(() => _revealed = true);
    _scheduleHide();
  }

  /// Reads the configured delay fresh each time, rather than caching it,
  /// so a change made on the Settings screen takes effect on this
  /// screen's very next interaction without needing to reopen it.
  void _scheduleHide() {
    _hideTimer?.cancel();
    final delayString = ref
        .read(settingsControllerProvider)
        .immersiveHudAutoHideDelay;
    final delay = parseImmersiveHudAutoHideDelay(delayString);
    // `null` means "Off" -- never auto-hide, so the HUD (already
    // revealed by the caller) just stays that way indefinitely.
    if (delay == null) return;
    _hideTimer = Timer(delay, () {
      if (mounted) setState(() => _revealed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(playbackControllerProvider.notifier);
    final uiState = ref.watch(playbackControllerProvider);
    final track = uiState.playback.currentTrack;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: LayoutBuilder(
        builder: (context, outerConstraints) {
          final scale = compactScale(
            availableHeight: outerConstraints.maxHeight,
          );
          double gap(double base) => (base * scale).clamp(base * 0.4, base);

          // Verified on a real device: every child below this point is
          // `Positioned` except the header row, and a `Stack` with only
          // one non-`Positioned` child sizes itself to *that child's own
          // size* when its own incoming constraints are loose (as
          // `Scaffold.body`'s are) -- not to the constraints it was
          // given. That shrank this Stack down to just the header row's
          // height, so the "bottom: 0" content block ended up pinned to
          // the bottom of a Stack only as tall as the header, painting
          // outside those (unenforced, for a Positioned child) bounds
          // and overlapping the header instead of sitting at the actual
          // screen bottom. `SizedBox.expand` forces the Stack to actually
          // fill the space `LayoutBuilder` confirms is available.
          // Any tap/drag anywhere on screen -- background art included --
          // brings the HUD back (or just pushes its auto-hide countdown
          // back out if already showing). `Listener` observes the raw
          // pointer event without joining the gesture arena, so it never
          // interferes with the buttons/scrubber painted on top of it.
          return Listener(
            onPointerDown: (_) => _reveal(),
            behavior: HitTestBehavior.translucent,
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.4, -0.4),
                          radius: 1.1,
                          colors: [
                            AppColors.willow.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _revealed ? 1 : 0,
                    duration: _fadeDuration,
                    child: IgnorePointer(
                      ignoring: !_revealed,
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: gap(26),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18,
                                ),
                                color: AppColors.pale,
                                onPressed: () {
                                  controller.toggleImmersive();
                                  context.pop();
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_fullscreen_rounded,
                                  size: 18,
                                ),
                                color: AppColors.paleDim,
                                onPressed: () {
                                  controller.toggleImmersive();
                                  context.pop();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (track != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      // `top: false` -- the header row above already has its
                      // own SafeArea for the top inset; this only needs to
                      // keep the transport controls clear of the bottom one
                      // (a gesture nav bar some OEM skins won't fully hide
                      // even in `immersiveSticky`, or its brief reveal via an
                      // edge swipe), rather than pinning to the raw screen
                      // edge regardless of what's actually safe there.
                      child: AnimatedOpacity(
                        opacity: _revealed ? 1 : 0,
                        duration: _fadeDuration,
                        child: IgnorePointer(
                          ignoring: !_revealed,
                          child: SafeArea(
                            top: false,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                26,
                                gap(40),
                                26,
                                gap(40),
                              ),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [AppColors.void_, Colors.transparent],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    track.title,
                                    style: frauncesStyle(fontSize: 22),
                                  ),
                                  SizedBox(height: gap(4)),
                                  Text(
                                    track.artist,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.paleDim,
                                    ),
                                  ),
                                  SizedBox(height: gap(22)),
                                  PlaybackScrubber(
                                    trackId: track.id,
                                    position: uiState.playback.position,
                                    duration: Duration(
                                      milliseconds: track.durationMs,
                                    ),
                                    onSeek: controller.seekTo,
                                    lineAlwaysVisible: false,
                                  ),
                                  SizedBox(height: gap(26)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.skip_previous_rounded,
                                          size: 26,
                                        ),
                                        color: AppColors.paleDim,
                                        onPressed: controller.skipPrevious,
                                      ),
                                      SizedBox(width: gap(34)),
                                      InkWell(
                                        onTap: controller.togglePlayPause,
                                        customBorder: const CircleBorder(),
                                        child: Container(
                                          width: 52,
                                          height: 52,
                                          decoration: const BoxDecoration(
                                            color: AppColors.pale,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            uiState.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: AppColors.void_,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: gap(34)),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.skip_next_rounded,
                                          size: 26,
                                        ),
                                        color: AppColors.paleDim,
                                        onPressed: controller.skipNext,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
