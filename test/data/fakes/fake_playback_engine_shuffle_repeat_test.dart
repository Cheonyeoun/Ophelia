import 'dart:math';

import 'package:test/test.dart';
import 'package:ophelia/core/domain/playback_state.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  group('repeat mode', () {
    test('RepeatMode.one keeps skipNext on the current track', () async {
      final playback = FakePlaybackEnginePort();
      await playback.setQueue(sampleTracks);
      await playback.play(sampleTracks[0], 'src');
      await playback.setRepeatMode(RepeatMode.one);

      final track = unwrapValue(await playback.skipNext());

      expect(track, sampleTracks[0]);
      expect(playback.currentIndex, 0);
    });

    test('RepeatMode.one keeps skipPrevious on the current track', () async {
      final playback = FakePlaybackEnginePort();
      await playback.setQueue(sampleTracks);
      await playback.play(sampleTracks[2], 'src', queueIndex: 2);
      await playback.setRepeatMode(RepeatMode.one);

      final track = unwrapValue(await playback.skipPrevious());

      expect(track, sampleTracks[2]);
      expect(playback.currentIndex, 2);
    });

    test(
      'RepeatMode.all loops from the last track back to the first on '
      'skipNext',
      () async {
        final playback = FakePlaybackEnginePort();
        await playback.setQueue(sampleTracks);
        await playback.play(
          sampleTracks.last,
          'src',
          queueIndex: sampleTracks.length - 1,
        );
        await playback.setRepeatMode(RepeatMode.all);

        final track = unwrapValue(await playback.skipNext());

        expect(track, sampleTracks.first);
        expect(playback.currentIndex, 0);
      },
    );

    test(
      'RepeatMode.all loops from the first track back to the last on '
      'skipPrevious',
      () async {
        final playback = FakePlaybackEnginePort();
        await playback.setQueue(sampleTracks);
        await playback.play(sampleTracks.first, 'src');
        await playback.setRepeatMode(RepeatMode.all);

        final track = unwrapValue(await playback.skipPrevious());

        expect(track, sampleTracks.last);
        expect(playback.currentIndex, sampleTracks.length - 1);
      },
    );

    test('RepeatMode.off still fails at the end of the queue', () async {
      final playback = FakePlaybackEnginePort();
      await playback.setQueue(sampleTracks);
      await playback.play(
        sampleTracks.last,
        'src',
        queueIndex: sampleTracks.length - 1,
      );

      final failure = unwrapFailure(await playback.skipNext());

      expect(failure, isA<NotFoundFailure>());
    });
  });

  group('shuffle', () {
    test(
      'visits every track exactly once before repeating, with repeat off',
      () async {
        final playback = FakePlaybackEnginePort(random: Random(7));
        await playback.setQueue(sampleTracks);
        await playback.play(sampleTracks[0], 'src');
        await playback.setShuffle(true);

        final visited = <String>{sampleTracks[0].id};
        for (var i = 0; i < sampleTracks.length - 1; i++) {
          final track = unwrapValue(await playback.skipNext());
          expect(
            visited.contains(track.id),
            isFalse,
            reason: 'should not repeat before exhausting the queue',
          );
          visited.add(track.id);
        }
        expect(visited.length, sampleTracks.length);

        // Every track has now been visited; repeat is off by default.
        final failure = unwrapFailure(await playback.skipNext());
        expect(failure, isA<NotFoundFailure>());
      },
    );

    test(
      'reshuffles and keeps going once exhausted, with repeat all',
      () async {
        final playback = FakePlaybackEnginePort(random: Random(3));
        await playback.setQueue(sampleTracks);
        await playback.play(sampleTracks[0], 'src');
        await playback.setShuffle(true);
        await playback.setRepeatMode(RepeatMode.all);

        for (var i = 0; i < sampleTracks.length - 1; i++) {
          unwrapValue(await playback.skipNext());
        }

        final track = unwrapValue(await playback.skipNext());
        expect(sampleTracks.map((t) => t.id), contains(track.id));
      },
    );

    test('skipPrevious undoes the last shuffle pick', () async {
      final playback = FakePlaybackEnginePort(random: Random(11));
      await playback.setQueue(sampleTracks);
      await playback.play(sampleTracks[0], 'src');
      await playback.setShuffle(true);

      final first = unwrapValue(await playback.skipNext());
      final second = unwrapValue(await playback.skipNext());
      expect(second, isNot(first));

      final back = unwrapValue(await playback.skipPrevious());

      expect(back, first);
    });

    test(
      'skipPrevious fails once back at the track shuffle started from',
      () async {
        final playback = FakePlaybackEnginePort(random: Random(5));
        await playback.setQueue(sampleTracks);
        await playback.play(sampleTracks[0], 'src');
        await playback.setShuffle(true);

        final failure = unwrapFailure(await playback.skipPrevious());

        expect(failure, isA<NotFoundFailure>());
      },
    );
  });

  group('resume', () {
    test(
      'leaves the queue, position, and shuffle history untouched, unlike '
      'play',
      () async {
        final playback = FakePlaybackEnginePort(random: Random(9));
        await playback.setQueue(sampleTracks);
        await playback.play(sampleTracks[0], 'src');
        await playback.setShuffle(true);
        final firstShufflePick = unwrapValue(await playback.skipNext());
        await playback.pause();

        unwrapValue(await playback.resume());

        expect(playback.isPlaying, isTrue);
        expect(playback.queue, sampleTracks);
        expect(playback.currentTrack, firstShufflePick);
        // If resume had reset shuffle history the way play() does,
        // skipPrevious would fail here instead of undoing the pick above.
        final back = unwrapValue(await playback.skipPrevious());
        expect(back, sampleTracks[0]);
      },
    );
  });
}
