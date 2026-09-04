import 'package:test/test.dart';
import 'package:ophelia/core/domain/settings.dart';
import 'package:ophelia/core/usecases/toggle_gapless_playback.dart';
import 'package:ophelia/data/fakes/fake_settings_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('toggles gapless playback off, and persists it', () async {
    final port = FakeSettingsPort(
      settings: Settings.defaults.copyWith(gaplessPlayback: true),
    );
    final toggleGaplessPlayback = ToggleGaplessPlayback(port);

    final updated = unwrapValue(await toggleGaplessPlayback());

    expect(updated.gaplessPlayback, isFalse);
    final persisted = unwrapValue(await port.getSettings());
    expect(persisted.gaplessPlayback, isFalse);
  });

  test('toggles gapless playback back on', () async {
    final port = FakeSettingsPort(
      settings: Settings.defaults.copyWith(gaplessPlayback: false),
    );
    final toggleGaplessPlayback = ToggleGaplessPlayback(port);

    final updated = unwrapValue(await toggleGaplessPlayback());

    expect(updated.gaplessPlayback, isTrue);
  });

  test('leaves other fields untouched', () async {
    final seed = Settings.defaults.copyWith(streamingQuality: 'Low');
    final port = FakeSettingsPort(settings: seed);
    final toggleGaplessPlayback = ToggleGaplessPlayback(port);

    final updated = unwrapValue(await toggleGaplessPlayback());

    expect(updated.streamingQuality, seed.streamingQuality);
    expect(updated.downloadQuality, seed.downloadQuality);
    expect(updated.wifiOnlyDownloads, seed.wifiOnlyDownloads);
    expect(updated.connectedServer, seed.connectedServer);
  });
}
