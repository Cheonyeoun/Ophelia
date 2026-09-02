import '../domain/local_library_port.dart';
import '../domain/playback_engine_port.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';
import 'listening_session.dart';

/// Skips to the next track in the queue, finalizing the outgoing track's
/// listening session (recording its actual elapsed time) and starting a
/// new one for [nextTrack].
///
/// [nextTrack] is the track the queue is skipping to. `PlaybackEnginePort`
/// has no way to report what its internally-managed queue advanced to, so
/// the caller — which already knows the queue (e.g. from `PlaybackState`)
/// — supplies it.
class SkipNext {
  final PlaybackEnginePort playback;
  final LocalLibraryPort library;
  final ListeningSession session;

  SkipNext(this.playback, this.library, this.session);

  Future<Result<void, Failure>> call(Track nextTrack) async {
    final skipResult = await playback.skipNext();
    switch (skipResult) {
      case Success():
        break;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }

    final event = session.finish();
    if (event != null) {
      final recordResult = await library.recordListeningEvent(event);
      switch (recordResult) {
        case Success():
          break;
        case ResultFailure(failure: final f):
          return Result.failure(f);
      }
    }

    session.start(nextTrack.id);
    return const Result.success(null);
  }
}
