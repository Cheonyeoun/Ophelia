import 'package:test/test.dart';
import 'package:ophelia/core/usecases/listening_session.dart';
import 'package:ophelia/core/usecases/resume_track.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('resumes playback', () async {
    final playback = FakePlaybackEnginePort()..isPlaying = false;
    final session = ListeningSession();
    final resumeTrack = ResumeTrack(playback, session);

    unwrapValue(await resumeTrack(sampleTracks.first));

    expect(playback.isPlaying, isTrue);
  });

  test('starts tracking a listening session for the resumed track', () async {
    final playback = FakePlaybackEnginePort();
    final session = ListeningSession();
    final resumeTrack = ResumeTrack(playback, session);

    unwrapValue(await resumeTrack(sampleTracks.first));

    final event = session.finish();
    expect(event, isNotNull);
    expect(event!.trackId, sampleTracks.first.id);
  });

  test(
    'preserves the queue and shuffle history built up before the pause, '
    'unlike re-entering PlayTrack would',
    () async {
      final playback = FakePlaybackEnginePort();
      await playback.setQueue(sampleTracks);
      await playback.play(sampleTracks[0], 'src');
      await playback.setShuffle(true);
      unwrapValue(await playback.skipNext());
      await playback.pause();

      final queueBefore = playback.queue;
      final currentTrackBefore = playback.currentTrack;
      final session = ListeningSession();
      final resumeTrack = ResumeTrack(playback, session);

      unwrapValue(await resumeTrack(currentTrackBefore!));

      expect(playback.queue, queueBefore);
      expect(playback.currentTrack, currentTrackBefore);
      // A fresh setQueue() (what re-entering PlayTrack on resume used to
      // do) resets shuffle history to a single-entry round, so undoing
      // the skip above would no longer be possible.
      unwrapValue(await playback.skipPrevious());
    },
  );
}
