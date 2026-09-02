import 'package:test/test.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/usecases/play_track.dart';
import 'package:ophelia/data/fakes/fake_download_port.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/data/fakes/fake_media_source_port.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  late FakePlaybackEnginePort playback;
  late FakeMediaSourcePort mediaSource;
  late FakeDownloadPort downloads;
  late FakeLocalLibraryPort library;
  late PlayTrack playTrack;

  setUp(() {
    playback = FakePlaybackEnginePort();
    mediaSource = FakeMediaSourcePort();
    downloads = FakeDownloadPort(seed: []);
    library = FakeLocalLibraryPort(listeningEvents: []);
    playTrack = PlayTrack(playback, mediaSource, downloads, library);
  });

  test(
    'plays a downloaded track from its local path and records a '
    'listening event',
    () async {
      final track = sampleTracks.first;
      await downloads.download(track);

      unwrapValue(await playTrack(track));

      expect(playback.currentTrack, track);
      expect(playback.currentSourcePath, '/downloads/${track.id}.mp3');

      final events = unwrapValue(await library.getListeningEvents());
      expect(events, hasLength(1));
      expect(events.single.trackId, track.id);
    },
  );

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
