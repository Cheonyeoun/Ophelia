import 'package:test/test.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/usecases/listening_session.dart';
import 'package:ophelia/core/usecases/play_track.dart';
import 'package:ophelia/data/fakes/fake_download_port.dart';
import 'package:ophelia/data/fakes/fake_media_source_port.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  late FakePlaybackEnginePort playback;
  late FakeMediaSourcePort mediaSource;
  late FakeDownloadPort downloads;
  late ListeningSession session;
  late PlayTrack playTrack;

  setUp(() {
    playback = FakePlaybackEnginePort();
    mediaSource = FakeMediaSourcePort();
    downloads = FakeDownloadPort(seed: []);
    session = ListeningSession();
    playTrack = PlayTrack(playback, mediaSource, downloads, session);
  });

  test('plays a downloaded track from its local path', () async {
    final track = sampleTracks.first;
    await downloads.download(track);

    unwrapValue(await playTrack(track));

    expect(playback.currentTrack, track);
    expect(playback.currentSourcePath, '/downloads/${track.id}.mp3');
  });

  test('streams a track that has not been downloaded', () async {
    final track = sampleTracks[2];

    unwrapValue(await playTrack(track));

    expect(playback.currentTrack, track);
    expect(
      playback.currentSourcePath,
      'https://stream.ophelia.fake/${track.id}',
    );
  });

  test(
    'sets the engine queue to the given queue, positioned at the played '
    'track',
    () async {
      final queue = [sampleTracks[0], sampleTracks[1], sampleTracks[2]];

      unwrapValue(await playTrack(sampleTracks[1], queue: queue));

      expect(playback.queue, queue);
      expect(playback.currentIndex, 1);
    },
  );

  test(
    'defaults the engine queue to just the played track when none is given',
    () async {
      final track = sampleTracks.first;

      unwrapValue(await playTrack(track));

      expect(playback.queue, [track]);
      expect(playback.currentIndex, 0);
    },
  );

  test('starts tracking a listening session for the played track', () async {
    final track = sampleTracks.first;

    unwrapValue(await playTrack(track));

    final event = session.finish();
    expect(event, isNotNull);
    expect(event!.trackId, track.id);
  });

  test(
    'propagates a failure when the track is unknown to the media source',
    () async {
      const unknownTrack = Track(
        id: 'unknown',
        title: 'Unknown',
        artist: 'Nobody',
        album: 'Nowhere',
        durationMs: 1000,
        sourceType: TrackSourceType.streamed,
      );

      final failure = unwrapFailure(await playTrack(unknownTrack));

      expect(failure, isA<NotFoundFailure>());
    },
  );
}
