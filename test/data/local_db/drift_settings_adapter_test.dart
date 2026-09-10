import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:ophelia/core/domain/settings.dart';
import 'package:ophelia/data/local_db/database.dart';
import 'package:ophelia/data/local_db/drift_settings_adapter.dart';

import '../../support/result_test_helpers.dart';

void main() {
  // See the identical note in drift_library_adapter_test.dart -- every
  // test below opens its own isolated in-memory OpheliaDatabase.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late OpheliaDatabase database;
  late DriftSettingsAdapter adapter;

  setUp(() {
    database = OpheliaDatabase(NativeDatabase.memory());
    adapter = DriftSettingsAdapter(database);
  });

  tearDown(() => database.close());

  test('getSettings returns Settings.defaults before anything has ever been '
      'saved, rather than a NotFoundFailure', () async {
    final settings = unwrapValue(await adapter.getSettings());
    expect(settings, Settings.defaults);
  });

  test('saveSettings creates the row when none exists yet', () async {
    final saved = Settings.defaults.copyWith(streamingQuality: 'Low');

    unwrapValue(await adapter.saveSettings(saved));

    expect(unwrapValue(await adapter.getSettings()), saved);
  });

  test('saveSettings updates the existing row rather than creating a second '
      'one', () async {
    await adapter.saveSettings(
      Settings.defaults.copyWith(streamingQuality: 'Low'),
    );
    await adapter.saveSettings(
      Settings.defaults.copyWith(streamingQuality: 'Normal'),
    );

    expect(unwrapValue(await adapter.getSettings()).streamingQuality, 'Normal');

    final rows = await database.select(database.appSettings).get();
    expect(rows, hasLength(1));
  });

  test(
    'saveSettings persists every field, not just the one that changed',
    () async {
      final saved = const Settings(
        streamingQuality: 'Low',
        gaplessPlayback: false,
        downloadQuality: 'Normal',
        wifiOnlyDownloads: false,
        connectedServer: 'Away library',
        immersiveHudAutoHideDelay: 'Off',
      );

      await adapter.saveSettings(saved);

      expect(unwrapValue(await adapter.getSettings()), saved);
    },
  );

  test('two concurrent saveSettings calls -- neither awaited before the '
      'other starts -- still leave exactly one settings row, not a '
      'constraint violation or two rows', () async {
    await Future.wait([
      adapter.saveSettings(Settings.defaults.copyWith(streamingQuality: 'Low')),
      adapter.saveSettings(
        Settings.defaults.copyWith(streamingQuality: 'Normal'),
      ),
    ]);

    final rows = await database.select(database.appSettings).get();
    expect(rows, hasLength(1));

    final settings = unwrapValue(await adapter.getSettings());
    expect(['Low', 'Normal'], contains(settings.streamingQuality));
  });

  test('settings persist across a simulated app restart -- a fresh '
      'DriftSettingsAdapter/OpheliaDatabase pair reading back what a prior '
      'one saved, the same way main.dart constructs a fresh pair on every '
      'real launch', () async {
    final executor = NativeDatabase.memory();
    final firstDatabase = OpheliaDatabase(executor);
    final firstAdapter = DriftSettingsAdapter(firstDatabase);
    await firstAdapter.saveSettings(
      Settings.defaults.copyWith(
        streamingQuality: 'Low',
        immersiveHudAutoHideDelay: '8s',
      ),
    );

    // Not `firstDatabase.close()` -- an in-memory database's contents
    // don't survive that, unlike the real file-backed connection this
    // simulates -- just a second wrapper over the same underlying
    // connection, proving the read comes from the database itself and
    // not from something the first adapter/database instance happened
    // to be holding onto in memory.
    final secondDatabase = OpheliaDatabase(executor);
    final secondAdapter = DriftSettingsAdapter(secondDatabase);

    final settings = unwrapValue(await secondAdapter.getSettings());
    expect(settings.streamingQuality, 'Low');
    expect(settings.immersiveHudAutoHideDelay, '8s');

    await secondDatabase.close();
  });
}
