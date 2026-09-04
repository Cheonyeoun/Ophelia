import 'package:test/test.dart';
import 'package:ophelia/core/domain/settings.dart';
import 'package:ophelia/core/usecases/set_streaming_quality.dart';
import 'package:ophelia/data/fakes/fake_settings_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('cycles Low -> Normal -> High -> Low, and persists it', () async {
    final port = FakeSettingsPort(
      settings: Settings.defaults.copyWith(streamingQuality: 'Low'),
    );
    final setStreamingQuality = SetStreamingQuality(port);

    final afterFirst = unwrapValue(await setStreamingQuality());
    expect(afterFirst.streamingQuality, 'Normal');

    final afterSecond = unwrapValue(await setStreamingQuality());
    expect(afterSecond.streamingQuality, 'High');

    final afterThird = unwrapValue(await setStreamingQuality());
    expect(afterThird.streamingQuality, 'Low');

    final persisted = unwrapValue(await port.getSettings());
    expect(persisted.streamingQuality, 'Low');
  });

  test('leaves other fields untouched', () async {
    final seed = Settings.defaults.copyWith(
      gaplessPlayback: false,
      wifiOnlyDownloads: false,
    );
    final port = FakeSettingsPort(settings: seed);
    final setStreamingQuality = SetStreamingQuality(port);

    final updated = unwrapValue(await setStreamingQuality());

    expect(updated.gaplessPlayback, seed.gaplessPlayback);
    expect(updated.downloadQuality, seed.downloadQuality);
    expect(updated.wifiOnlyDownloads, seed.wifiOnlyDownloads);
    expect(updated.connectedServer, seed.connectedServer);
  });
}
