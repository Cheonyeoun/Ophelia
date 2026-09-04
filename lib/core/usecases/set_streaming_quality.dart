import '../domain/settings.dart';
import '../domain/settings_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Cycles streaming quality Low -> Normal -> High -> Low, persisting the
/// result via [SettingsPort].
class SetStreamingQuality {
  final SettingsPort settings;

  SetStreamingQuality(this.settings);

  static const _options = ['Low', 'Normal', 'High'];

  /// The streaming quality [current] cycles to next. Pure and
  /// synchronous, mirroring `ToggleRepeatMode.next` (see that use case
  /// for why a caller might want this exposed independently of [call]).
  static String next(String current) =>
      _options[(_options.indexOf(current) + 1) % _options.length];

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
      streamingQuality: next(current.streamingQuality),
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
