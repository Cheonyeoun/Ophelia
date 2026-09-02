import 'package:test/test.dart';
import 'package:ophelia/core/usecases/download_track.dart';
import 'package:ophelia/data/fakes/fake_download_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('downloads a track and returns the download record', () async {
    final downloads = FakeDownloadPort(seed: []);
    final downloadTrack = DownloadTrack(downloads);
    final track = sampleTracks.first;

    final record = unwrapValue(await downloadTrack(track));

    expect(record.trackId, track.id);
    expect(unwrapValue(await downloads.isDownloaded(track.id)), isTrue);
  });
}
