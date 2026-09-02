import 'package:test/test.dart';
import 'package:ophelia/core/usecases/seek_by.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('seeks forward relative to the current position', () async {
    final playback = FakePlaybackEnginePort();
    final seekBy = SeekBy(playback);

    unwrapValue(
      await seekBy(
        currentPosition: const Duration(seconds: 30),
        offset: const Duration(seconds: 10),
      ),
    );

    expect(playback.position, const Duration(seconds: 40));
  });

  test('clamps to zero when seeking before the start', () async {
    final playback = FakePlaybackEnginePort();
    final seekBy = SeekBy(playback);

    unwrapValue(
      await seekBy(
        currentPosition: const Duration(seconds: 5),
        offset: const Duration(seconds: -20),
      ),
    );

    expect(playback.position, Duration.zero);
  });
}
