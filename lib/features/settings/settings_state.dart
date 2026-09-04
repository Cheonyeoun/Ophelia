import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/domain/settings.dart';
import '../../core/error/result.dart';

/// Presentation-layer Notifier over the domain [Settings] entity. Each
/// method calls exactly one use case (see
/// core/usecases/set_streaming_quality.dart and its four siblings), which
/// reads/writes through `SettingsPort` — this class holds no settings
/// logic of its own. No UI-only field needs to ride alongside [Settings]
/// the way `PlaybackController` adds `isPlaying` to `PlaybackState`, so
/// the Notifier's state is the domain entity directly rather than a
/// separate wrapper type.
class SettingsController extends Notifier<Settings> {
  @override
  Settings build() => Settings.defaults;

  Future<void> cycleStreamingQuality() async {
    final result = await ref.read(setStreamingQualityProvider)();
    if (result case Success(value: final updated)) {
      state = updated;
    }
  }

  Future<void> toggleGaplessPlayback() async {
    final result = await ref.read(toggleGaplessPlaybackProvider)();
    if (result case Success(value: final updated)) {
      state = updated;
    }
  }

  Future<void> cycleDownloadQuality() async {
    final result = await ref.read(setDownloadQualityProvider)();
    if (result case Success(value: final updated)) {
      state = updated;
    }
  }

  Future<void> toggleWifiOnlyDownloads() async {
    final result = await ref.read(toggleWifiOnlyDownloadsProvider)();
    if (result case Success(value: final updated)) {
      state = updated;
    }
  }

  Future<void> cycleConnectedServer() async {
    final result = await ref.read(setConnectedServerProvider)();
    if (result case Success(value: final updated)) {
      state = updated;
    }
  }
}
