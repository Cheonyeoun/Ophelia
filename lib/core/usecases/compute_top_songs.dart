import '../domain/local_library_port.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Ranks track ids by how many times they were played within [window]
/// (e.g. `Duration(days: 7)` for "top 5 this week") — a pure local
/// aggregation over [LocalLibraryPort.getListeningEvents] (see
/// docs/architecture.md §5.1).
class ComputeTopSongs {
  final LocalLibraryPort library;

  ComputeTopSongs(this.library);

  Future<Result<List<String>, Failure>> call({
    required Duration window,
    int limit = 5,
  }) async {
    final eventsResult = await library.getListeningEvents();
    switch (eventsResult) {
      case Success(value: final events):
        final cutoff = DateTime.now().subtract(window);
        final playCounts = <String, int>{};
        for (final event in events) {
          if (event.playedAt.isBefore(cutoff)) continue;
          playCounts[event.trackId] = (playCounts[event.trackId] ?? 0) + 1;
        }
        final ranked = playCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final safeLimit = limit < 0 ? 0 : limit;
        return Result.success(
          ranked.take(safeLimit).map((entry) => entry.key).toList(),
        );
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }
  }
}
