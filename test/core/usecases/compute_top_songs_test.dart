import 'package:test/test.dart';
import 'package:ophelia/core/domain/listening_event.dart';
import 'package:ophelia/core/usecases/compute_top_songs.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/data/fakes/sample_data.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test(
    'ranks track ids by play count within the window, most-played first',
    () async {
      final library = FakeLocalLibraryPort(
        listeningEvents: buildSampleListeningEvents(),
      );
      final computeTopSongs = ComputeTopSongs(library);

      final ranked = unwrapValue(
        await computeTopSongs(window: const Duration(days: 7)),
      );

      expect(ranked, ['t1', 't5', 't2', 't4', 't3']);
    },
  );

  test('excludes events outside the window', () async {
    final library = FakeLocalLibraryPort(
      listeningEvents: [
        ListeningEvent(
          trackId: 't3',
          playedAt: DateTime.now().subtract(const Duration(days: 10)),
          msPlayed: 1000,
        ),
      ],
    );
    final computeTopSongs = ComputeTopSongs(library);

    final ranked = unwrapValue(
      await computeTopSongs(window: const Duration(days: 7)),
    );

    expect(ranked, isEmpty);
  });

  test('respects the limit parameter', () async {
    final library = FakeLocalLibraryPort(
      listeningEvents: buildSampleListeningEvents(),
    );
    final computeTopSongs = ComputeTopSongs(library);

    final ranked = unwrapValue(
      await computeTopSongs(window: const Duration(days: 7), limit: 2),
    );

    expect(ranked, hasLength(2));
  });
}
