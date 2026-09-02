import '../domain/local_library_port.dart';
import '../domain/playback_engine_port.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';
import 'listening_session.dart';

/// Skips to the previous track in the queue, finalizing the outgoing
/// track's listening session (recording its actual elapsed time) and
/// starting a new one for whatever track the engine landed on.
///
/// Returns that track: the engine (not the caller) decides what's
/// previous, since shuffle/repeat mean it isn't necessarily the prior
/// linear queue position (see docs/architecture.md §3.1's
/// `PlaybackEnginePort`).
class SkipPrevious {
  final PlaybackEnginePort playback;
  final LocalLibraryPort library;
  final ListeningSession session;

  SkipPrevious(this.playback, this.library, this.session);

  Future<Result<Track, Failure>> call() async {
    final skipResult = await playback.skipPrevious();
    final Track previous;
    switch (skipResult) {
      case Success(value: final track):
        previous = track;
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

    session.start(previous.id);
    return Result.success(previous);
  }
}
