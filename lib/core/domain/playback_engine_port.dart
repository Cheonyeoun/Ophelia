import '../error/failure.dart';
import '../error/result.dart';
import 'track.dart';

/// Port for controlling audio playback, abstracting over "streamed" vs.
/// "downloaded" sources (see docs/architecture.md §3.1, §7). Implemented
/// by an adapter under lib/playback/engine/ (see §3.3) — the domain only
/// depends on this interface.
abstract interface class PlaybackEnginePort {
  /// Plays [track] from [sourcePath] — a stream URL or a local file path.
  Future<Result<void, Failure>> play(Track track, String sourcePath);

  Future<Result<void, Failure>> pause();

  Future<Result<void, Failure>> seek(Duration position);

  Future<Result<void, Failure>> skipNext();

  Future<Result<void, Failure>> skipPrevious();

  Future<Result<void, Failure>> setQueue(List<Track> tracks);
}
