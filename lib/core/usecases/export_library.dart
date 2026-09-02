import 'dart:typed_data';

import '../domain/export_import_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Exports the local library as a portable `.ophelia` bundle (see
/// docs/architecture.md §5.4).
class ExportLibrary {
  final ExportImportPort exportImport;

  ExportLibrary(this.exportImport);

  Future<Result<Uint8List, Failure>> call() => exportImport.exportBundle();
}
