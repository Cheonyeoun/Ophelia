import '../error/failure.dart';
import '../error/result.dart';
import 'listening_event.dart';
import 'playlist.dart';
import 'user_profile.dart';

/// Port for local persistence of playlists, the user profile, and
/// listening history — the source of truth for everything except raw
/// audio bytes (see docs/architecture.md §1, §3.1). Implemented by an
/// adapter under lib/data/local_db/ (see §3.3) — the domain only depends
/// on this interface.
abstract interface class LocalLibraryPort {
  Future<Result<List<Playlist>, Failure>> getPlaylists();

  Future<Result<Playlist, Failure>> getPlaylist(String id);

  /// Creates the playlist if [playlist.id] is new, otherwise updates it.
  Future<Result<void, Failure>> savePlaylist(Playlist playlist);

  Future<Result<void, Failure>> deletePlaylist(String id);

  Future<Result<UserProfile, Failure>> getProfile();

  /// Creates the profile if none exists yet, otherwise updates it.
  Future<Result<void, Failure>> saveProfile(UserProfile profile);

  Future<Result<void, Failure>> recordListeningEvent(ListeningEvent event);

  Future<Result<List<ListeningEvent>, Failure>> getListeningEvents();
}
