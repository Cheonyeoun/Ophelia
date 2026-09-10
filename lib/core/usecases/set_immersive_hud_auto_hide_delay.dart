import '../domain/settings.dart';
import '../domain/settings_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Cycles Immersive Play's HUD auto-hide delay 3s -> 5s -> 8s -> Off -> 3s,
/// persisting the result via [SettingsPort]. `Off` disables auto-hide
/// entirely -- the header, title/artist, scrubber, and transport controls
/// stay visible for the whole session, the same as before this feature
/// existed.
class SetImmersiveHudAutoHideDelay {
  final SettingsPort settings;

  SetImmersiveHudAutoHideDelay(this.settings);

  static const _options = ['3s', '5s', '8s', 'Off'];

  /// The delay [current] cycles to next. Pure and synchronous, mirroring
  /// `SetStreamingQuality.next` (see that use case for why a caller might
  /// want this exposed independently of [call]).
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
      immersiveHudAutoHideDelay: next(current.immersiveHudAutoHideDelay),
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

/// Parses one of [SetImmersiveHudAutoHideDelay]'s own option strings back
/// into a [Duration] -- `null` for `'Off'`, meaning "never auto-hide."
/// Kept next to the use case that owns the string format, rather than in
/// the widget that consumes it, so the two can never drift out of sync.
Duration? parseImmersiveHudAutoHideDelay(String value) {
  if (value == 'Off') return null;
  return Duration(seconds: int.parse(value.substring(0, value.length - 1)));
}
