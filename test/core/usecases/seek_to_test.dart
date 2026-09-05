import 'package:test/test.dart';
import 'package:ophelia/core/usecases/seek_to.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('seeks directly to the absolute target position', () async {
    final playback = FakePlaybackEnginePort();
    final seekTo = SeekTo(playback);

    unwrapValue(await seekTo(const Duration(seconds: 42)));

    expect(playback.position, const Duration(seconds: 42));
  });

  test('clamps a negative target to zero', () async {
    final playback = FakePlaybackEnginePort();
    final seekTo = SeekTo(playback);

    unwrapValue(await seekTo(const Duration(seconds: -5)));

    expect(playback.position, Duration.zero);
  });
}
