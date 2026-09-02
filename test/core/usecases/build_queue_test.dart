import 'package:test/test.dart';
import 'package:ophelia/core/domain/playlist.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/usecases/build_queue.dart';
import 'package:ophelia/data/fakes/fake_media_source_port.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test("resolves a playlist's track ids to tracks and loads the queue", () async {
    final mediaSource = FakeMediaSourcePort();
    final playback = FakePlaybackEnginePort();
    final buildQueue = BuildQueue(mediaSource, playback);
    final playlist = samplePlaylists.first;

    unwrapValue(await buildQueue(playlist));

    expect(playback.queue.map((track) => track.id), playlist.trackIds);
  });

  test('propagates a failure when a track id cannot be resolved', () async {
    final mediaSource = FakeMediaSourcePort();
    final playback = FakePlaybackEnginePort();
    final buildQueue = BuildQueue(mediaSource, playback);
    final playlist = Playlist(id: 'bad', name: 'Bad', trackIds: ['missing']);

    final failure = unwrapFailure(await buildQueue(playlist));

    expect(failure, isA<NotFoundFailure>());
  });
}
