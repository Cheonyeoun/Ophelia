import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

/// The app's local Drift/SQLite database (docs/architecture.md §5) --
/// playlists, the user profile, and listening history. Song metadata and
/// downloads are cached here too (`cached_tracks`, `downloads`) but, for
/// now, only ever read/written as placeholders by [DriftLibraryAdapter] --
/// see tables.dart's doc comment.
@DriftDatabase(
  tables: [Playlists, PlaylistTracks, CachedTracks, ListeningEvents, Profile, Downloads],
)
class OpheliaDatabase extends _$OpheliaDatabase {
  /// [executor] is overridable so tests can pass an in-memory
  /// `NativeDatabase.memory()` instead of the real, isolate-backed
  /// connection [defaultConnection] opens.
  OpheliaDatabase([QueryExecutor? executor])
      : super(executor ?? defaultConnection());

  /// The real connection used outside tests: a background-isolate-backed
  /// native database (docs/architecture.md §5.3's "off the UI thread"
  /// requirement) — `driftDatabase` (package:drift_flutter) defaults to
  /// `NativeDatabase.createBackgroundConnection` under the hood, so no
  /// query here ever runs on the same isolate as the UI.
  static QueryExecutor defaultConnection() => driftDatabase(name: 'ophelia');

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          // SQLite disables foreign key enforcement by default; without
          // this, every `.references()` constraint in tables.dart
          // (including the cascade delete from playlists to
          // playlist_tracks) would silently do nothing.
          await customStatement('PRAGMA foreign_keys = ON');
          // docs/architecture.md §5.3: so background writes (listening
          // events) don't block foreground reads (library browsing). A
          // no-op on the in-memory database tests use -- SQLite doesn't
          // support WAL for ':memory:' and just keeps its existing
          // journal mode instead of erroring.
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );
}
