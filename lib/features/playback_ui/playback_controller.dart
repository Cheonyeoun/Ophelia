import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/domain/playback_state.dart';
import '../../core/domain/playlist.dart';
import '../../core/domain/track.dart';
import '../../core/error/result.dart';
import '../../core/usecases/toggle_repeat_mode.dart';

/// Presentation-layer view of playback: the domain [PlaybackState] plus
/// `isPlaying`, which the domain entity doesn't track (see
/// docs/architecture.md §3.1) — this is UI state, not something a port
/// needs to expose.
class PlaybackUiState {
  final PlaybackState playback;
  final bool isPlaying;

  const PlaybackUiState({required this.playback, required this.isPlaying});

  factory PlaybackUiState.initial() => PlaybackUiState(
        playback: PlaybackState(
          position: Duration.zero,
          queue: const [],
          isImmersive: false,
          repeatMode: RepeatMode.off,
          shuffle: false,
        ),
        isPlaying: false,
      );

  PlaybackUiState copyWith({PlaybackState? playback, bool? isPlaying}) {
    return PlaybackUiState(
      playback: playback ?? this.playback,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

/// Coordinates the playback use cases and exposes the result to screens
/// via Riverpod — screens call use cases through this controller, never
/// through ports/fakes directly (docs/architecture.md §3.4). The engine
/// (not this controller) tracks queue position, since it also has to
/// decide the next index under shuffle/repeat — see
/// core/usecases/skip_next.dart.
///
/// Failures from the underlying use cases are not yet surfaced to the UI
/// (e.g. as a snackbar) — every method just leaves the state unchanged on
/// failure. Not solved here.
class PlaybackController extends Notifier<PlaybackUiState> {
  @override
  PlaybackUiState build() => PlaybackUiState.initial();

  /// Plays [track]. When [queue] is given, it becomes the active queue —
  /// e.g. the track list a screen played this track from — so
  /// skipNext/skipPrevious have somewhere to go; otherwise the queue is
  /// just [track] on its own. [queueIndex] is [track]'s position within
  /// that queue — the caller (e.g. the screen that built the list [track]
  /// came from) is the one place that unambiguously knows this, so it's
  /// passed through rather than re-derived by searching the queue for a
  /// value-equal track (see core/domain/playback_engine_port.dart).
  Future<void> play(
    Track track, {
    List<Track>? queue,
    int queueIndex = 0,
  }) async {
    final effectiveQueue = queue ?? [track];
    final result = await ref.read(playTrackProvider)(
      track,
      queue: effectiveQueue,
      queueIndex: queueIndex,
    );
    if (result case ResultFailure()) return;

    state = state.copyWith(
      playback: state.playback.copyWith(
        currentTrack: track,
        position: Duration.zero,
        queue: effectiveQueue,
      ),
      isPlaying: true,
    );
  }

  /// Resolves [playlist] to tracks and starts playing it from the top.
  Future<void> playPlaylist(Playlist playlist) async {
    final result = await ref.read(buildQueueProvider)(playlist);
    switch (result) {
      case Success(value: final tracks):
        if (tracks.isEmpty) return;
        await play(tracks.first, queue: tracks);
      case ResultFailure():
        return;
    }
  }

  Future<void> pause() async {
    final result = await ref.read(pauseTrackProvider)();
    if (result case ResultFailure()) return;
    state = state.copyWith(isPlaying: false);
  }

  /// Resumes the already-loaded current track via `ResumeTrack` — unlike
  /// [play], this never re-commits the queue, so it can't reset shuffle
  /// history the way re-entering [play] on resume used to (see
  /// core/usecases/resume_track.dart).
  Future<void> resume() async {
    final track = state.playback.currentTrack;
    if (track == null) return;
    final result = await ref.read(resumeTrackProvider)(track);
    if (result case ResultFailure()) return;
    state = state.copyWith(isPlaying: true);
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else if (state.playback.currentTrack != null) {
      await resume();
    }
  }

  Future<void> skipNext() async {
    final result = await ref.read(skipNextProvider)();
    switch (result) {
      case Success(value: final track):
        state = state.copyWith(
          playback: state.playback.copyWith(
            currentTrack: track,
            position: Duration.zero,
          ),
          isPlaying: true,
        );
      case ResultFailure():
        return;
    }
  }

  Future<void> skipPrevious() async {
    final result = await ref.read(skipPreviousProvider)();
    switch (result) {
      case Success(value: final track):
        state = state.copyWith(
          playback: state.playback.copyWith(
            currentTrack: track,
            position: Duration.zero,
          ),
          isPlaying: true,
        );
      case ResultFailure():
        return;
    }
  }

  Future<void> seekBy(Duration offset) async {
    final result = await ref.read(seekByProvider)(
      currentPosition: state.playback.position,
      offset: offset,
    );
    if (result case ResultFailure()) return;

    final target = state.playback.position + offset;
    state = state.copyWith(
      playback: state.playback.copyWith(
        position: target < Duration.zero ? Duration.zero : target,
      ),
    );
  }

  void toggleImmersive() {
    state = state.copyWith(
      playback: ref.read(toggleImmersiveProvider)(state.playback),
    );
  }

  /// Toggles shuffle. The target value is computed synchronously, from
  /// [state] as it is right now, *before* the `await` below — and applied
  /// to [state] immediately — rather than read again once the engine call
  /// resolves. Otherwise two rapid taps both read the same pre-toggle
  /// [state] (the first tap's own update hasn't landed yet while its
  /// `await` is in flight) and compute the same target, instead of each
  /// toggling from the other's result.
  ///
  /// On failure, only the `shuffle` field is flipped back — read off
  /// [state] as it is *at that point*, not the `previous` snapshot from
  /// before the `await`. Restoring the whole snapshot would clobber any
  /// other change (a skip, a seek, another toggle) that completed on
  /// [state] while this call was awaiting the engine.
  Future<void> toggleShuffle() async {
    final previous = state.playback;
    final target = !previous.shuffle;
    state = state.copyWith(playback: previous.copyWith(shuffle: target));

    final result = await ref.read(toggleShuffleProvider)(previous);
    if (result case ResultFailure()) {
      state = state.copyWith(
        playback: state.playback.copyWith(shuffle: previous.shuffle),
      );
    }
  }

  /// The repeat-mode equivalent of [toggleShuffle] — see its doc comment
  /// for why the target is computed synchronously up front and why a
  /// failure only flips `repeatMode` back on the live [state], not a
  /// pre-await snapshot.
  Future<void> toggleRepeatMode() async {
    final previous = state.playback;
    final target = ToggleRepeatMode.next(previous.repeatMode);
    state = state.copyWith(playback: previous.copyWith(repeatMode: target));

    final result = await ref.read(toggleRepeatModeProvider)(previous);
    if (result case ResultFailure()) {
      state = state.copyWith(
        playback: state.playback.copyWith(repeatMode: previous.repeatMode),
      );
    }
  }
}

final playbackControllerProvider =
    NotifierProvider<PlaybackController, PlaybackUiState>(
  PlaybackController.new,
);
