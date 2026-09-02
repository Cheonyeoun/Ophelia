import '../../core/domain/listening_event.dart';
import '../../core/domain/local_library_port.dart';
import '../../core/domain/playlist.dart';
import '../../core/domain/user_profile.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import 'sample_data.dart';

/// **Temporary, UI-development-only fake — not a production adapter.**
///
/// In-memory stand-in for [LocalLibraryPort], seeded with
/// [samplePlaylists], [sampleUserProfile], and sample listening history,
/// so screens have believable library data before a real adapter exists
/// under lib/data/local_db/.
class FakeLocalLibraryPort implements LocalLibraryPort {
  final List<Playlist> _playlists;
  UserProfile profile;
  final List<ListeningEvent> _listeningEvents;

  FakeLocalLibraryPort({
    List<Playlist>? playlists,
    this.profile = sampleUserProfile,
    List<ListeningEvent>? listeningEvents,
  })  : _playlists = List.of(playlists ?? samplePlaylists),
        _listeningEvents =
            List.of(listeningEvents ?? buildSampleListeningEvents());

  @override
  Future<Result<List<Playlist>, Failure>> getPlaylists() async {
    return Result.success(List.unmodifiable(_playlists));
  }

  @override
  Future<Result<Playlist, Failure>> getPlaylist(String id) async {
    for (final playlist in _playlists) {
      if (playlist.id == id) return Result.success(playlist);
    }
    return Result.failure(NotFoundFailure('no playlist with id $id'));
  }

  @override
  Future<Result<void, Failure>> savePlaylist(Playlist playlist) async {
    final index = _playlists.indexWhere((p) => p.id == playlist.id);
    if (index == -1) {
      _playlists.add(playlist);
    } else {
      _playlists[index] = playlist;
    }
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> deletePlaylist(String id) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) {
      return Result.failure(NotFoundFailure('no playlist with id $id'));
    }
    _playlists.removeAt(index);
    return const Result.success(null);
  }

  @override
  Future<Result<UserProfile, Failure>> getProfile() async {
    return Result.success(profile);
  }

  @override
  Future<Result<void, Failure>> saveProfile(UserProfile profile) async {
    this.profile = profile;
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> recordListeningEvent(
    ListeningEvent event,
  ) async {
    _listeningEvents.add(event);
    return const Result.success(null);
  }

  @override
  Future<Result<List<ListeningEvent>, Failure>> getListeningEvents() async {
    return Result.success(List.unmodifiable(_listeningEvents));
  }
}
