import '../error/failure.dart';
import '../error/result.dart';
import 'playback_state.dart';
import 'track.dart';

/// Opaque token capturing everything [PlaybackEnginePort] tracks about
/// where playback is *positioned* — queue, current index, shuffle
/// history — at the moment [PlaybackEnginePort.captureNavigationState]
/// was called. Each adapter defines its own concrete subtype; a token is
/// only ever passed back to the same engine instance that produced it,
/// via [PlaybackEnginePort.restoreNavigationState].
abstract interface class PlaybackNavigationSnapshot {}

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
  ///
  /// An adapter must reject a [queueIndex] outside the current queue's
  /// bounds (or an empty queue) with a [Result.failure] rather than
  /// letting it crash on first use, leaving all state untouched.
  Future<Result<void, Failure>> play(
    Track track,
    String sourcePath, {
    int queueIndex = 0,
  });

  /// Resumes whatever track is already loaded — e.g. after [pause] — at
  /// its current position, without touching the queue or shuffle history
  /// the way a fresh [play] call does. See
  /// features/playback_ui/playback_controller.dart's `togglePlayPause`.
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

  /// Captures the engine's queue, current index, and shuffle history as a
  /// single opaque token, so a caller (e.g. `PlayTrack`) can restore all
  /// of it atomically via [restoreNavigationState] if a later step fails.
  /// These three only make sense together — restoring just the queue
  /// (and leaving current index or shuffle history pointing at whatever a
  /// failed attempt left them at) can leave the engine internally
  /// inconsistent even though the queue itself looks right.
  PlaybackNavigationSnapshot captureNavigationState();

  /// Restores navigation state previously captured by
  /// [captureNavigationState], undoing whatever [setQueue], [play],
  /// [skipNext], or [skipPrevious] calls happened on this engine since —
  /// so a failed [play] can leave the engine exactly as it was before the
  /// attempt: correct current track, correct index, correct shuffle
  /// history.
  Future<Result<void, Failure>> restoreNavigationState(
    PlaybackNavigationSnapshot snapshot,
  );

  /// The current track's position within the engine's queue, or `-1` if
  /// nothing is set. The sole authority on queue position (see
  /// core/usecases/skip_next.dart) — read by `PlaybackController` after
  /// any call that might have moved it, and mirrored onto
  /// `PlaybackState.currentIndex` so the presentation layer can highlight
  /// by position instead of matching queue entries by value.
  int get currentIndex;
}
