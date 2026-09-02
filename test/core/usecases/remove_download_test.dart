import 'package:test/test.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/usecases/remove_download.dart';
import 'package:ophelia/data/fakes/fake_download_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('deletes a downloaded track', () async {
    final downloads = FakeDownloadPort();
    final removeDownload = RemoveDownload(downloads);

    unwrapValue(await removeDownload('t1'));

    expect(unwrapValue(await downloads.isDownloaded('t1')), isFalse);
  });

  test('propagates a failure for a track that was never downloaded', () async {
    final downloads = FakeDownloadPort(seed: []);
    final removeDownload = RemoveDownload(downloads);

    final failure = unwrapFailure(await removeDownload('t1'));

    expect(failure, isA<NotFoundFailure>());
  });
}
