import 'package:test/test.dart';
import 'package:ophelia/core/domain/local_file_source_port.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/error/result.dart';
import 'package:ophelia/core/usecases/link_folder.dart';
import 'package:ophelia/data/fakes/fake_local_file_source_port.dart';

import '../../support/result_test_helpers.dart';

/// Wraps a [FakeLocalFileSourcePort], but always fails [linkFolder] --
/// lets a test prove a picked folder that fails to persist doesn't get
/// reported as if the user had cancelled (both would otherwise look like
/// a `null`/success from the picker alone).
class _LinkFailingSource implements LocalFileSourcePort {
  final FakeLocalFileSourcePort inner;

  _LinkFailingSource(this.inner);

  @override
  Future<Result<void, Failure>> linkFolder(String pathOrUri) async {
    return Result.failure(const StorageFailure('could not persist folder'));
  }

  @override
  Future<Result<String?, Failure>> pickFolder() => inner.pickFolder();

  @override
  Future<Result<List<Track>, Failure>> scanFolder(String pathOrUri) =>
      inner.scanFolder(pathOrUri);

  @override
  Future<Result<List<String>, Failure>> getLinkedFolders() =>
      inner.getLinkedFolders();

  @override
  Future<Result<void, Failure>> removeLinkedFolder(String pathOrUri) =>
      inner.removeLinkedFolder(pathOrUri);

  @override
  Future<Result<String, Failure>> getSourcePath(String trackId) =>
      inner.getSourcePath(trackId);

  @override
  Future<Result<bool, Failure>> sourceExists(String trackId) =>
      inner.sourceExists(trackId);
}

void main() {
  test('picks and links a folder, returning its path', () async {
    final localFileSource = FakeLocalFileSourcePort(
      nextPickedFolder: '/music',
    );
    final linkFolder = LinkFolder(localFileSource);

    final path = unwrapValue(await linkFolder());

    expect(path, '/music');
    expect(
      unwrapValue(await localFileSource.getLinkedFolders()),
      ['/music'],
    );
  });

  test(
    'returns a null success, without linking anything, when the user '
    'cancels the picker',
    () async {
      final localFileSource = FakeLocalFileSourcePort();
      final linkFolder = LinkFolder(localFileSource);

      final path = unwrapValue(await linkFolder());

      expect(path, isNull);
      expect(unwrapValue(await localFileSource.getLinkedFolders()), isEmpty);
    },
  );

  test('propagates a failure from the picker itself', () async {
    final localFileSource = _FailingPickSource();
    final linkFolder = LinkFolder(localFileSource);

    final failure = unwrapFailure(await linkFolder());

    expect(failure, isA<StorageFailure>());
  });

  test(
    'propagates a failure when persisting the picked folder fails, '
    'rather than reporting it as a cancellation',
    () async {
      final inner = FakeLocalFileSourcePort(nextPickedFolder: '/music');
      final localFileSource = _LinkFailingSource(inner);
      final linkFolder = LinkFolder(localFileSource);

      final failure = unwrapFailure(await linkFolder());

      expect(failure, isA<StorageFailure>());
    },
  );
}

class _FailingPickSource implements LocalFileSourcePort {
  @override
  Future<Result<String?, Failure>> pickFolder() async {
    return Result.failure(const StorageFailure('picker failed'));
  }

  @override
  Future<Result<void, Failure>> linkFolder(String pathOrUri) =>
      throw UnimplementedError('should not be called');

  @override
  Future<Result<List<Track>, Failure>> scanFolder(String pathOrUri) =>
      throw UnimplementedError();

  @override
  Future<Result<List<String>, Failure>> getLinkedFolders() =>
      throw UnimplementedError();

  @override
  Future<Result<void, Failure>> removeLinkedFolder(String pathOrUri) =>
      throw UnimplementedError();

  @override
  Future<Result<String, Failure>> getSourcePath(String trackId) =>
      throw UnimplementedError();

  @override
  Future<Result<bool, Failure>> sourceExists(String trackId) =>
      throw UnimplementedError();
}
