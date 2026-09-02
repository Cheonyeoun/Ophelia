import '../domain/local_library_port.dart';
import '../domain/playlist.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Creates or updates a playlist.
class SavePlaylist {
  final LocalLibraryPort library;

  SavePlaylist(this.library);

  Future<Result<void, Failure>> call(Playlist playlist) =>
      library.savePlaylist(playlist);
}
