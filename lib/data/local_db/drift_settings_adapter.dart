import 'package:drift/drift.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../../core/domain/settings.dart' as domain;
import '../../core/domain/settings_port.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import 'database.dart';

/// Real [SettingsPort] adapter backed by [OpheliaDatabase] (Drift/SQLite)
/// -- see docs/architecture.md §5. Replaces `FakeSettingsPort` as the
/// app's default (lib/app/providers.dart); the fake remains for tests
/// that want predictable, hardware-free behavior.
///
/// A separate class implementing this separate port, rather than folded
/// into [DriftLibraryAdapter] -- same reasoning as `LocalFileSourceAdapter`'s
/// own doc comment: [SettingsPort] is its own interface, even though a
/// real adapter shares the same [OpheliaDatabase] for storage.
///
/// Unlike `DriftLibraryAdapter.getProfile` (which fails with
/// [NotFoundFailure] when no profile has ever been saved -- a genuinely
/// meaningful "not set up yet" state the Settings screen handles as its
/// own case), [getSettings] returns [domain.Settings.defaults] when no
/// row exists yet. There is no equivalent "not configured" state for
/// settings to represent -- every caller (the Settings screen, the
/// immersive-play auto-hide delay, ...) just wants *some* usable value on
/// a fresh install, the same way `FakeSettingsPort` always has one from
/// construction.
class DriftSettingsAdapter implements SettingsPort {
  final OpheliaDatabase _db;

  DriftSettingsAdapter(this._db);

  /// The one and only `app_settings` row's fixed id -- same reasoning as
  /// `DriftLibraryAdapter.profileRowId`, for the same kind of singleton
  /// row.
  static const settingsRowId = 1;

  @override
  Future<Result<domain.Settings, Failure>> getSettings() async {
    try {
      final row = await (_db.select(
        _db.appSettings,
      )..where((s) => s.id.equals(settingsRowId))).getSingleOrNull();
      if (row == null) return const Result.success(domain.Settings.defaults);
      return Result.success(
        domain.Settings(
          streamingQuality: row.streamingQuality,
          gaplessPlayback: row.gaplessPlayback,
          downloadQuality: row.downloadQuality,
          wifiOnlyDownloads: row.wifiOnlyDownloads,
          connectedServer: row.connectedServer,
          immersiveHudAutoHideDelay: row.immersiveHudAutoHideDelay,
        ),
      );
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }

  @override
  Future<Result<void, Failure>> saveSettings(domain.Settings settings) async {
    try {
      // A single atomic upsert against the fixed settingsRowId -- same
      // "ON CONFLICT DO UPDATE, not check-then-branch" reasoning as
      // `DriftLibraryAdapter.saveProfile`'s own doc comment: two
      // concurrent saveSettings calls racing a check-then-insert-or-update
      // could otherwise both see "no row yet" and both insert.
      await _db
          .into(_db.appSettings)
          .insertOnConflictUpdate(
            AppSettingsCompanion(
              id: const Value(settingsRowId),
              streamingQuality: Value(settings.streamingQuality),
              gaplessPlayback: Value(settings.gaplessPlayback),
              downloadQuality: Value(settings.downloadQuality),
              wifiOnlyDownloads: Value(settings.wifiOnlyDownloads),
              connectedServer: Value(settings.connectedServer),
              immersiveHudAutoHideDelay: Value(
                settings.immersiveHudAutoHideDelay,
              ),
            ),
          );
      return const Result.success(null);
    } on SqliteException catch (e) {
      return Result.failure(StorageFailure(e.message));
    }
  }
}
