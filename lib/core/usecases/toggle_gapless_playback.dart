import '../domain/settings.dart';
import '../domain/settings_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Toggles gapless playback on/off, persisting the result via
/// [SettingsPort].
class ToggleGaplessPlayback {
  final SettingsPort settings;

  ToggleGaplessPlayback(this.settings);

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
      gaplessPlayback: !current.gaplessPlayback,
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
