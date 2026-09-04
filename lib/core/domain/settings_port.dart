import '../error/failure.dart';
import '../error/result.dart';
import 'settings.dart';

/// Port for reading and persisting the user's settings (see
/// docs/architecture.md §3.1). Implemented by an adapter — until a real
/// one exists, `FakeSettingsPort` under lib/data/fakes/ stands in with
/// plain in-memory storage.
abstract interface class SettingsPort {
  Future<Result<Settings, Failure>> getSettings();

  /// Persists [settings] wholesale — callers read the current value via
  /// [getSettings], apply their one change with `Settings.copyWith`, and
  /// save the result, the same read-modify-write shape
  /// `LocalLibraryPort.saveProfile` uses for `UserProfile`.
  Future<Result<void, Failure>> saveSettings(Settings settings);
}
