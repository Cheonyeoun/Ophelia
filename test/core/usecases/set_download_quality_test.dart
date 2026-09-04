import 'package:test/test.dart';
import 'package:ophelia/core/domain/settings.dart';
import 'package:ophelia/core/usecases/set_download_quality.dart';
import 'package:ophelia/data/fakes/fake_settings_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test(
    'cycles Standard -> High -> Lossless -> Standard, and persists it',
    () async {
      final port = FakeSettingsPort(
        settings: Settings.defaults.copyWith(downloadQuality: 'Standard'),
      );
      final setDownloadQuality = SetDownloadQuality(port);

      final afterFirst = unwrapValue(await setDownloadQuality());
      expect(afterFirst.downloadQuality, 'High');

      final afterSecond = unwrapValue(await setDownloadQuality());
      expect(afterSecond.downloadQuality, 'Lossless');

      final afterThird = unwrapValue(await setDownloadQuality());
      expect(afterThird.downloadQuality, 'Standard');

      final persisted = unwrapValue(await port.getSettings());
      expect(persisted.downloadQuality, 'Standard');
    },
  );

  test('leaves other fields untouched', () async {
    final seed = Settings.defaults.copyWith(connectedServer: 'Backup library');
    final port = FakeSettingsPort(settings: seed);
    final setDownloadQuality = SetDownloadQuality(port);

    final updated = unwrapValue(await setDownloadQuality());

    expect(updated.streamingQuality, seed.streamingQuality);
    expect(updated.gaplessPlayback, seed.gaplessPlayback);
    expect(updated.wifiOnlyDownloads, seed.wifiOnlyDownloads);
    expect(updated.connectedServer, seed.connectedServer);
  });
}
