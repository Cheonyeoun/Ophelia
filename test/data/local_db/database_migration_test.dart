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
  test(
    'reopening a pre-existing v1 database creates linked_folders via '
    'onUpgrade, instead of leaving it missing and failing with '
    '"no such table" the first time it is used',
    () async {
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
    },
  );
}
