import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;

import '../../core/domain/listening_event.dart' as domain;
import '../../core/domain/local_library_port.dart';
import '../../core/domain/playlist.dart' as domain;
import '../../core/domain/user_profile.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import 'database.dart';

/// Real [LocalLibraryPort] adapter backed by [OpheliaDatabase] (Drift/
/// SQLite) — see docs/architecture.md §5. Replaces `FakeLocalLibraryPort`
/// as the app's default (lib/app/providers.dart); the fake remains for
/// tests that want predictable sample data without a real database.
///
/// Every method maps real Drift/SQLite exceptions to [StorageFailure] --
/// [SqliteException] covers constraint violations and most on-disk I/O
/// problems, and drift's isolate protocol specifically reconstructs that
/// exception type across the background isolate boundary (see
/// `database.dart`), so catching it here works whether or not a query
/// actually ran on this isolate. A missing row is never an exception --
/// it's a plain query result -- so those cases return [NotFoundFailure]
/// directly instead of relying on a catch clause.
class DriftLibraryAdapter implements LocalLibraryPort {
  final OpheliaDatabase _db;

  DriftLibraryAdapter(this._db);

  /// Ensures a placeholder `cached_tracks` row exists for [trackId], so
  /// that inserting a `playlist_tracks`/`listening_events` row
  /// referencing it doesn't violate the foreign key -- see tables.dart's
  /// doc comment on why `cached_tracks` is otherwise left for a future
  /// media-cache adapter to populate.
  Future<void> _ensureCachedTrackStub(String trackId) {
    return _db
        .into(_db.cachedTracks)
        .insert(
          CachedTracksCompanion.insert(id: trackId),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<Result<List<domain.Playlist>, Failure>> getPlaylists() async {
    try {
      final rows =
          await (_db.select(_db.playlists)
                ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]))
              .get();
      final playlists = await Future.wait(rows.map(_toDomainPlaylist));
      return Result.success(playlists);
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  @override
  Future<Result<domain.Playlist, Failure>> getPlaylist(String id) async {
    try {
      final row = await (_db.select(
        _db.playlists,
      )..where((p) => p.id.equals(id))).getSingleOrNull();
      if (row == null) {
        return Result.failure(NotFoundFailure('no playlist with id $id'));
      }
      return Result.success(await _toDomainPlaylist(row));
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  Future<domain.Playlist> _toDomainPlaylist(Playlist row) async {
    final trackRows =
        await (_db.select(_db.playlistTracks)
              ..where((t) => t.playlistId.equals(row.id))
              ..orderBy([(t) => OrderingTerm(expression: t.position)]))
            .get();
    return domain.Playlist(
      id: row.id,
      name: row.name,
      trackIds: [for (final t in trackRows) t.trackId],
    );
  }

  @override
  Future<Result<void, Failure>> savePlaylist(domain.Playlist playlist) async {
    try {
      await _db.transaction(() async {
        for (final trackId in playlist.trackIds) {
          await _ensureCachedTrackStub(trackId);
        }

        final existing = await (_db.select(
          _db.playlists,
        )..where((p) => p.id.equals(playlist.id))).getSingleOrNull();

        if (existing == null) {
          await _db
              .into(_db.playlists)
              .insert(
                PlaylistsCompanion.insert(
                  id: playlist.id,
                  name: playlist.name,
                  createdAt: DateTime.now(),
                ),
              );
        } else {
          await (_db.update(
            _db.playlists,
          )..where((p) => p.id.equals(playlist.id))).write(
            PlaylistsCompanion(name: Value(playlist.name)),
          );
        }

        await (_db.delete(
          _db.playlistTracks,
        )..where((t) => t.playlistId.equals(playlist.id))).go();

        await _db.batch((b) {
          b.insertAll(_db.playlistTracks, [
            for (final (index, trackId) in playlist.trackIds.indexed)
              PlaylistTracksCompanion.insert(
                playlistId: playlist.id,
                trackId: trackId,
                position: index,
              ),
          ]);
        });
      });
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  @override
  Future<Result<void, Failure>> deletePlaylist(String id) async {
    try {
      final deletedCount = await (_db.delete(
        _db.playlists,
      )..where((p) => p.id.equals(id))).go();
      if (deletedCount == 0) {
        return Result.failure(NotFoundFailure('no playlist with id $id'));
      }
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  @override
  Future<Result<UserProfile, Failure>> getProfile() async {
    try {
      final row = await _db.select(_db.profile).getSingleOrNull();
      if (row == null) {
        return Result.failure(const NotFoundFailure('no profile set up yet'));
      }
      return Result.success(
        UserProfile(
          displayName: row.displayName,
          backgroundImagePath: row.backgroundPath,
          profileImagePath: row.profileImagePath,
        ),
      );
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  @override
  Future<Result<void, Failure>> saveProfile(UserProfile profile) async {
    try {
      final existing = await _db.select(_db.profile).getSingleOrNull();
      final companion = ProfileCompanion(
        displayName: Value(profile.displayName),
        backgroundPath: Value(profile.backgroundImagePath),
        profileImagePath: Value(profile.profileImagePath),
      );

      if (existing == null) {
        await _db.into(_db.profile).insert(companion);
      } else {
        await (_db.update(
          _db.profile,
        )..where((p) => p.id.equals(existing.id))).write(companion);
      }
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  @override
  Future<Result<void, Failure>> recordListeningEvent(
    domain.ListeningEvent event,
  ) async {
    try {
      await _db.transaction(() async {
        await _ensureCachedTrackStub(event.trackId);
        await _db
            .into(_db.listeningEvents)
            .insert(
              ListeningEventsCompanion.insert(
                trackId: event.trackId,
                playedAt: event.playedAt,
                msPlayed: event.msPlayed,
              ),
            );
      });
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  @override
  Future<Result<List<domain.ListeningEvent>, Failure>>
  getListeningEvents() async {
    try {
      final rows = await _db.select(_db.listeningEvents).get();
      return Result.success([
        for (final row in rows)
          domain.ListeningEvent(
            trackId: row.trackId,
            playedAt: row.playedAt,
            msPlayed: row.msPlayed,
          ),
      ]);
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }
}
