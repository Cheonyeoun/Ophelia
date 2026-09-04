import 'package:test/test.dart';
import 'package:ophelia/core/domain/settings.dart';
import 'package:ophelia/core/usecases/toggle_wifi_only_downloads.dart';
import 'package:ophelia/data/fakes/fake_settings_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('toggles Wi-Fi-only downloads off, and persists it', () async {
    final port = FakeSettingsPort(
      settings: Settings.defaults.copyWith(wifiOnlyDownloads: true),
    );
    final toggleWifiOnlyDownloads = ToggleWifiOnlyDownloads(port);

    final updated = unwrapValue(await toggleWifiOnlyDownloads());

    expect(updated.wifiOnlyDownloads, isFalse);
    final persisted = unwrapValue(await port.getSettings());
    expect(persisted.wifiOnlyDownloads, isFalse);
  });

  test('toggles Wi-Fi-only downloads back on', () async {
    final port = FakeSettingsPort(
      settings: Settings.defaults.copyWith(wifiOnlyDownloads: false),
    );
    final toggleWifiOnlyDownloads = ToggleWifiOnlyDownloads(port);

    final updated = unwrapValue(await toggleWifiOnlyDownloads());

    expect(updated.wifiOnlyDownloads, isTrue);
  });

  test('leaves other fields untouched', () async {
    final seed = Settings.defaults.copyWith(downloadQuality: 'Standard');
    final port = FakeSettingsPort(settings: seed);
    final toggleWifiOnlyDownloads = ToggleWifiOnlyDownloads(port);

    final updated = unwrapValue(await toggleWifiOnlyDownloads());

    expect(updated.streamingQuality, seed.streamingQuality);
    expect(updated.gaplessPlayback, seed.gaplessPlayback);
    expect(updated.downloadQuality, seed.downloadQuality);
    expect(updated.connectedServer, seed.connectedServer);
  });
}
