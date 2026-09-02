import 'package:test/test.dart';
import 'package:ophelia/core/domain/playlist.dart';
import 'package:ophelia/core/usecases/save_playlist.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('saves a new playlist', () async {
    final library = FakeLocalLibraryPort();
    final savePlaylist = SavePlaylist(library);
    final playlist = Playlist(
      id: 'new',
      name: 'New playlist',
      trackIds: ['t1'],
    );

    unwrapValue(await savePlaylist(playlist));

    final saved = unwrapValue(await library.getPlaylist('new'));
    expect(saved, playlist);
  });

  test('updates an existing playlist in place', () async {
    final library = FakeLocalLibraryPort();
    final savePlaylist = SavePlaylist(library);
    final original = unwrapValue(await library.getPlaylists()).first;
    final renamed = original.copyWith(name: 'Renamed');

    unwrapValue(await savePlaylist(renamed));

    final saved = unwrapValue(await library.getPlaylist(original.id));
    expect(saved.name, 'Renamed');
    final all = unwrapValue(await library.getPlaylists());
    expect(all, hasLength(2));
  });
}
