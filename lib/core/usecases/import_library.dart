import 'dart:typed_data';

import '../domain/export_import_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Imports a previously exported `.ophelia` bundle (see
/// docs/architecture.md §5.4).
class ImportLibrary {
  final ExportImportPort exportImport;

  ImportLibrary(this.exportImport);

  Future<Result<void, Failure>> call(Uint8List bundle) =>
      exportImport.importBundle(bundle);
}
