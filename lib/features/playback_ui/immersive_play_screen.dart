import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/responsive.dart';
import '../../app/theme.dart';
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
class ImmersivePlayScreen extends ConsumerWidget {
  const ImmersivePlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

          return Stack(
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
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: gap(26),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        color: AppColors.pale,
                        onPressed: () {
                          controller.toggleImmersive();
                          context.pop();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_fullscreen_rounded, size: 18),
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
              if (track != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(26, gap(40), 26, gap(40)),
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
                        Text(track.title, style: frauncesStyle(fontSize: 22)),
                        SizedBox(height: gap(4)),
                        Text(
                          track.artist,
                          style: const TextStyle(fontSize: 13, color: AppColors.paleDim),
                        ),
                        SizedBox(height: gap(22)),
                        PlaybackScrubber(
                          trackId: track.id,
                          position: uiState.playback.position,
                          duration: Duration(milliseconds: track.durationMs),
                          onSeek: controller.seekTo,
                          lineAlwaysVisible: false,
                        ),
                        SizedBox(height: gap(26)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous_rounded, size: 26),
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
                                  uiState.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: AppColors.void_,
                                ),
                              ),
                            ),
                            SizedBox(width: gap(34)),
                            IconButton(
                              icon: const Icon(Icons.skip_next_rounded, size: 26),
                              color: AppColors.paleDim,
                              onPressed: controller.skipNext,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
