import 'package:test/test.dart';
import 'package:ophelia/core/usecases/export_library.dart';
import 'package:ophelia/data/fakes/fake_export_import_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('exports a bundle of bytes', () async {
    final exportImport = FakeExportImportPort();
    final exportLibrary = ExportLibrary(exportImport);

    final bytes = unwrapValue(await exportLibrary());

    expect(bytes, isNotEmpty);
  });
}
