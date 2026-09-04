import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/widgets/screen_top_bar.dart';
import '../../app/widgets/track_row.dart';
import 'playback_controller.dart';

/// Queue — pushed from Everyday Play's queue icon. Declared alongside
/// Everyday/Immersive Play as a top-level route outside the outer
/// `ShellRoute` (see app/router.dart), so — like those two — it has
/// neither the nav bar nor the mini-player; crossing from a route outside
/// that shell into one nested inside it trips a Navigator assertion, and
/// this screen is only ever reached from a route that's already outside
/// it. Shows `PlaybackState.queue` in order with the current track
/// highlighted; tapping a row jumps to that track, the same "tap to
/// play" pattern every other track list in the app uses.
///
/// Read-only for now: reordering would need a `PlaybackEnginePort`
/// method to reorder the queue while keeping currentIndex and shuffle
/// history consistent with the new order (see
/// captureNavigationState/restoreNavigationState in
/// core/domain/playback_engine_port.dart, and the several rounds of
/// review this file's queue-navigation logic already went through) —
/// deferred rather than bolted on here.
///
/// The current track is matched by value, not position: `PlaybackState`
/// only exposes `currentTrack`, not the engine's `currentIndex` (see
/// app/playback_controller.dart's doc comment on why the engine, not the
/// controller, owns queue position). A queue with the same track
/// appearing more than once would highlight every matching row instead
/// of just the one actually playing — not solved here.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playbackControllerProvider.notifier);
    final playback = ref.watch(playbackControllerProvider).playback;
    final queue = playback.queue;

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: const ScreenTopBar(title: 'Queue'),
      body: queue.isEmpty
          ? const Center(
              child: Text(
                'Queue is empty',
                style: TextStyle(fontSize: 12, color: AppColors.mist),
              ),
            )
          : ListView(
              children: [
                for (final (index, track) in queue.indexed)
                  TrackRow(
                    title: track.title,
                    subtitle: track.artist,
                    onTap: () =>
                        controller.play(track, queue: queue, queueIndex: index),
                    trailing: track == playback.currentTrack
                        ? const Icon(
                            Icons.graphic_eq,
                            size: 16,
                            color: AppColors.willow,
                          )
                        : null,
                  ),
              ],
            ),
    );
  }
}
