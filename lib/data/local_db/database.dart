import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  /// The real connection used outside tests. `driftDatabase`
  /// (package:drift_flutter) is conditionally implemented per platform
  /// (see its own `connect.dart`), so this same call compiles to two
  /// genuinely different backends:
  ///
  /// - **Native** (Android, iOS, macOS, Linux, Windows): a background-
  ///   isolate-backed native database (docs/architecture.md §5.3's "off
  ///   the UI thread" requirement) — `driftDatabase` defaults to
  ///   `NativeDatabase.createBackgroundConnection` under the hood, so no
  ///   query here ever runs on the same isolate as the UI. [native] is
  ///   ignored on web.
  /// - **Web**: a WebAssembly SQLite build running in a worker (also off
  ///   the UI thread) via `sqlite3.wasm` + `drift_worker.js`, both under
  ///   `web/` — see https://drift.simonbinder.eu/web/#prerequisites.
  ///   Both files must come from the exact same drift/sqlite3 package
  ///   versions this app depends on (check pubspec.lock); `web/
  ///   drift_worker.js` here is copied straight from the installed
  ///   `drift` package (`drift_worker.js` at that package's root, built
  ///   by drift's own release process), and `web/sqlite3.wasm` is
  ///   downloaded from the matching tag on
  ///   https://github.com/simolus3/sqlite3.dart/releases. [web] is
  ///   required when compiling for web and ignored on native.
  static QueryExecutor defaultConnection() => driftDatabase(
        name: 'ophelia',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );

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
          // events) don't block foreground reads (library browsing).
          // Skipped on web -- drift's wasm backend documents WAL as
          // unsupported there (https://drift.simonbinder.eu/web/) -- and
          // a no-op on the in-memory database tests use, since SQLite
          // doesn't support WAL for ':memory:' and just keeps its
          // existing journal mode instead of erroring.
          if (!kIsWeb) {
            await customStatement('PRAGMA journal_mode = WAL');
          }
        },
      );
}
