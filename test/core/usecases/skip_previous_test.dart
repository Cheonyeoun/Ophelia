import 'package:test/test.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/usecases/skip_previous.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('goes back to the previous track in the queue', () async {
    final playback = FakePlaybackEnginePort();
    await playback.setQueue(sampleTracks);
    await playback.play(sampleTracks[1], 'src');
    final skipPrevious = SkipPrevious(playback);

    unwrapValue(await skipPrevious());

    expect(playback.currentTrack, sampleTracks[0]);
  });

  test('propagates a failure when already at the start of the queue', () async {
    final playback = FakePlaybackEnginePort();
    await playback.setQueue(sampleTracks);
    await playback.play(sampleTracks.first, 'src');
    final skipPrevious = SkipPrevious(playback);

    final failure = unwrapFailure(await skipPrevious());

    expect(failure, isA<NotFoundFailure>());
  });
}
