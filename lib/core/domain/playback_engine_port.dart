import '../error/failure.dart';
import '../error/result.dart';
import 'playback_state.dart';
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

  /// Advances to the next track per the engine's own queue position,
  /// shuffle, and repeat mode, and returns the track it landed on — the
  /// caller has no way to predict this itself once shuffle is involved.
  Future<Result<Track, Failure>> skipNext();

  /// The previous-track equivalent of [skipNext].
  Future<Result<Track, Failure>> skipPrevious();

  Future<Result<void, Failure>> setQueue(List<Track> tracks);

  /// Enables or disables shuffled playback order for [skipNext] and
  /// [skipPrevious].
  Future<Result<void, Failure>> setShuffle(bool enabled);

  /// Sets what happens once [skipNext]/[skipPrevious] would otherwise run
  /// out of queue.
  Future<Result<void, Failure>> setRepeatMode(RepeatMode repeatMode);
}
