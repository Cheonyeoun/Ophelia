import '../domain/local_library_port.dart';
import '../domain/playback_engine_port.dart';
import '../error/failure.dart';
import '../error/result.dart';
import 'listening_session.dart';

/// Pauses whatever is currently playing, then finalizes its listening
/// session — recording a listening event with the actual elapsed time
/// (see listening_session.dart) rather than a placeholder.
class PauseTrack {
  final PlaybackEnginePort playback;
  final LocalLibraryPort library;
  final ListeningSession session;

  PauseTrack(this.playback, this.library, this.session);

  Future<Result<void, Failure>> call() async {
    final pauseResult = await playback.pause();
    switch (pauseResult) {
      case Success():
        break;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }

    final event = session.finish();
    if (event == null) return const Result.success(null);
    return library.recordListeningEvent(event);
  }
}
