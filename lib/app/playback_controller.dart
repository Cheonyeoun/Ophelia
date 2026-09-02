import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/domain/playback_state.dart';
import '../core/domain/playlist.dart';
import '../core/domain/track.dart';
import '../core/error/result.dart';
import 'providers.dart';

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
/// through ports/fakes directly (docs/architecture.md §3.4). This is also
/// the one place that tracks queue position, since `PlaybackEnginePort`
/// has no "what's next" query (see core/usecases/skip_next.dart).
///
/// Failures from the underlying use cases are not yet surfaced to the UI
/// (e.g. as a snackbar) — every method just leaves the state unchanged on
/// failure. Not solved here.
class PlaybackController extends Notifier<PlaybackUiState> {
  int _queueIndex = -1;

  @override
  PlaybackUiState build() => PlaybackUiState.initial();

  /// Plays [track]. When [queue] is given, it becomes the active queue —
  /// e.g. the track list a screen played this track from — so
  /// skipNext/skipPrevious have somewhere to go; otherwise the queue is
  /// just [track] on its own.
  Future<void> play(Track track, {List<Track>? queue}) async {
    final result = await ref.read(playTrackProvider)(track);
    if (result case ResultFailure()) return;

    final effectiveQueue = queue ?? [track];
    _queueIndex = effectiveQueue.indexOf(track);
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

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else if (state.playback.currentTrack != null) {
      await play(state.playback.currentTrack!, queue: state.playback.queue);
    }
  }

  Future<void> skipNext() async {
    final queue = state.playback.queue;
    if (_queueIndex < 0 || _queueIndex >= queue.length - 1) return;
    final next = queue[_queueIndex + 1];

    final result = await ref.read(skipNextProvider)(next);
    if (result case ResultFailure()) return;

    _queueIndex++;
    state = state.copyWith(
      playback: state.playback.copyWith(
        currentTrack: next,
        position: Duration.zero,
      ),
      isPlaying: true,
    );
  }

  Future<void> skipPrevious() async {
    final queue = state.playback.queue;
    if (_queueIndex <= 0 || _queueIndex >= queue.length) return;
    final previous = queue[_queueIndex - 1];

    final result = await ref.read(skipPreviousProvider)(previous);
    if (result case ResultFailure()) return;

    _queueIndex--;
    state = state.copyWith(
      playback: state.playback.copyWith(
        currentTrack: previous,
        position: Duration.zero,
      ),
      isPlaying: true,
    );
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
}

final playbackControllerProvider =
    NotifierProvider<PlaybackController, PlaybackUiState>(
  PlaybackController.new,
);
