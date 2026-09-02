import 'package:test/test.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/usecases/skip_next.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('advances to the next track in the queue', () async {
    final playback = FakePlaybackEnginePort();
    await playback.setQueue(sampleTracks);
    await playback.play(sampleTracks[0], 'src');
    final skipNext = SkipNext(playback);

    unwrapValue(await skipNext());

    expect(playback.currentTrack, sampleTracks[1]);
  });

  test('propagates a failure when already at the end of the queue', () async {
    final playback = FakePlaybackEnginePort();
    await playback.setQueue(sampleTracks);
    await playback.play(sampleTracks.last, 'src');
    final skipNext = SkipNext(playback);

    final failure = unwrapFailure(await skipNext());

    expect(failure, isA<NotFoundFailure>());
  });
}
