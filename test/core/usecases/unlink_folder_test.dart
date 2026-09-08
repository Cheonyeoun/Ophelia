import 'package:test/test.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/usecases/unlink_folder.dart';
import 'package:ophelia/data/fakes/fake_local_file_source_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('removes a linked folder', () async {
    final localFileSource = FakeLocalFileSourcePort(
      linkedFolders: ['/music'],
    );
    final unlinkFolder = UnlinkFolder(localFileSource);

    unwrapValue(await unlinkFolder('/music'));

    expect(unwrapValue(await localFileSource.getLinkedFolders()), isEmpty);
  });

  test('fails with NotFoundFailure for a folder that was never linked', () async {
    final localFileSource = FakeLocalFileSourcePort();
    final unlinkFolder = UnlinkFolder(localFileSource);

    final failure = unwrapFailure(await unlinkFolder('/never-linked'));

    expect(failure, isA<NotFoundFailure>());
  });
}
