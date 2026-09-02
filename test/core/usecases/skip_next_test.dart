import 'package:test/test.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/usecases/listening_session.dart';
import 'package:ophelia/core/usecases/skip_next.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  late FakePlaybackEnginePort playback;
  late FakeLocalLibraryPort library;
  late ListeningSession session;
  late SkipNext skipNext;

  setUp(() async {
    playback = FakePlaybackEnginePort();
    library = FakeLocalLibraryPort(listeningEvents: []);
    session = ListeningSession();
    skipNext = SkipNext(playback, library, session);
    await playback.setQueue(sampleTracks);
    await playback.play(sampleTracks[0], 'src');
  });

  test('advances to the next track in the queue', () async {
    unwrapValue(await skipNext(sampleTracks[1]));

    expect(playback.currentTrack, sampleTracks[1]);
  });

  test('propagates a failure when already at the end of the queue', () async {
    for (var i = 1; i < sampleTracks.length; i++) {
      unwrapValue(await skipNext(sampleTracks[i]));
    }

    final failure = unwrapFailure(await skipNext(sampleTracks[0]));

    expect(failure, isA<NotFoundFailure>());
  });

  test('starts tracking the new current track after skipping', () async {
    unwrapValue(await skipNext(sampleTracks[1]));

    final event = session.finish();
    expect(event, isNotNull);
    expect(event!.trackId, sampleTracks[1].id);
  });

  test(
    'finalizes the outgoing track with its real elapsed listening time',
    () async {
      var clock = DateTime(2026, 1, 1, 12);
      final trackedSession = ListeningSession(now: () => clock);
      final trackedSkipNext = SkipNext(playback, library, trackedSession);
      trackedSession.start(sampleTracks[0].id);
      clock = clock.add(const Duration(seconds: 17));

      unwrapValue(await trackedSkipNext(sampleTracks[1]));

      final events = unwrapValue(await library.getListeningEvents());
      expect(events, hasLength(1));
      expect(events.single.trackId, sampleTracks[0].id);
      expect(events.single.msPlayed, 17000);
    },
  );
}
