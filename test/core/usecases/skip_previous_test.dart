import 'package:test/test.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/usecases/listening_session.dart';
import 'package:ophelia/core/usecases/skip_previous.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  late FakePlaybackEnginePort playback;
  late FakeLocalLibraryPort library;
  late ListeningSession session;
  late SkipPrevious skipPrevious;

  setUp(() async {
    playback = FakePlaybackEnginePort();
    library = FakeLocalLibraryPort(listeningEvents: []);
    session = ListeningSession();
    skipPrevious = SkipPrevious(playback, library, session);
    await playback.setQueue(sampleTracks);
    await playback.play(sampleTracks[0], 'src');
  });

  test('goes back to the previous track in the queue', () async {
    await playback.skipNext();

    unwrapValue(await skipPrevious(sampleTracks[0]));

    expect(playback.currentTrack, sampleTracks[0]);
  });

  test('propagates a failure when already at the start of the queue', () async {
    final failure = unwrapFailure(await skipPrevious(sampleTracks[0]));

    expect(failure, isA<NotFoundFailure>());
  });

  test('starts tracking the new current track after skipping back', () async {
    await playback.skipNext();

    unwrapValue(await skipPrevious(sampleTracks[0]));

    final event = session.finish();
    expect(event, isNotNull);
    expect(event!.trackId, sampleTracks[0].id);
  });

  test(
    'finalizes the outgoing track with its real elapsed listening time',
    () async {
      await playback.skipNext();
      var clock = DateTime(2026, 1, 1, 12);
      final trackedSession = ListeningSession(now: () => clock);
      final trackedSkipPrevious =
          SkipPrevious(playback, library, trackedSession);
      trackedSession.start(sampleTracks[1].id);
      clock = clock.add(const Duration(seconds: 9));

      unwrapValue(await trackedSkipPrevious(sampleTracks[0]));

      final events = unwrapValue(await library.getListeningEvents());
      expect(events, hasLength(1));
      expect(events.single.trackId, sampleTracks[1].id);
      expect(events.single.msPlayed, 9000);
    },
  );
}
