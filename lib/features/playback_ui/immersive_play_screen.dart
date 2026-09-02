import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/playback_controller.dart';
import '../../app/theme.dart';

/// Immersive Play — pushed, no nav bar, no mini-player. Matches the
/// "Immersive play" frame in docs/design/ophelia-ui-mockup.html: full-
/// bleed art with a scrim, title/artist, flow-line, and a simpler
/// 3-button transport (no seek buttons, unlike Everyday Play). Both
/// screens subscribe to the same playback state (docs/architecture.md
/// §7) — they differ only in which controls they render.
class ImmersivePlayScreen extends ConsumerWidget {
  const ImmersivePlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playbackControllerProvider.notifier);
    final uiState = ref.watch(playbackControllerProvider);
    final track = uiState.playback.currentTrack;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.4, -0.4),
                  radius: 1.1,
                  colors: [AppColors.willow.withValues(alpha: 0.18), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
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
                padding: const EdgeInsets.fromLTRB(26, 40, 26, 40),
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
                    const SizedBox(height: 4),
                    Text(
                      track.artist,
                      style: const TextStyle(fontSize: 13, color: AppColors.paleDim),
                    ),
                    const SizedBox(height: 22),
                    Stack(
                      children: [
                        Container(height: 1, color: AppColors.flowTrack),
                        FractionallySizedBox(
                          widthFactor: track.durationMs == 0
                              ? 0
                              : (uiState.playback.position.inMilliseconds /
                                      track.durationMs)
                                  .clamp(0.0, 1.0),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.willow,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, size: 26),
                          color: AppColors.paleDim,
                          onPressed: controller.skipPrevious,
                        ),
                        const SizedBox(width: 34),
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
                        const SizedBox(width: 34),
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
      ),
    );
  }
}
