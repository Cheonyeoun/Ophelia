import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/responsive.dart';
import '../../app/theme.dart';
import '../../app/widgets/cover_art.dart';
import '../../core/domain/playback_state.dart';
import 'playback_controller.dart';

/// Everyday Play — pushed, no nav bar, no mini-player (it *is* the
/// player). Matches the "Everyday play" frame in
/// docs/design/ophelia-ui-mockup-2.html. Tapping the cover art enters
/// Immersive Play — the mockups don't show a dedicated "expand" icon
/// here, so the cover art (a common now-playing pattern) is the
/// immersive-toggle affordance the architecture doc's §6 refers to.
///
/// This screen is a single fixed-size column, not something scrollable,
/// so on a short device it can't just grow a scrollbar — [compactScale]
/// shrinks the cover art and the gaps between elements together so
/// nothing overflows, instead of a fixed 200x200 cover and fixed gaps
/// regardless of available height.
class EverydayPlayScreen extends ConsumerWidget {
  const EverydayPlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playbackControllerProvider.notifier);
    final uiState = ref.watch(playbackControllerProvider);
    final track = uiState.playback.currentTrack;

    return Scaffold(
      backgroundColor: AppColors.void_,
      body: SafeArea(
        child: track == null
            ? const Center(
                child: Text(
                  'Nothing playing',
                  style: TextStyle(color: AppColors.mist),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final scale = compactScale(
                    availableHeight: constraints.maxHeight,
                  );
                  double gap(double base) =>
                      (base * scale).clamp(base * 0.4, base);
                  final coverSize = (200.0 * scale).clamp(
                    120.0,
                    constraints.maxWidth * 0.62,
                  );

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                              ),
                              color: AppColors.pale,
                              onPressed: () => context.pop(),
                            ),
                            const Expanded(
                              child: Text(
                                'playing from queue',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, color: AppColors.mist),
                              ),
                            ),
                            const IconButton(
                              icon: Icon(Icons.menu, size: 18),
                              color: AppColors.paleDim,
                              onPressed: null,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          controller.toggleImmersive();
                          context.push('/immersive-play');
                        },
                        child: CoverArt(size: coverSize, borderRadius: 16),
                      ),
                      SizedBox(height: gap(22)),
                      Text(
                        track.title,
                        textAlign: TextAlign.center,
                        style: frauncesStyle(fontSize: 19),
                      ),
                      SizedBox(height: gap(4)),
                      Text(
                        track.artist,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppColors.paleDim),
                      ),
                      SizedBox(height: gap(22)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _FlowLine(
                          progress: track.durationMs == 0
                              ? 0
                              : uiState.playback.position.inMilliseconds /
                                  track.durationMs,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(uiState.playback.position),
                              style: const TextStyle(fontSize: 10, color: AppColors.mist),
                            ),
                            Text(
                              _formatDuration(
                                Duration(milliseconds: track.durationMs),
                              ),
                              style: const TextStyle(fontSize: 10, color: AppColors.mist),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap(22)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded, size: 26),
                            color: AppColors.paleDim,
                            onPressed: controller.skipPrevious,
                          ),
                          IconButton(
                            icon: const Icon(Icons.replay_10_rounded, size: 22),
                            color: AppColors.paleDim,
                            onPressed: () =>
                                controller.seekBy(const Duration(seconds: -10)),
                          ),
                          const SizedBox(width: 8),
                          _PlayPauseButton(
                            isPlaying: uiState.isPlaying,
                            onTap: controller.togglePlayPause,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.forward_10_rounded, size: 22),
                            color: AppColors.paleDim,
                            onPressed: () =>
                                controller.seekBy(const Duration(seconds: 10)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, size: 26),
                            color: AppColors.paleDim,
                            onPressed: controller.skipNext,
                          ),
                        ],
                      ),
                      SizedBox(height: gap(12)),
                      Padding(
                        padding: EdgeInsets.only(bottom: gap(24)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: controller.toggleShuffle,
                              child: Icon(
                                Icons.shuffle,
                                size: 16,
                                color: uiState.playback.shuffle
                                    ? AppColors.willow
                                    : AppColors.mist,
                              ),
                            ),
                            const SizedBox(width: 38),
                            GestureDetector(
                              onTap: controller.toggleRepeatMode,
                              child: Icon(
                                uiState.playback.repeatMode == RepeatMode.one
                                    ? Icons.repeat_one
                                    : Icons.repeat,
                                size: 16,
                                color: uiState.playback.repeatMode != RepeatMode.off
                                    ? AppColors.willow
                                    : AppColors.mist,
                              ),
                            ),
                            const SizedBox(width: 38),
                            GestureDetector(
                              onTap: () => context.push('/queue'),
                              child: const Icon(
                                Icons.queue_music,
                                size: 16,
                                color: AppColors.mist,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayPauseButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(color: AppColors.pale, shape: BoxShape.circle),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: AppColors.void_,
        ),
      ),
    );
  }
}

class _FlowLine extends StatelessWidget {
  final double progress;

  const _FlowLine({required this.progress});

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(height: 1, color: AppColors.flowTrack),
            Container(
              height: 4,
              width: constraints.maxWidth * clamped,
              decoration: BoxDecoration(
                color: AppColors.willow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
