import 'package:test/test.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('setQueue positions currentIndex at the start of the new queue', () async {
    final playback = FakePlaybackEnginePort();

    unwrapValue(await playback.setQueue(sampleTracks));

    expect(playback.currentIndex, 0);
  });

  test(
    'navigates by queue position, unaffected by duplicate tracks in the '
    'queue',
    () async {
      final playback = FakePlaybackEnginePort();
      final duplicateQueue = [
        sampleTracks[0],
        sampleTracks[1],
        sampleTracks[0],
      ];
      await playback.setQueue(duplicateQueue);
      await playback.play(duplicateQueue[0], 'src');

      unwrapValue(await playback.skipNext());
      expect(playback.currentIndex, 1);
      expect(playback.currentTrack, duplicateQueue[1]);

      unwrapValue(await playback.skipNext());
      expect(playback.currentIndex, 2);
      expect(playback.currentTrack, duplicateQueue[2]);

      // currentTrack (sampleTracks[0]) also appears earlier in the queue
      // with a track after it — if navigation re-derived position by
      // matching the track instead of using currentIndex, this could
      // wrongly report a next track instead of failing here.
      final failure = unwrapFailure(await playback.skipNext());
      expect(failure, isA<NotFoundFailure>());
    },
  );

  test(
    'positions currentIndex from the caller-supplied queueIndex, not a '
    'value-equality search, when the played track appears more than once '
    'in the queue',
    () async {
      final playback = FakePlaybackEnginePort();
      final duplicateQueue = [
        sampleTracks[0],
        sampleTracks[1],
        sampleTracks[0],
      ];
      await playback.setQueue(duplicateQueue);

      // Play the second (later) occurrence explicitly. A value-equality
      // search (queue.indexOf) would always find the first occurrence
      // (index 0) instead, regardless of which one was actually played.
      unwrapValue(
        await playback.play(duplicateQueue[2], 'src', queueIndex: 2),
      );
      expect(playback.currentIndex, 2);

      unwrapValue(await playback.skipPrevious());
      expect(playback.currentIndex, 1);
      expect(playback.currentTrack, duplicateQueue[1]);
    },
  );

  test(
    'keeps currentSourcePath consistent with currentTrack after skipping '
    'forward',
    () async {
      final playback = FakePlaybackEnginePort();
      await playback.setQueue(sampleTracks);
      await playback.play(sampleTracks[0], 'original-source');

      unwrapValue(await playback.skipNext());

      expect(playback.currentTrack, sampleTracks[1]);
      expect(playback.currentSourcePath, isNot('original-source'));
      expect(playback.currentSourcePath, contains(sampleTracks[1].id));
    },
  );

  test(
    'keeps currentSourcePath consistent with currentTrack after skipping '
    'backward',
    () async {
      final playback = FakePlaybackEnginePort();
      await playback.setQueue(sampleTracks);
      await playback.play(sampleTracks[0], 'src');
      await playback.skipNext();

      unwrapValue(await playback.skipPrevious());

      expect(playback.currentTrack, sampleTracks[0]);
      expect(playback.currentSourcePath, contains(sampleTracks[0].id));
    },
  );
}
