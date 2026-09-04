import 'package:test/test.dart';
import 'package:ophelia/core/domain/playback_engine_port.dart';
import 'package:ophelia/core/domain/playback_state.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/error/result.dart';
import 'package:ophelia/core/usecases/listening_session.dart';
import 'package:ophelia/core/usecases/play_track.dart';
import 'package:ophelia/data/fakes/fake_download_port.dart';
import 'package:ophelia/data/fakes/fake_media_source_port.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

/// Wraps a [FakePlaybackEnginePort], but always fails [play] — lets a test
/// exercise `PlayTrack`'s rollback path (restoring the engine's prior
/// navigation state when `play` fails after `setQueue` already succeeded)
/// without needing a real engine that can actually fail to play
/// something. If [failRestore] is set, [restoreNavigationState] fails
/// too, so a test can exercise `PlayTrack`'s handling of a rollback that
/// itself doesn't succeed.
class _PlayFailingEngine implements PlaybackEnginePort {
  final FakePlaybackEnginePort inner;
  final bool failRestore;

  _PlayFailingEngine(this.inner, {this.failRestore = false});

  @override
  Future<Result<void, Failure>> play(
    Track track,
    String sourcePath, {
    int queueIndex = 0,
  }) async {
    return Result.failure(const StorageFailure('engine rejected play'));
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
  Future<Result<void, Failure>> setShuffle(bool enabled) =>
      inner.setShuffle(enabled);

  @override
  Future<Result<void, Failure>> setRepeatMode(RepeatMode repeatMode) =>
      inner.setRepeatMode(repeatMode);

  @override
  PlaybackNavigationSnapshot captureNavigationState() =>
      inner.captureNavigationState();

  @override
  Future<Result<void, Failure>> restoreNavigationState(
    PlaybackNavigationSnapshot snapshot,
  ) async {
    if (failRestore) {
      return Result.failure(const StorageFailure('engine rejected restore'));
    }
    return inner.restoreNavigationState(snapshot);
  }
}

void main() {
  late FakePlaybackEnginePort playback;
  late FakeMediaSourcePort mediaSource;
  late FakeDownloadPort downloads;
  late ListeningSession session;
  late PlayTrack playTrack;

  setUp(() {
    playback = FakePlaybackEnginePort();
    mediaSource = FakeMediaSourcePort();
    downloads = FakeDownloadPort(seed: []);
    session = ListeningSession();
    playTrack = PlayTrack(playback, mediaSource, downloads, session);
  });

  test('plays a downloaded track from its local path', () async {
    final track = sampleTracks.first;
    await downloads.download(track);

    unwrapValue(await playTrack(track));

    expect(playback.currentTrack, track);
    expect(playback.currentSourcePath, '/downloads/${track.id}.mp3');
  });

  test('streams a track that has not been downloaded', () async {
    final track = sampleTracks[2];

    unwrapValue(await playTrack(track));

    expect(playback.currentTrack, track);
    expect(
      playback.currentSourcePath,
      'https://stream.ophelia.fake/${track.id}',
    );
  });

  test(
    'sets the engine queue to the given queue, positioned at the given '
    'queueIndex',
    () async {
      final queue = [sampleTracks[0], sampleTracks[1], sampleTracks[2]];

      unwrapValue(
        await playTrack(sampleTracks[1], queue: queue, queueIndex: 1),
      );

      expect(playback.queue, queue);
      expect(playback.currentIndex, 1);
    },
  );

  test(
    'defaults the engine queue to just the played track when none is given',
    () async {
      final track = sampleTracks.first;

      unwrapValue(await playTrack(track));

      expect(playback.queue, [track]);
      expect(playback.currentIndex, 0);
    },
  );

  test('starts tracking a listening session for the played track', () async {
    final track = sampleTracks.first;

    unwrapValue(await playTrack(track));

    final event = session.finish();
    expect(event, isNotNull);
    expect(event!.trackId, track.id);
  });

  test(
    'never commits a queue to the engine when the track cannot be sourced',
    () async {
      final failingSourceMediaSource = FakeMediaSourcePort(tracks: const []);
      final playTrackWithFailingSource = PlayTrack(
        playback,
        failingSourceMediaSource,
        downloads,
        session,
      );
      final priorQueue = [sampleTracks[3], sampleTracks[4]];
      await playback.setQueue(priorQueue);

      final failure = unwrapFailure(
        await playTrackWithFailingSource(
          sampleTracks[0],
          queue: [sampleTracks[0], sampleTracks[1]],
        ),
      );

      expect(failure, isA<NotFoundFailure>());
      expect(playback.queue, priorQueue);
    },
  );

  test(
    'restores the engine\'s full prior navigation state -- current track, '
    'index, and shuffle history, not just the queue -- when play itself '
    'fails after the queue was already committed',
    () async {
      // Build up real navigation state (not just a queue) to prove it's
      // all restored together: play, enable shuffle, and skip once so
      // there's shuffle history a fresh setQueue would otherwise wipe.
      await playback.setQueue(sampleTracks);
      await playback.play(sampleTracks[0], 'src');
      await playback.setShuffle(true);
      final priorTrack = unwrapValue(await playback.skipNext());
      final priorIndex = playback.currentIndex;

      final failingEngine = _PlayFailingEngine(playback);
      final playTrackWithFailingEngine = PlayTrack(
        failingEngine,
        mediaSource,
        downloads,
        session,
      );

      final failure = unwrapFailure(
        await playTrackWithFailingEngine(
          sampleTracks[3],
          queue: [sampleTracks[3], sampleTracks[4]],
        ),
      );

      expect(failure, isA<StorageFailure>());
      // The engine briefly had the new queue committed (play() needs it
      // set to position itself) but PlayTrack rolled the whole snapshot
      // back once play failed -- not just the queue.
      expect(playback.currentTrack, priorTrack);
      expect(playback.currentIndex, priorIndex);
      expect(playback.queue, sampleTracks);
      // If shuffle history hadn't been restored too (a fresh setQueue
      // resets it to a single-entry round), this would fail instead of
      // undoing the shuffle pick made above.
      final back = unwrapValue(await playback.skipPrevious());
      expect(back, sampleTracks[0]);
    },
  );

  test(
    'surfaces an EngineInconsistentFailure, wrapping both failures, when '
    'the rollback after a failed play itself fails',
    () async {
      await playback.setQueue(sampleTracks);
      await playback.play(sampleTracks[0], 'src');

      final failingEngine = _PlayFailingEngine(playback, failRestore: true);
      final playTrackWithFailingEngine = PlayTrack(
        failingEngine,
        mediaSource,
        downloads,
        session,
      );

      final failure = unwrapFailure(
        await playTrackWithFailingEngine(
          sampleTracks[3],
          queue: [sampleTracks[3], sampleTracks[4]],
        ),
      );

      // Discarding the rollback's own failure would hide that the engine
      // may now be lying about its state -- it must show up in what's
      // returned, not just the original play failure.
      final inconsistent = failure as EngineInconsistentFailure;
      expect(inconsistent.cause, isA<StorageFailure>());
      expect(inconsistent.rollbackFailure, isA<StorageFailure>());
    },
  );

  test(
    'propagates a failure when the track is unknown to the media source',
    () async {
      const unknownTrack = Track(
        id: 'unknown',
        title: 'Unknown',
        artist: 'Nobody',
        album: 'Nowhere',
        durationMs: 1000,
        sourceType: TrackSourceType.streamed,
      );

      final failure = unwrapFailure(await playTrack(unknownTrack));

      expect(failure, isA<NotFoundFailure>());
    },
  );
}
