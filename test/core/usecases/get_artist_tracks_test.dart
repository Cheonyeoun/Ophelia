import 'package:test/test.dart';
import 'package:ophelia/core/usecases/get_artist_tracks.dart';
import 'package:ophelia/data/fakes/fake_media_source_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('returns only the tracks credited to the given artist, in order', () async {
    final mediaSource = FakeMediaSourcePort();
    final getArtistTracks = GetArtistTracks(mediaSource);

    final tracks = unwrapValue(await getArtistTracks('Wren Callahan'));

    expect(tracks, [sampleTracks[0], sampleTracks[1]]);
  });

  test(
    'matches the artist exactly, not a fuzzy substring match',
    () async {
      final mediaSource = FakeMediaSourcePort();
      final getArtistTracks = GetArtistTracks(mediaSource);

      // 'Wren' alone is a substring of 'Wren Callahan' but not an exact
      // match -- search() would match it, getTracksByArtist() must not.
      final tracks = unwrapValue(await getArtistTracks('Wren'));

      expect(tracks, isEmpty);
    },
  );

  test('returns an empty list for an artist with no tracks', () async {
    final mediaSource = FakeMediaSourcePort();
    final getArtistTracks = GetArtistTracks(mediaSource);

    final tracks = unwrapValue(await getArtistTracks('Nobody'));

    expect(tracks, isEmpty);
  });
}
