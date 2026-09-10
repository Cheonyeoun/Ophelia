import 'package:test/test.dart';
import 'package:ophelia/core/domain/download_record.dart';
import 'package:ophelia/core/domain/playback_session_snapshot.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/usecases/restore_last_session.dart';
import 'package:ophelia/data/fakes/fake_download_port.dart';
import 'package:ophelia/data/fakes/fake_local_file_source_port.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';

import '../../support/result_test_helpers.dart';

const _localTrack = Track(
  id: 'local:/music/song.mp3',
  title: 'Song',
  artist: 'Artist',
  album: 'Album',
  durationMs: 1000,
  sourceType: TrackSourceType.local,
);

const _streamedTrack = Track(
  id: 't1',
  title: 'Streamed',
  artist: 'Artist',
  album: 'Album',
  durationMs: 1000,
  sourceType: TrackSourceType.streamed,
);

const _downloadedTrack = Track(
  id: 't2',
  title: 'Downloaded',
  artist: 'Artist',
  album: 'Album',
  durationMs: 1000,
  sourceType: TrackSourceType.downloaded,
);

void main() {
  late FakeLocalLibraryPort library;
  late FakeLocalFileSourcePort localFileSource;
  late FakeDownloadPort downloads;
  late RestoreLastSession restoreLastSession;

  setUp(() {
    library = FakeLocalLibraryPort();
    localFileSource = FakeLocalFileSourcePort(
      tracksByFolder: const {
        '/music': [_localTrack],
      },
    );
    downloads = FakeDownloadPort(seed: []);
    restoreLastSession = RestoreLastSession(
      library,
      localFileSource,
      downloads,
    );
  });

  test('returns a null success when nothing has ever been saved', () async {
    expect(unwrapValue(await restoreLastSession()), isNull);
  });

  test('returns the saved snapshot for a streamed track without checking '
      'anything -- there is no local/download source to verify', () async {
    final snapshot = PlaybackSessionSnapshot(
      queue: const [_streamedTrack],
      queueIndex: 0,
      position: const Duration(seconds: 10),
    );
    await library.saveLastPlaybackState(snapshot);

    expect(unwrapValue(await restoreLastSession()), snapshot);
  });

  test(
    'returns the saved snapshot for a local track whose file still exists',
    () async {
      final snapshot = PlaybackSessionSnapshot(
        queue: const [_localTrack],
        queueIndex: 0,
        position: const Duration(seconds: 5),
      );
      await library.saveLastPlaybackState(snapshot);

      expect(unwrapValue(await restoreLastSession()), snapshot);
    },
  );

  test(
    'fails gracefully (a null success, not a crash or a Failure) when a '
    'saved local track\'s file no longer exists -- e.g. its linked folder '
    'was removed',
    () async {
      localFileSource.missingTrackIds.add(_localTrack.id);
      final snapshot = PlaybackSessionSnapshot(
        queue: const [_localTrack],
        queueIndex: 0,
        position: const Duration(seconds: 5),
      );
      await library.saveLastPlaybackState(snapshot);

      expect(unwrapValue(await restoreLastSession()), isNull);
    },
  );

  test(
    'returns the saved snapshot for a downloaded track still marked as '
    'downloaded',
    () async {
      downloads = FakeDownloadPort(
        seed: [
          DownloadRecord(
            trackId: _downloadedTrack.id,
            localPath: '/downloads/t2.mp3',
            sizeBytes: 1000,
            downloadedAt: DateTime.now(),
          ),
        ],
      );
      restoreLastSession = RestoreLastSession(
        library,
        localFileSource,
        downloads,
      );
      final snapshot = PlaybackSessionSnapshot(
        queue: const [_downloadedTrack],
        queueIndex: 0,
        position: Duration.zero,
      );
      await library.saveLastPlaybackState(snapshot);

      expect(unwrapValue(await restoreLastSession()), snapshot);
    },
  );

  test(
    'fails gracefully when a saved downloaded track is no longer marked '
    'as downloaded',
    () async {
      final snapshot = PlaybackSessionSnapshot(
        queue: const [_downloadedTrack],
        queueIndex: 0,
        position: Duration.zero,
      );
      await library.saveLastPlaybackState(snapshot);

      expect(unwrapValue(await restoreLastSession()), isNull);
    },
  );
}
