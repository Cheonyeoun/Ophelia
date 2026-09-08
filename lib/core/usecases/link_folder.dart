import '../domain/local_file_source_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Picks a folder and remembers it as a linked local music source.
///
/// Returns the linked path on success, or `null` if the user cancelled
/// the picker — a cancellation is not a failure, so the caller (see
/// features/local_files/local_files_screen.dart) can tell "nothing to do"
/// apart from "something went wrong."
class LinkFolder {
  final LocalFileSourcePort localFileSource;

  LinkFolder(this.localFileSource);

  Future<Result<String?, Failure>> call() async {
    final pickResult = await localFileSource.pickFolder();
    final String? pathOrUri;
    switch (pickResult) {
      case Success(value: final v):
        pathOrUri = v;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }
    if (pathOrUri == null) return const Result.success(null);

    final linkResult = await localFileSource.linkFolder(pathOrUri);
    return switch (linkResult) {
      Success() => Result.success(pathOrUri),
      ResultFailure(failure: final f) => Result.failure(f),
    };
  }
}
