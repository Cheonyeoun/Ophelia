import '../domain/settings.dart';
import '../domain/settings_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Cycles the connected media server Home library -> Backup library ->
/// Home library, persisting the result via [SettingsPort].
class SetConnectedServer {
  final SettingsPort settings;

  SetConnectedServer(this.settings);

  static const _options = ['Home library', 'Backup library'];

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
      connectedServer: next(current.connectedServer),
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
