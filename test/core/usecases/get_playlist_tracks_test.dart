import 'package:test/test.dart';
import 'package:ophelia/core/domain/playlist.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/usecases/get_playlist_tracks.dart';
import 'package:ophelia/data/fakes/fake_media_source_port.dart';
import 'package:ophelia/data/fakes/fake_playback_engine_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test(
    "resolves a playlist's track ids to full tracks, in order",
    () async {
      final mediaSource = FakeMediaSourcePort();
      final getPlaylistTracks = GetPlaylistTracks(mediaSource);
      final playlist = samplePlaylists.first;

      final tracks = unwrapValue(await getPlaylistTracks(playlist));

      expect(tracks.map((track) => track.id), playlist.trackIds);
    },
  );

  test('propagates a failure when a track id cannot be resolved', () async {
    final mediaSource = FakeMediaSourcePort();
    final getPlaylistTracks = GetPlaylistTracks(mediaSource);
    final playlist = Playlist(id: 'bad', name: 'Bad', trackIds: ['missing']);

    final failure = unwrapFailure(await getPlaylistTracks(playlist));

    expect(failure, isA<NotFoundFailure>());
  });

  test('never touches the playback engine, unlike BuildQueue', () async {
    final mediaSource = FakeMediaSourcePort();
    final playback = FakePlaybackEnginePort();
    final getPlaylistTracks = GetPlaylistTracks(mediaSource);
    final playlist = samplePlaylists.first;

    unwrapValue(await getPlaylistTracks(playlist));

    expect(playback.queue, isEmpty);
  });
}
