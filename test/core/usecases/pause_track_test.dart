import 'package:test/test.dart';
import 'package:ophelia/core/usecases/listening_session.dart';
import 'package:ophelia/core/usecases/pause_track.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('pauses playback', () async {
    final playback = FakePlaybackEnginePort()..isPlaying = true;
    final library = FakeLocalLibraryPort(listeningEvents: []);
    final session = ListeningSession();
    final pauseTrack = PauseTrack(playback, library, session);

    unwrapValue(await pauseTrack());

    expect(playback.isPlaying, isFalse);
  });

  test('records the actual elapsed listening time when pausing', () async {
    var clock = DateTime(2026, 1, 1, 12);
    final playback = FakePlaybackEnginePort();
    final library = FakeLocalLibraryPort(listeningEvents: []);
    final session = ListeningSession(now: () => clock);
    final pauseTrack = PauseTrack(playback, library, session);
    session.start('t1');
    clock = clock.add(const Duration(seconds: 42));

    unwrapValue(await pauseTrack());

    final events = unwrapValue(await library.getListeningEvents());
    expect(events, hasLength(1));
    expect(events.single.trackId, 't1');
    expect(events.single.msPlayed, 42000);
  });

  test('records nothing when no track was being tracked', () async {
    final playback = FakePlaybackEnginePort();
    final library = FakeLocalLibraryPort(listeningEvents: []);
    final session = ListeningSession();
    final pauseTrack = PauseTrack(playback, library, session);

    unwrapValue(await pauseTrack());

    final events = unwrapValue(await library.getListeningEvents());
    expect(events, isEmpty);
  });
}
