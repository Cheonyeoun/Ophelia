import 'package:test/test.dart';
import 'package:ophelia/core/domain/settings.dart';
import 'package:ophelia/core/usecases/set_connected_server.dart';
import 'package:ophelia/data/fakes/fake_settings_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test(
    'cycles Home library -> Backup library -> Home library, and persists '
    'it',
    () async {
      final port = FakeSettingsPort(
        settings: Settings.defaults.copyWith(connectedServer: 'Home library'),
      );
      final setConnectedServer = SetConnectedServer(port);

      final afterFirst = unwrapValue(await setConnectedServer());
      expect(afterFirst.connectedServer, 'Backup library');

      final afterSecond = unwrapValue(await setConnectedServer());
      expect(afterSecond.connectedServer, 'Home library');

      final persisted = unwrapValue(await port.getSettings());
      expect(persisted.connectedServer, 'Home library');
    },
  );

  test('leaves other fields untouched', () async {
    final seed = Settings.defaults.copyWith(streamingQuality: 'Normal');
    final port = FakeSettingsPort(settings: seed);
    final setConnectedServer = SetConnectedServer(port);

    final updated = unwrapValue(await setConnectedServer());

    expect(updated.streamingQuality, seed.streamingQuality);
    expect(updated.gaplessPlayback, seed.gaplessPlayback);
    expect(updated.downloadQuality, seed.downloadQuality);
    expect(updated.wifiOnlyDownloads, seed.wifiOnlyDownloads);
  });
}
