import 'package:test/test.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/usecases/scan_local_folder.dart';
import 'package:ophelia/data/fakes/fake_local_file_source_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('returns the tracks LocalFileSourcePort finds in the folder', () async {
    const track = Track(
      id: 'local:/music/song.mp3',
      title: 'Song',
      artist: 'Someone',
      album: 'Some Folder',
      durationMs: 1000,
      sourceType: TrackSourceType.local,
    );
    final localFileSource = FakeLocalFileSourcePort(
      tracksByFolder: {'/music': [track]},
    );
    final scanLocalFolder = ScanLocalFolder(localFileSource);

    final tracks = unwrapValue(await scanLocalFolder('/music'));

    expect(tracks, [track]);
  });

  test('propagates a NotFoundFailure for an unknown folder', () async {
    final localFileSource = FakeLocalFileSourcePort();
    final scanLocalFolder = ScanLocalFolder(localFileSource);

    final failure = unwrapFailure(await scanLocalFolder('/missing'));

    expect(failure, isA<NotFoundFailure>());
  });
}
