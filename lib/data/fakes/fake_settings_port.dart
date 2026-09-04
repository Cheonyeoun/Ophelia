import '../../core/domain/settings.dart';
import '../../core/domain/settings_port.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';

/// **Temporary, UI-development-only fake — not a production adapter.**
///
/// In-memory stand-in for [SettingsPort], seeded with [Settings.defaults],
/// so the Settings screen has something to read and write before a real
/// adapter exists under lib/data/.
class FakeSettingsPort implements SettingsPort {
  Settings settings;

  FakeSettingsPort({this.settings = Settings.defaults});

  @override
  Future<Result<Settings, Failure>> getSettings() async {
    return Result.success(settings);
  }

  @override
  Future<Result<void, Failure>> saveSettings(Settings settings) async {
    this.settings = settings;
    return const Result.success(null);
  }
}
