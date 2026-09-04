import '../domain/settings.dart';
import '../domain/settings_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Toggles Wi-Fi-only downloads on/off, persisting the result via
/// [SettingsPort].
class ToggleWifiOnlyDownloads {
  final SettingsPort settings;

  ToggleWifiOnlyDownloads(this.settings);

  Future<Result<Settings, Failure>> call() async {
    final getResult = await settings.getSettings();
    final Settings current;
    switch (getResult) {
      case Success(value: final v):
        current = v;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }

    final updated = current.copyWith(
      wifiOnlyDownloads: !current.wifiOnlyDownloads,
    );
    final saveResult = await settings.saveSettings(updated);
    switch (saveResult) {
      case Success():
        return Result.success(updated);
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }
  }
}
