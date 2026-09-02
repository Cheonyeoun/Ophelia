import 'dart:convert';
import 'dart:typed_data';

import '../../core/domain/export_import_port.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import 'sample_data.dart';

/// **Temporary, UI-development-only fake — not a production adapter.**
///
/// In-memory stand-in for [ExportImportPort]. Produces a small synthetic
/// byte payload on export and just remembers the last imported bundle —
/// no real `.ophelia` zip format, no disk I/O — before a real adapter
/// exists under lib/data/export_import/.
class FakeExportImportPort implements ExportImportPort {
  Uint8List? lastImportedBundle;

  @override
  Future<Result<Uint8List, Failure>> exportBundle() async {
    final payload = 'ophelia-bundle:tracks=${sampleTracks.length}';
    return Result.success(Uint8List.fromList(utf8.encode(payload)));
  }

  @override
  Future<Result<void, Failure>> importBundle(Uint8List bundle) async {
    lastImportedBundle = bundle;
    return const Result.success(null);
  }
}
