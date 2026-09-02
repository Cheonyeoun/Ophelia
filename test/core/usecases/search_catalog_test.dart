import 'package:test/test.dart';
import 'package:ophelia/core/usecases/search_catalog.dart';
import 'package:ophelia/data/fakes/fake_media_source_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('returns tracks matching the query by title', () async {
    final mediaSource = FakeMediaSourcePort();
    final searchCatalog = SearchCatalog(mediaSource);

    final tracks = unwrapValue(await searchCatalog('low tide'));

    expect(tracks, hasLength(1));
    expect(tracks.single.title, 'Low Tide');
  });

  test('returns tracks matching the query by artist, case-insensitively', () async {
    final mediaSource = FakeMediaSourcePort();
    final searchCatalog = SearchCatalog(mediaSource);

    final tracks = unwrapValue(await searchCatalog('WREN CALLAHAN'));

    expect(tracks, hasLength(2));
  });

  test('returns an empty list when nothing matches', () async {
    final mediaSource = FakeMediaSourcePort();
    final searchCatalog = SearchCatalog(mediaSource);

    final tracks = unwrapValue(await searchCatalog('nonexistent'));

    expect(tracks, isEmpty);
  });
}
