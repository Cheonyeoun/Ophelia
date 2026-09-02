import 'package:test/test.dart';
import 'package:ophelia/core/usecases/pause_track.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('pauses playback', () async {
    final playback = FakePlaybackEnginePort()..isPlaying = true;
    final pauseTrack = PauseTrack(playback);

    unwrapValue(await pauseTrack());

    expect(playback.isPlaying, isFalse);
  });
}
