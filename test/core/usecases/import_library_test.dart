import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:ophelia/core/usecases/import_library.dart';
import 'package:ophelia/data/fakes/fake_export_import_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('imports a bundle of bytes', () async {
    final exportImport = FakeExportImportPort();
    final importLibrary = ImportLibrary(exportImport);
    final bundle = Uint8List.fromList([1, 2, 3]);

    unwrapValue(await importLibrary(bundle));

    expect(exportImport.lastImportedBundle, bundle);
  });
}
