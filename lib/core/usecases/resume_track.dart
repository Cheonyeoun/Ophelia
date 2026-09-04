import '../domain/playback_engine_port.dart';
import '../domain/track.dart';
import '../error/failure.dart';
import '../error/result.dart';
import 'listening_session.dart';

/// Resumes [track] — already loaded, just paused — via
/// `PlaybackEnginePort.resume` rather than `play`, so resuming never
/// re-commits a queue or resets shuffle history the way starting a fresh
/// play would (see playback_engine_port.dart's `resume`). Starts a new
/// listening-session segment for the resumed track, mirroring how `play`
/// starts one for a freshly-played track.
class ResumeTrack {
  final PlaybackEnginePort playback;
  final ListeningSession session;

  ResumeTrack(this.playback, this.session);

  Future<Result<void, Failure>> call(Track track) async {
    final result = await playback.resume();
    switch (result) {
      case Success():
        break;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }

    session.start(track.id);
    return const Result.success(null);
  }
}
