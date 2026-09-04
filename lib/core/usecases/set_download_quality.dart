import '../domain/settings.dart';
import '../domain/settings_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Cycles download quality Standard -> High -> Lossless -> Standard,
/// persisting the result via [SettingsPort].
class SetDownloadQuality {
  final SettingsPort settings;

  SetDownloadQuality(this.settings);

  static const _options = ['Standard', 'High', 'Lossless'];

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
      downloadQuality: next(current.downloadQuality),
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
