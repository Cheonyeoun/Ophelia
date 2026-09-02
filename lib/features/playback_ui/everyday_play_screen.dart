import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/playback_controller.dart';
import '../../app/theme.dart';
import '../../app/widgets/cover_art.dart';

/// Everyday Play — pushed, no nav bar, no mini-player (it *is* the
/// player). Matches the "Everyday play" frame in
/// docs/design/ophelia-ui-mockup-2.html. Tapping the cover art enters
/// Immersive Play — the mockups don't show a dedicated "expand" icon
/// here, so the cover art (a common now-playing pattern) is the
/// immersive-toggle affordance the architecture doc's §6 refers to.
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
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
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
                    child: const CoverArt(size: 200, borderRadius: 16),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    track.title,
                    textAlign: TextAlign.center,
                    style: frauncesStyle(fontSize: 19),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.paleDim),
                  ),
                  const SizedBox(height: 22),
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
                          _formatDuration(Duration(milliseconds: track.durationMs)),
                          style: const TextStyle(fontSize: 10, color: AppColors.mist),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
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
                        onPressed: () => controller.seekBy(const Duration(seconds: -10)),
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
                        onPressed: () => controller.seekBy(const Duration(seconds: 10)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 26),
                        color: AppColors.paleDim,
                        onPressed: controller.skipNext,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shuffle, size: 16, color: AppColors.mist),
                        SizedBox(width: 38),
                        Icon(Icons.repeat, size: 16, color: AppColors.mist),
                        SizedBox(width: 38),
                        Icon(Icons.queue_music, size: 16, color: AppColors.mist),
                      ],
                    ),
                  ),
                ],
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
