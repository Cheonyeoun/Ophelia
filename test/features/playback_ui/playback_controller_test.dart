import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/core/domain/playback_engine_port.dart';
import 'package:ophelia/core/domain/playback_state.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/error/result.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';
import 'package:ophelia/features/playback_ui/playback_controller.dart';

/// Wraps a [FakePlaybackEnginePort], but always fails [setShuffle] --
/// only once [readyToFail] completes, so a test can force a toggle's
/// engine call to still be pending while a *different* concurrent
/// operation (e.g. a skip) runs to completion, then let the toggle fail
/// afterward on a schedule the test controls instead of hoping for a
/// particular microtask interleaving.
class _ShuffleSetFailingEngine implements PlaybackEnginePort {
  final FakePlaybackEnginePort inner;
  final Completer<void> readyToFail;

  _ShuffleSetFailingEngine(this.inner, this.readyToFail);

  @override
  Future<Result<void, Failure>> setShuffle(bool enabled) async {
    await readyToFail.future;
    return Result.failure(const StorageFailure('shuffle rejected'));
  }

  @override
  Future<Result<void, Failure>> play(
    Track track,
    String sourcePath, {
    int queueIndex = 0,
  }) =>
      inner.play(track, sourcePath, queueIndex: queueIndex);

  @override
  Future<Result<void, Failure>> resume() => inner.resume();

  @override
  Future<Result<void, Failure>> pause() => inner.pause();

  @override
  Future<Result<void, Failure>> seek(Duration position) =>
      inner.seek(position);

  @override
  Future<Result<Track, Failure>> skipNext() => inner.skipNext();

  @override
  Future<Result<Track, Failure>> skipPrevious() => inner.skipPrevious();

  @override
  Future<Result<void, Failure>> setQueue(List<Track> tracks) =>
      inner.setQueue(tracks);

  @override
  Future<Result<void, Failure>> setRepeatMode(RepeatMode repeatMode) =>
      inner.setRepeatMode(repeatMode);

  @override
  PlaybackNavigationSnapshot captureNavigationState() =>
      inner.captureNavigationState();

  @override
  Future<Result<void, Failure>> restoreNavigationState(
    PlaybackNavigationSnapshot snapshot,
  ) =>
      inner.restoreNavigationState(snapshot);
}

/// Covers the fix for rapid double-taps on shuffle/repeat: each tap must
/// compute its target from the *other* tap's result, not from the same
/// stale pre-toggle value both taps happened to read (see
/// playback_controller.dart's toggleShuffle/toggleRepeatMode).
void main() {
  test(
    'two rapid shuffle taps each toggle from the other\'s result, landing '
    'back on the original value',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(sampleTracks.first);
      expect(
        container.read(playbackControllerProvider).playback.shuffle,
        isFalse,
      );

      final first = controller.toggleShuffle();
      final second = controller.toggleShuffle();
      await Future.wait([first, second]);

      // Two toggles from false should land back on false. If both taps
      // had read the same stale pre-toggle value, they'd both flip to
      // true and the later one to resolve would leave it stuck there.
      expect(
        container.read(playbackControllerProvider).playback.shuffle,
        isFalse,
      );
    },
  );

  test(
    'two rapid repeat-mode taps each advance the cycle once, not twice '
    'from the same value',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(sampleTracks.first);
      expect(
        container.read(playbackControllerProvider).playback.repeatMode,
        RepeatMode.off,
      );

      final first = controller.toggleRepeatMode();
      final second = controller.toggleRepeatMode();
      await Future.wait([first, second]);

      // off -> all -> one: two taps should land on `one`. If both taps
      // had read the same stale `off` value, they'd both compute `all`.
      expect(
        container.read(playbackControllerProvider).playback.repeatMode,
        RepeatMode.one,
      );
    },
  );

  test(
    'a toggle failure only reverts its own field, preserving a skip that '
    'completed on the live state while the toggle was still awaiting the '
    'engine',
    () async {
      final readyToFail = Completer<void>();
      final failingEngine = _ShuffleSetFailingEngine(
        FakePlaybackEnginePort(),
        readyToFail,
      );
      final container = ProviderContainer(
        overrides: [playbackEngineProvider.overrideWithValue(failingEngine)],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(
        sampleTracks[0],
        queue: sampleTracks,
        queueIndex: 0,
      );

      // Start the toggle -- it optimistically flips `shuffle` right away,
      // then suspends awaiting the engine call, which won't resolve until
      // `readyToFail` completes below.
      final toggle = controller.toggleShuffle();
      // Let a *different* state change fully land on the live state while
      // the toggle is still pending.
      await controller.skipNext();
      expect(
        container.read(playbackControllerProvider).playback.currentTrack,
        sampleTracks[1],
      );

      // Now let the toggle's engine call fail, and its failure handler
      // run -- after the skip above already completed.
      readyToFail.complete();
      await toggle;

      final playback = container.read(playbackControllerProvider).playback;
      // The failed toggle must only revert `shuffle` -- restoring the
      // whole pre-toggle snapshot would clobber the skip's currentTrack
      // update with the track that was playing before the toggle started.
      expect(playback.currentTrack, sampleTracks[1]);
      expect(playback.shuffle, isFalse);
    },
  );
}
