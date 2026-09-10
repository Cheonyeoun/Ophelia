import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/core/domain/playback_engine_port.dart';
import 'package:ophelia/core/domain/playback_session_snapshot.dart';
import 'package:ophelia/core/domain/playback_state.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/error/result.dart';
import 'package:ophelia/data/fakes/fake_local_file_source_port.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';
import 'package:ophelia/features/playback_ui/playback_controller.dart';

import '../../support/result_test_helpers.dart';

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

  /// Held open (if given) until [skipGate] completes, before delegating
  /// -- simulates a skip's real, non-trivial round trip (resolving a new
  /// source, handing it to the real decoder) so a test can fire a second
  /// skip while the first is still "in flight."
  final Completer<void>? skipGate;
  int skipNextCallCount = 0;

  _GatedEngine(this.inner, this.playGate, this.callOrder, {this.skipGate});

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
  Future<Result<void, Failure>> seek(Duration position) => inner.seek(position);

  @override
  Future<Result<Track, Failure>> skipNext() async {
    skipNextCallCount++;
    if (skipGate != null) await skipGate!.future;
    return inner.skipNext();
  }

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
  ) => inner.restoreNavigationState(snapshot);

  @override
  int get currentIndex => inner.currentIndex;

  @override
  Stream<Duration> get positionStream => inner.positionStream;

  @override
  Stream<Duration?> get durationStream => inner.durationStream;
}

/// Covers the fix for rapid double-taps on shuffle/repeat: each tap must
/// compute its target from the *other* tap's result, not from the same
/// stale pre-toggle value both taps happened to read (see
/// playback_controller.dart's toggleShuffle/toggleRepeatMode) -- and,
/// structurally, the mutex in playback_controller.dart that now
/// serializes every playback-mutating method against every other one.
void main() {
  test('two rapid shuffle taps each toggle from the other\'s result, landing '
      'back on the original value', () async {
    final container = ProviderContainer(
      overrides: [
        playbackEngineProvider.overrideWithValue(FakePlaybackEnginePort()),
        localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
      ],
    );
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
  });

  test('two rapid repeat-mode taps each advance the cycle once, not twice '
      'from the same value', () async {
    final container = ProviderContainer(
      overrides: [
        playbackEngineProvider.overrideWithValue(FakePlaybackEnginePort()),
        localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
      ],
    );
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
  });

  test('play and toggleShuffle fired concurrently are fully serialized -- '
      'toggleShuffle never reaches the engine until play has -- with no '
      'corrupted final state', () async {
    final playGate = Completer<void>();
    final callOrder = <String>[];
    final gatedEngine = _GatedEngine(
      FakePlaybackEnginePort(),
      playGate,
      callOrder,
    );
    final container = ProviderContainer(
      overrides: [
        playbackEngineProvider.overrideWithValue(gatedEngine),
        localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
      ],
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
  });

  test(
    'a skipNext tap that arrives while a previous one is still in flight '
    'is ignored, not queued -- confirmed on a real device against a '
    'queue of real audio files: each skip\'s full round trip is slow '
    'enough that a few impatient taps queued several skips deep before '
    'the first even resolved, making the transport controls look frozen '
    'and then suddenly jump multiple tracks once the backlog drained',
    () async {
      final skipGate = Completer<void>();
      final gatedEngine = _GatedEngine(
        FakePlaybackEnginePort(),
        Completer<void>()..complete(),
        [],
        skipGate: skipGate,
      );
      final container = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(gatedEngine),
          localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
          localLibraryProvider.overrideWithValue(FakeLocalLibraryPort()),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(
        sampleTracks[0],
        queue: sampleTracks,
        queueIndex: 0,
      );

      // First tap starts a skip and blocks inside the engine (via
      // skipGate). Two more arrive while it's still in flight.
      final first = controller.skipNext();
      final second = controller.skipNext();
      final third = controller.skipNext();
      await Future<void>.delayed(Duration.zero);

      skipGate.complete();
      await Future.wait([first, second, third]);

      // Only the first tap ever actually reached the engine -- the
      // other two were ignored outright, not queued behind it.
      expect(gatedEngine.skipNextCallCount, 1);
    },
  );

  group('seek clamping', () {
    test('seekBy never pushes position past the track\'s duration, and the '
        'engine itself stays in sync with the clamped value -- not just '
        'the UI-facing state', () async {
      final engine = FakePlaybackEnginePort();
      final container = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(engine),
          localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      final track = sampleTracks.first;
      await controller.play(track);
      await controller.seekTo(Duration(milliseconds: track.durationMs - 5000));

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
    });

    test('seekBy never pushes position below zero', () async {
      final container = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(FakePlaybackEnginePort()),
          localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(sampleTracks.first);

      await controller.seekBy(const Duration(seconds: -30));

      expect(
        container.read(playbackControllerProvider).playback.position,
        Duration.zero,
      );
    });

    test(
      'seekTo clamps an out-of-range target to within [0, duration]',
      () async {
        final container = ProviderContainer(
          overrides: [
            playbackEngineProvider.overrideWithValue(FakePlaybackEnginePort()),
            localFileSourceProvider.overrideWithValue(
              FakeLocalFileSourcePort(),
            ),
          ],
        );
        addTearDown(container.dispose);
        final controller = container.read(playbackControllerProvider.notifier);
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

    test('seekBy and seekTo both actually move position for a track with an '
        'unknown (durationMs: 0) duration, instead of clamping every seek '
        'straight back to zero -- a local file (no tag reader) always '
        'starts out this way', () async {
      const localTrack = Track(
        id: 'local:/music/song.mp3',
        title: 'Song',
        artist: 'Unknown artist',
        album: 'Music',
        durationMs: 0,
        sourceType: TrackSourceType.local,
      );
      final container = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(FakePlaybackEnginePort()),
          localFileSourceProvider.overrideWithValue(
            FakeLocalFileSourcePort(
              tracksByFolder: const {
                '/music': [localTrack],
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(localTrack);

      await controller.seekBy(const Duration(seconds: 10));
      expect(
        container.read(playbackControllerProvider).playback.position,
        const Duration(seconds: 10),
      );

      await controller.seekTo(const Duration(minutes: 5));
      expect(
        container.read(playbackControllerProvider).playback.position,
        const Duration(minutes: 5),
      );

      // The zero floor still applies -- "unknown" only lifts the upper
      // bound, not the lower one.
      await controller.seekBy(const Duration(hours: -1));
      expect(
        container.read(playbackControllerProvider).playback.position,
        Duration.zero,
      );
    });

    test('a real duration reported by the engine refines currentTrack, '
        'after which seeking is bounded by that real value', () async {
      const localTrack = Track(
        id: 'local:/music/song.mp3',
        title: 'Song',
        artist: 'Unknown artist',
        album: 'Music',
        durationMs: 0,
        sourceType: TrackSourceType.local,
      );
      final engine = FakePlaybackEnginePort();
      final container = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(engine),
          localFileSourceProvider.overrideWithValue(
            FakeLocalFileSourcePort(
              tracksByFolder: const {
                '/music': [localTrack],
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(localTrack);

      engine.emitDuration(const Duration(minutes: 3));
      await Future<void>.delayed(Duration.zero);

      expect(
        container
            .read(playbackControllerProvider)
            .playback
            .currentTrack
            ?.durationMs,
        const Duration(minutes: 3).inMilliseconds,
      );
      // currentTrack and queue[currentIndex] are separate fields (see
      // PlaybackState's own doc comment) -- refining only the former
      // would leave the queue entry `persistSessionSnapshot` actually
      // saves permanently stuck at 0 ("unknown"), silently losing a
      // since-learned real duration across every session restore.
      expect(
        container
            .read(playbackControllerProvider)
            .playback
            .queue[container
                .read(playbackControllerProvider)
                .playback
                .currentIndex]
            .durationMs,
        const Duration(minutes: 3).inMilliseconds,
      );

      await controller.seekTo(const Duration(minutes: 10));
      expect(
        container.read(playbackControllerProvider).playback.position,
        const Duration(minutes: 3),
      );
    });

    test('skipping away from a track and back to it keeps its '
        'previously-learned duration, instead of it regressing to '
        '"unknown" (0) -- reported after skipping between local tracks: '
        'skipNext/skipPrevious resolve from the engine\'s own internal '
        'queue, a separate copy from PlaybackState.queue that duration '
        'refinement never touched', () async {
      const trackA = Track(
        id: 'local:/music/a.mp3',
        title: 'A',
        artist: 'Unknown artist',
        album: 'Music',
        durationMs: 0,
        sourceType: TrackSourceType.local,
      );
      const trackB = Track(
        id: 'local:/music/b.mp3',
        title: 'B',
        artist: 'Unknown artist',
        album: 'Music',
        durationMs: 0,
        sourceType: TrackSourceType.local,
      );
      final engine = FakePlaybackEnginePort();
      final container = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(engine),
          localFileSourceProvider.overrideWithValue(
            FakeLocalFileSourcePort(
              tracksByFolder: {
                '/music': [trackA, trackB],
              },
            ),
          ),
          // SkipNext/SkipPrevious (unlike play) also finalize the
          // outgoing track's listening time via localLibraryProvider --
          // without overriding it, this would hit the real
          // DriftLibraryAdapter/database from a plain unit test.
          localLibraryProvider.overrideWithValue(FakeLocalLibraryPort()),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(trackA, queue: [trackA, trackB], queueIndex: 0);

      await controller.skipNext();
      engine.emitDuration(const Duration(minutes: 4));
      await Future<void>.delayed(Duration.zero);
      expect(
        container
            .read(playbackControllerProvider)
            .playback
            .currentTrack
            ?.durationMs,
        const Duration(minutes: 4).inMilliseconds,
      );

      await controller.skipPrevious();
      await controller.skipNext();

      expect(
        container
            .read(playbackControllerProvider)
            .playback
            .currentTrack
            ?.durationMs,
        const Duration(minutes: 4).inMilliseconds,
      );
    });
  });

  group('session restore', () {
    test('restoreSession populates the mini-player paused at the saved '
        'track/position, without touching the engine', () async {
      final engine = FakePlaybackEnginePort();
      final container = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(engine),
          localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);

      controller.restoreSession(
        PlaybackSessionSnapshot(
          queue: [sampleTracks[0], sampleTracks[1]],
          queueIndex: 1,
          position: const Duration(seconds: 30),
        ),
      );

      final state = container.read(playbackControllerProvider);
      expect(state.playback.currentTrack, sampleTracks[1]);
      expect(state.playback.currentIndex, 1);
      expect(state.playback.position, const Duration(seconds: 30));
      expect(state.isPlaying, isFalse);
      // Nothing was ever loaded into the engine -- see the doc comment
      // on `restoreSession` for why not.
      expect(engine.currentTrack, isNull);
    });

    test('the first togglePlayPause after a restore loads the track fresh and '
        'seeks to the saved position, rather than trying to resume a track '
        'the engine was never given', () async {
      final container = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(FakePlaybackEnginePort()),
          localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      controller.restoreSession(
        PlaybackSessionSnapshot(
          queue: [sampleTracks[0]],
          queueIndex: 0,
          position: const Duration(seconds: 12),
        ),
      );

      await controller.togglePlayPause();

      final state = container.read(playbackControllerProvider);
      expect(state.isPlaying, isTrue);
      expect(state.playback.currentTrack, sampleTracks[0]);
      expect(state.playback.position, const Duration(seconds: 12));
    });

    test('togglePlayPause after a restore, once loaded, behaves like normal '
        'pause/resume from then on', () async {
      final container = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(FakePlaybackEnginePort()),
          localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
          // pause() (via PauseTrack) records a listening event once a
          // session has actually been timed -- see
          // core/usecases/pause_track.dart -- which the real
          // localLibraryProvider can't do here without a real database.
          localLibraryProvider.overrideWithValue(FakeLocalLibraryPort()),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      controller.restoreSession(
        PlaybackSessionSnapshot(
          queue: [sampleTracks[0]],
          queueIndex: 0,
          position: Duration.zero,
        ),
      );
      await controller.togglePlayPause(); // loads + plays

      await controller.togglePlayPause(); // pause
      expect(container.read(playbackControllerProvider).isPlaying, isFalse);

      await controller.togglePlayPause(); // resume, not a fresh load
      expect(container.read(playbackControllerProvider).isPlaying, isTrue);
    });

    test('persistSessionSnapshot saves the current track/queue/position, and '
        'is a no-op with nothing loaded', () async {
      final library = FakeLocalLibraryPort();
      final container = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(FakePlaybackEnginePort()),
          localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
          localLibraryProvider.overrideWithValue(library),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);

      await controller.persistSessionSnapshot();
      expect(unwrapValue(await library.getLastPlaybackState()), isNull);

      await controller.play(sampleTracks.first);
      await controller.persistSessionSnapshot();

      final saved = unwrapValue(await library.getLastPlaybackState());
      expect(saved!.currentTrack, sampleTracks.first);
    });

    test('a duration learned mid-session survives persistSessionSnapshot and '
        'a subsequent restoreSession, instead of coming back as "unknown" '
        '(0) -- caught on a real device: a local track\'s duration, once '
        'refined from the engine\'s durationStream, showed as --:-- again '
        'after force-stopping and relaunching the app', () async {
      const localTrack = Track(
        id: 'local:/music/song.mp3',
        title: 'Song',
        artist: 'Unknown artist',
        album: 'Music',
        durationMs: 0,
        sourceType: TrackSourceType.local,
      );
      final engine = FakePlaybackEnginePort();
      final library = FakeLocalLibraryPort();
      final container = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(engine),
          localFileSourceProvider.overrideWithValue(
            FakeLocalFileSourcePort(
              tracksByFolder: {
                '/music': [localTrack],
              },
            ),
          ),
          localLibraryProvider.overrideWithValue(library),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(playbackControllerProvider.notifier);
      await controller.play(localTrack);
      engine.emitDuration(const Duration(seconds: 2));
      await Future<void>.delayed(Duration.zero);

      await controller.persistSessionSnapshot();

      // A fresh controller/state, the same as a real app relaunch --
      // restoreSession populates state entirely from what was saved.
      final freshContainer = ProviderContainer(
        overrides: [
          playbackEngineProvider.overrideWithValue(FakePlaybackEnginePort()),
          localFileSourceProvider.overrideWithValue(FakeLocalFileSourcePort()),
          localLibraryProvider.overrideWithValue(library),
        ],
      );
      addTearDown(freshContainer.dispose);
      final snapshot = unwrapValue(await library.getLastPlaybackState())!;
      freshContainer
          .read(playbackControllerProvider.notifier)
          .restoreSession(snapshot);

      expect(
        freshContainer
            .read(playbackControllerProvider)
            .playback
            .currentTrack
            ?.durationMs,
        const Duration(seconds: 2).inMilliseconds,
      );
    });
  });
}
