import 'package:drift/drift.dart';

/// The local schema from docs/architecture.md §5.2, as Drift tables.
///
/// `cached_tracks` is deliberately thin here: this adapter only ever
/// writes a placeholder row (id only) to satisfy the foreign keys below
/// when a playlist or listening event references a track id — populating
/// it with real title/artist/album/etc. metadata is the job of a future
/// media-cache adapter that syncs from `MediaSourcePort`, not
/// [DriftLibraryAdapter]. That's why every column but [CachedTracks.id]
/// is nullable.
///
/// Deferred per docs/architecture.md §5.3, until `SearchCatalog`/
/// `ComputeTopSongs` actually need the performance: an FTS5 virtual table
/// over title/artist/album for search, and a materialized `weekly_stats`
/// table instead of live-aggregating `listening_events`.
class Playlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A playlist's ordered track ids. Has its own autoincrement [id] (rather
/// than a composite `(playlist_id, track_id)` key) because the same track
/// can legitimately appear more than once in one playlist at different
/// [position]s — a duplicate-track queue/playlist is supported elsewhere
/// in this app (see e.g. `fake_playback_engine_port_test.dart`), so a
/// unique-pair constraint here would incorrectly forbid it.
@TableIndex(name: 'playlist_tracks_track_id', columns: {#trackId})
class PlaylistTracks extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Cascades so deleting a playlist cleans up its track rows instead of
  /// leaving them orphaned.
  TextColumn get playlistId =>
      text().references(Playlists, #id, onDelete: KeyAction.cascade)();

  /// No `onDelete` action: unlike a playlist owned outright by this
  /// adapter, a `cached_tracks` row deleted by a future cache-cleanup
  /// process shouldn't silently delete a user's playlist entries too.
  TextColumn get trackId => text().references(CachedTracks, #id)();

  IntColumn get position => integer()();
}

class CachedTracks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get coverArtPath => text().nullable()();
  BoolColumn get isDownloaded =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'listening_events_track_id', columns: {#trackId})
@TableIndex(name: 'listening_events_played_at', columns: {#playedAt})
class ListeningEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackId => text().references(CachedTracks, #id)();
  DateTimeColumn get playedAt => dateTime()();
  IntColumn get msPlayed => integer()();
}

/// A singleton table: the app has exactly one local user, so this only
/// ever holds zero or one row (see [DriftLibraryAdapter.getProfile]/
/// [DriftLibraryAdapter.saveProfile]) rather than being keyed by a
/// meaningful user id.
class Profile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text()();
  TextColumn get backgroundPath => text().nullable()();
  TextColumn get profileImagePath => text().nullable()();
}

/// Not written by [DriftLibraryAdapter] -- downloads belong to
/// `DownloadPort`'s own (still-fake) adapter under lib/data/downloads/.
/// Defined here now so the schema matches docs/architecture.md §5.2 in
/// full and that future adapter has a table to migrate onto.
class Downloads extends Table {
  TextColumn get trackId => text().references(CachedTracks, #id)();
  TextColumn get localPath => text()();
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {trackId};
}
