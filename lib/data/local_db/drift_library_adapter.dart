import 'package:drift/drift.dart';
import 'package:sqlite3/common.dart' show SqliteException;

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
/// problems, and drift's cross-boundary protocol specifically
/// reconstructs that exception type on the way back -- across the
/// background isolate on native, or the web worker on web (see
/// `database.dart`) -- so catching it here works everywhere regardless of
/// where the query actually ran. A missing row is never an exception --
/// it's a plain query result -- so those cases return [NotFoundFailure]
/// directly instead of relying on a catch clause.
///
/// Imports `SqliteException` from `package:sqlite3/common.dart`, not
/// `package:sqlite3/sqlite3.dart` -- the latter pulls in `dart:ffi`
/// bindings that don't compile for web at all (`external` members are
/// only valid there for JS interop), and this file is loaded on every
/// platform through `providers.dart`.
class DriftLibraryAdapter implements LocalLibraryPort {
  final OpheliaDatabase _db;

  DriftLibraryAdapter(this._db);

  /// The one and only `profile` row's fixed id -- see [Profile]'s doc
  /// comment on why a deliberate constant, rather than "whatever row
  /// happens to already be there," is what makes [saveProfile] an atomic
  /// upsert instead of a racy check-then-insert-or-update.
  static const profileRowId = 1;

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
      // One join query for every playlist and its tracks together, rather
      // than one query per playlist (_toDomainPlaylist) -- that N+1 would
      // scale with the number of playlists instead of staying constant.
      // A left outer join keeps a playlist with zero tracks in the result
      // (as a single row with null playlist_tracks columns) instead of an
      // inner join silently dropping it.
      final query = _db.select(_db.playlists).join([
        leftOuterJoin(
          _db.playlistTracks,
          _db.playlistTracks.playlistId.equalsExp(_db.playlists.id),
        ),
      ])
        ..orderBy([
          // id after createdAt breaks ties between playlists created in
          // the same instant, so every row belonging to one playlist stays
          // contiguous -- required for the single linear grouping pass in
          // _groupJoinedRows below to be correct.
          OrderingTerm(expression: _db.playlists.createdAt),
          OrderingTerm(expression: _db.playlists.id),
          OrderingTerm(expression: _db.playlistTracks.position),
        ]);

      final rows = await query.get();
      return Result.success(_groupJoinedRows(rows));
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  /// Groups the flat, joined `playlists`/`playlist_tracks` result set from
  /// [getPlaylists] back into [domain.Playlist]s, one linear pass over
  /// rows already ordered so each playlist's own rows are contiguous and
  /// its tracks are already in position order.
  List<domain.Playlist> _groupJoinedRows(List<TypedResult> rows) {
    final order = <String>[];
    final names = <String, String>{};
    final trackIds = <String, List<String>>{};

    for (final row in rows) {
      final playlist = row.readTable(_db.playlists);
      final track = row.readTableOrNull(_db.playlistTracks);

      final ids = trackIds.putIfAbsent(playlist.id, () {
        order.add(playlist.id);
        names[playlist.id] = playlist.name;
        return [];
      });
      if (track != null) ids.add(track.trackId);
    }

    return [
      for (final id in order)
        domain.Playlist(id: id, name: names[id]!, trackIds: trackIds[id]!),
    ];
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
      final row = await (_db.select(
        _db.profile,
      )..where((p) => p.id.equals(profileRowId))).getSingleOrNull();
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
      // A single atomic upsert against the fixed profileRowId, rather
      // than a "check if any row exists, then insert or update" -- two
      // concurrent saveProfile calls both reading "no row yet" and then
      // both inserting used to be able to race into two rows (or a
      // constraint violation, depending on timing); ON CONFLICT DO UPDATE
      // makes that structurally impossible instead of just less likely,
      // since SQLite resolves the conflict within the single statement.
      await _db
          .into(_db.profile)
          .insertOnConflictUpdate(
            ProfileCompanion(
              id: const Value(profileRowId),
              displayName: Value(profile.displayName),
              backgroundPath: Value(profile.backgroundImagePath),
              profileImagePath: Value(profile.profileImagePath),
            ),
          );
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
