import 'dart:io';

import '../error/failure.dart';
import '../error/result.dart';

/// Port for exporting/importing the local library as a portable `.ophelia`
/// bundle (see Docs/Architecture.md §3.1, §5.4). Implemented by an adapter
/// under lib/data/export_import/ (see §3.3) — the domain only depends on
/// this interface.
///
/// Uses dart:io's [File] directly, matching the signature in §3.1 — this
/// is a core Dart SDK type, not a Flutter or pub package import.
abstract interface class ExportImportPort {
  Future<Result<File, Failure>> exportBundle();

  Future<Result<void, Failure>> importBundle(File file);
}
