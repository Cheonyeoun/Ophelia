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

/// Wraps a [FakePlaybackEnginePort], but holds [play] open until
/// [playGate] completes, and records each call it forwards to [inner] (in
/// arrival order) into [callOrder]. Lets a test prove
/// [PlaybackController]'s mutex actually serializes two different
/// methods: if `toggleShuffle`'s `setShuffle` call showed up in
/// [callOrder] before `play`'s gate was released, the controller would be
/// letting the two interleave instead of queuing one behind the other.
class _GatedEngine implements PlaybackEnginePort {
  final FakePlaybackEnginePort inner;
  final Completer<void> playGate;
  final List<String> callOrder;

  _GatedEngine(this.inner, this.playGate, this.callOrder);

  @override
  Future<Result<void, Failure>> play(
    Track track,
    String sourcePath, {
    int queueIndex = 0,
  }) async {
    await playGate.future;
    callOrder.add('play');
    return inner.play(track, sourcePath, queueIndex: queueIndex);
  }

  @override
  Future<Result<void, Failure>> setShuffle(bool enabled) async {
    callOrder.add('setShuffle');
    return inner.setShuffle(enabled);
  }

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

  @override
  int get currentIndex => inner.currentIndex;
}

/// Covers the fix for rapid double-taps on shuffle/repeat: each tap must
/// compute its target from the *other* tap's result, not from the same
/// stale pre-toggle value both taps happened to read (see
/// playback_controller.dart's toggleShuffle/toggleRepeatMode) -- and,
/// structurally, the mutex in playback_controller.dart that now
/// serializes every playback-mutating method against every other one.
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
    'play and toggleShuffle fired concurrently are fully serialized -- '
    'toggleShuffle never reaches the engine until play has -- with no '
    'corrupted final state',
    () async {
      final playGate = Completer<void>();
      final callOrder = <String>[];
      final gatedEngine = _GatedEngine(
        FakePlaybackEnginePort(),
        playGate,
        callOrder,
      );
      final container = ProviderContainer(
        overrides: [playbackEngineProvider.overrideWithValue(gatedEngine)],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);

      // play() is called first and immediately blocks inside the engine's
      // play() (via playGate). toggleShuffle() is called second, while
      // play() is still in flight.
      final playFuture = controller.play(
        sampleTracks[0],
        queue: sampleTracks,
        queueIndex: 0,
      );
      final toggleFuture = controller.toggleShuffle();

      // The mutex means toggleShuffle's whole body -- including its call
      // to setShuffle -- can't even start until play's action finishes,
      // which can't happen until playGate is released. So at this point,
      // regardless of how many microtasks have run, setShuffle cannot
      // have been called yet.
      await Future<void>.delayed(Duration.zero);
      expect(callOrder, isEmpty);

      playGate.complete();
      await Future.wait([playFuture, toggleFuture]);

      // Both calls landed, strictly in the order they were made.
      expect(callOrder, ['play', 'setShuffle']);
      final playback = container.read(playbackControllerProvider).playback;
      expect(playback.currentTrack, sampleTracks[0]);
      expect(playback.queue, sampleTracks);
      expect(playback.shuffle, isTrue);
    },
  );

  group('seek clamping', () {
    test(
      'seekBy never pushes position past the track\'s duration, and the '
      'engine itself stays in sync with the clamped value -- not just '
      'the UI-facing state',
      () async {
        final engine = FakePlaybackEnginePort();
        final container = ProviderContainer(
          overrides: [playbackEngineProvider.overrideWithValue(engine)],
        );
        addTearDown(container.dispose);
        final controller = container.read(
          playbackControllerProvider.notifier,
        );
        final track = sampleTracks.first;
        await controller.play(track);
        await controller.seekTo(
          Duration(milliseconds: track.durationMs - 5000),
        );

        // Push forward by far more than what's left in the track.
        await controller.seekBy(const Duration(seconds: 30));

        final expected = Duration(milliseconds: track.durationMs);
        expect(
          container.read(playbackControllerProvider).playback.position,
          expected,
        );
        // The engine receives the offset directly (see SeekBy) -- if the
        // controller clamped only the UI-facing state and not the offset
        // actually sent, the engine's own position would silently drift
        // past the track's end even though the UI showed a sane value.
        expect(engine.position, expected);
      },
    );

    test(
      'seekBy never pushes position below zero',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final controller = container.read(
          playbackControllerProvider.notifier,
        );
        await controller.play(sampleTracks.first);

        await controller.seekBy(const Duration(seconds: -30));

        expect(
          container.read(playbackControllerProvider).playback.position,
          Duration.zero,
        );
      },
    );

    test(
      'seekTo clamps an out-of-range target to within [0, duration]',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final controller = container.read(
          playbackControllerProvider.notifier,
        );
        final track = sampleTracks.first;
        await controller.play(track);

        await controller.seekTo(
          Duration(milliseconds: track.durationMs + 60000),
        );
        expect(
          container.read(playbackControllerProvider).playback.position,
          Duration(milliseconds: track.durationMs),
        );

        await controller.seekTo(const Duration(seconds: -30));
        expect(
          container.read(playbackControllerProvider).playback.position,
          Duration.zero,
        );
      },
    );
  });
}
