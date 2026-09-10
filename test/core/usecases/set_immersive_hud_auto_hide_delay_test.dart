import 'package:test/test.dart';
import 'package:ophelia/core/domain/settings.dart';
import 'package:ophelia/core/usecases/set_immersive_hud_auto_hide_delay.dart';
import 'package:ophelia/data/fakes/fake_settings_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('cycles 3s -> 5s -> 8s -> Off -> 3s, and persists it', () async {
    final port = FakeSettingsPort(
      settings: Settings.defaults.copyWith(immersiveHudAutoHideDelay: '3s'),
    );
    final setDelay = SetImmersiveHudAutoHideDelay(port);

    final afterFirst = unwrapValue(await setDelay());
    expect(afterFirst.immersiveHudAutoHideDelay, '5s');

    final afterSecond = unwrapValue(await setDelay());
    expect(afterSecond.immersiveHudAutoHideDelay, '8s');

    final afterThird = unwrapValue(await setDelay());
    expect(afterThird.immersiveHudAutoHideDelay, 'Off');

    final afterFourth = unwrapValue(await setDelay());
    expect(afterFourth.immersiveHudAutoHideDelay, '3s');

    final persisted = unwrapValue(await port.getSettings());
    expect(persisted.immersiveHudAutoHideDelay, '3s');
  });

  test('leaves other fields untouched', () async {
    final seed = Settings.defaults.copyWith(
      gaplessPlayback: false,
      wifiOnlyDownloads: false,
    );
    final port = FakeSettingsPort(settings: seed);
    final setDelay = SetImmersiveHudAutoHideDelay(port);

    final updated = unwrapValue(await setDelay());

    expect(updated.gaplessPlayback, seed.gaplessPlayback);
    expect(updated.downloadQuality, seed.downloadQuality);
    expect(updated.wifiOnlyDownloads, seed.wifiOnlyDownloads);
    expect(updated.connectedServer, seed.connectedServer);
    expect(updated.streamingQuality, seed.streamingQuality);
  });

  group('parseImmersiveHudAutoHideDelay', () {
    test('parses a "<n>s" option into a Duration of n seconds', () {
      expect(parseImmersiveHudAutoHideDelay('3s'), const Duration(seconds: 3));
      expect(parseImmersiveHudAutoHideDelay('8s'), const Duration(seconds: 8));
    });

    test('parses "Off" as null -- never auto-hide', () {
      expect(parseImmersiveHudAutoHideDelay('Off'), isNull);
    });
  });
}
