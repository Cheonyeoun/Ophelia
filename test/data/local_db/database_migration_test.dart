import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:ophelia/data/local_db/database.dart';

/// Covers `OpheliaDatabase.migration`'s `onUpgrade` step -- specifically
/// the v1 -> v2 step that adds `linked_folders` (local_file_source
/// feature). A fresh database always goes through `onCreate`, which
/// every other test implicitly exercises just by constructing
/// `OpheliaDatabase(NativeDatabase.memory())`; that path can't catch a
/// missing migration, since `onCreate`'s `m.createAll()` builds every
/// table currently in the schema regardless of what changed since the
/// last release. The bug this guards against only shows up on a database
/// file that already existed *before* `linked_folders` was added --
/// simulated here via [NativeDatabase.memory]'s `setup` hook, which runs
/// against the raw sqlite3 connection before drift's own migration logic
/// does, to stamp `PRAGMA user_version = 1` the same way a real v1
/// install's database file would already carry it.
void main() {
  test('reopening a pre-existing v1 database creates linked_folders via '
      'onUpgrade, instead of leaving it missing and failing with '
      '"no such table" the first time it is used', () async {
    final executor = NativeDatabase.memory(
      setup: (rawDb) => rawDb.execute('PRAGMA user_version = 1'),
    );
    final db = OpheliaDatabase(executor);

    try {
      // Opening the database must trigger onUpgrade(from: 1, to: 2) and
      // create linked_folders -- without that, this throws a real
      // SqliteException ("no such table: linked_folders") instead of
      // succeeding.
      await db
          .into(db.linkedFolders)
          .insert(
            LinkedFoldersCompanion.insert(
              path: '/music',
              linkedAt: DateTime.now(),
            ),
          );
      final rows = await db.select(db.linkedFolders).get();

      expect(rows.map((r) => r.path), ['/music']);
    } finally {
      await db.close();
    }
  });

  test('reopening a pre-existing v2 database creates playback_session and '
      'playback_queue_entries via onUpgrade, instead of leaving them missing '
      '(session-restore-on-startup feature)', () async {
    final executor = NativeDatabase.memory(
      setup: (rawDb) => rawDb.execute('PRAGMA user_version = 2'),
    );
    final db = OpheliaDatabase(executor);

    try {
      await db
          .into(db.playbackSession)
          .insert(
            PlaybackSessionCompanion.insert(
              id: const Value(1),
              queueIndex: 0,
              positionMs: 0,
              savedAt: DateTime.now(),
            ),
          );
      await db
          .into(db.playbackQueueEntries)
          .insert(
            PlaybackQueueEntriesCompanion.insert(
              sessionId: 1,
              position: 0,
              trackId: 't1',
              title: 'Title',
              artist: 'Artist',
              album: 'Album',
              durationMs: 1000,
              sourceType: 'streamed',
            ),
          );

      final sessionRows = await db.select(db.playbackSession).get();
      final entryRows = await db.select(db.playbackQueueEntries).get();

      expect(sessionRows, hasLength(1));
      expect(entryRows.map((e) => e.trackId), ['t1']);
    } finally {
      await db.close();
    }
  });

  test(
    'reopening a pre-existing v3 database creates app_settings via '
    'onUpgrade, instead of leaving it missing (real SettingsPort adapter)',
    () async {
      final executor = NativeDatabase.memory(
        setup: (rawDb) => rawDb.execute('PRAGMA user_version = 3'),
      );
      final db = OpheliaDatabase(executor);

      try {
        // Opening the database must trigger onUpgrade(from: 3, to: 4) and
        // create app_settings -- without that, this throws a real
        // SqliteException ("no such table: app_settings") instead of
        // succeeding.
        await db
            .into(db.appSettings)
            .insert(
              AppSettingsCompanion.insert(
                id: const Value(1),
                streamingQuality: 'Low',
                gaplessPlayback: true,
                downloadQuality: 'Lossless',
                wifiOnlyDownloads: true,
                connectedServer: 'Home library',
                immersiveHudAutoHideDelay: '5s',
              ),
            );
        final rows = await db.select(db.appSettings).get();

        expect(rows.map((r) => r.streamingQuality), ['Low']);
      } finally {
        await db.close();
      }
    },
  );
}
