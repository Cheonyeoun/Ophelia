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
  ///
  /// [queueIndex] is [track]'s position within whatever queue was just set
  /// via [setQueue], passed explicitly by the caller (see
  /// core/usecases/play_track.dart) rather than searched for by value —
  /// a value-equality search can't disambiguate a track that appears more
  /// than once in the queue, the same class of bug already fixed in
  /// [skipNext]/[skipPrevious] by tracking position with an index instead
  /// of matching on the track itself.
  Future<Result<void, Failure>> play(
    Track track,
    String sourcePath, {
    int queueIndex = 0,
  });

  /// Resumes whatever track is already loaded — e.g. after [pause] — at
  /// its current position, without touching the queue or shuffle history
  /// the way a fresh [play] call does. See
  /// app/playback_controller.dart's `togglePlayPause`.
  Future<Result<void, Failure>> resume();

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

  /// The engine's current queue — read, not just written, so a caller
  /// (e.g. `PlayTrack`) can capture it before committing a new one and
  /// restore it if a later step fails, instead of leaving the engine
  /// navigating a queue the UI never actually reflected.
  List<Track> get queue;
}
