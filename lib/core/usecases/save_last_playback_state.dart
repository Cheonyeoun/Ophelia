import '../domain/local_library_port.dart';
import '../domain/playback_session_snapshot.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Persists the current session so `RestoreLastSession` can bring it back
/// on the next app startup — a thin wrapper around
/// [LocalLibraryPort.saveLastPlaybackState], the same way `ScanLocalFolder`
/// wraps a single port call (see core/usecases/scan_local_folder.dart).
class SaveLastPlaybackState {
  final LocalLibraryPort library;

  SaveLastPlaybackState(this.library);

  Future<Result<void, Failure>> call(PlaybackSessionSnapshot snapshot) =>
      library.saveLastPlaybackState(snapshot);
}
