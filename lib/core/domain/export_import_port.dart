import 'dart:typed_data';

import '../error/failure.dart';
import '../error/result.dart';

/// Port for exporting/importing the local library as a portable `.ophelia`
/// bundle (see docs/architecture.md §3.1, §5.4). Implemented by an adapter
/// under lib/data/export_import/ (see §3.3) — the domain only depends on
/// this interface.
///
/// Bundles are raw bytes ([Uint8List]), not a `dart:io` `File` — actual
/// file I/O belongs to the adapter, not the domain.
abstract interface class ExportImportPort {
  Future<Result<Uint8List, Failure>> exportBundle();

  Future<Result<void, Failure>> importBundle(Uint8List bundle);
}
