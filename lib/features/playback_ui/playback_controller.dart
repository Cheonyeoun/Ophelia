import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/domain/playback_session_snapshot.dart';
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

/// Minimal `Future`-chaining mutex — no external package needed for
/// something this small. Each [run] call waits for every previously
/// queued [run] call to finish (success *or* failure) before its own
/// [action] starts, so calls to [PlaybackController]'s playback-mutating
/// methods can never interleave: whichever is called second simply waits
/// its turn instead of racing the first for the engine and `state`. This
/// replaces patching each individual race (a skip landing mid-toggle, two
/// concurrent plays, ...) with a single structural guarantee.
class _AsyncMutex {
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    // The next caller waits on this call finishing, not on whether it
    // succeeded — a failed action must not jam the queue for whatever's
    // queued after it.
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }
}

/// Coordinates the playback use cases and exposes the result to screens
/// via Riverpod — screens call use cases through this controller, never
/// through ports/fakes directly (docs/architecture.md §3.4). The engine
/// (not this controller) tracks queue position, since it also has to
/// decide the next index under shuffle/repeat — see
/// core/usecases/skip_next.dart. After any use case that might move that
/// position (`play`, `skipNext`, `skipPrevious`), this reads
/// `PlaybackEnginePort.currentIndex` directly — a narrow, deliberate
/// exception to "go through a use case" for a single synchronous getter,
/// just to mirror the engine's own number onto `PlaybackState` for the
/// presentation layer (see features/playback_ui/queue_screen.dart).
///
/// Every method that mutates playback state runs through [_mutex], so two
/// calls (e.g. a rapid `play` and `toggleShuffle`, or two concurrent
/// `skipNext`s) are always fully serialized rather than racing each other
/// for the engine and `state` — see [_AsyncMutex].
///
/// Failures from the underlying use cases are not yet surfaced to the UI
/// (e.g. as a snackbar) — every method just leaves the state unchanged on
/// failure. Not solved here.
class PlaybackController extends Notifier<PlaybackUiState> {
  final _mutex = _AsyncMutex();

  /// Guards [_ensureEngineStreamsSubscribed] so the engine's
  /// `positionStream`/`durationStream` are subscribed to at most once per
  /// controller lifetime, the first time anything actually plays -- not
  /// eagerly in [build], which would touch `playbackEngineProvider` (and,
  /// with the real adapter, `just_audio`/`audio_service`'s platform
  /// channels) just from mounting the app, before the user ever presses
  /// play.
  bool _engineStreamsSubscribed = false;

  /// Set by [restoreSession] and cleared once [togglePlayPause] actually
  /// loads that track into the engine — see both methods' doc comments
  /// for why a restored session needs a fresh [_play] rather than
  /// [_resume] the first time it's played.
  PlaybackSessionSnapshot? _pendingRestore;

  @override
  PlaybackUiState build() => PlaybackUiState.initial();

  /// Populates the mini-player with [snapshot] — the track, queue, and
  /// position `RestoreLastSession` found saved from last time — paused,
  /// without touching the playback engine at all. The engine is only
  /// ever given a track via [_play] (which starts loading it for real),
  /// so there is nothing to "resume" yet; the first [togglePlayPause]
  /// after this loads the track fresh and seeks to [snapshot]'s position,
  /// rather than assuming the engine already has it queued up the way a
  /// plain pause/resume cycle would.
  void restoreSession(PlaybackSessionSnapshot snapshot) {
    _pendingRestore = snapshot;
    state = state.copyWith(
      playback: state.playback.copyWith(
        currentTrack: snapshot.currentTrack,
        currentIndex: snapshot.queueIndex,
        position: snapshot.position,
        queue: snapshot.queue,
      ),
      isPlaying: false,
    );
  }

  /// Saves the current track/queue/position as the session to restore next
  /// startup — called from the app's lifecycle observer (see main.dart)
  /// when the app is backgrounded, which is the point at which the app is
  /// actually at risk of being killed outright before a clean shutdown
  /// could save anything. A no-op with nothing loaded. Deliberately not
  /// run through [_mutex]: it only reads [state], never mutates it, so it
  /// can't race with anything else here the way the mutating methods
  /// above can.
  Future<void> persistSessionSnapshot() async {
    final track = state.playback.currentTrack;
    if (track == null) return;
    await ref.read(saveLastPlaybackStateProvider)(
      PlaybackSessionSnapshot(
        queue: state.playback.queue,
        queueIndex: state.playback.currentIndex.clamp(
          0,
          state.playback.queue.length - 1,
        ),
        position: state.playback.position,
      ),
    );
  }

  /// Subscribes once to the engine's continuous position stream (see
  /// `PlaybackEnginePort.positionStream`), mirroring each update onto
  /// `PlaybackState.position` — the real-playback equivalent of the
  /// discrete position snapshots [_play]/[_seekBy]/[_seekTo]/[_skipNext]/
  /// [_skipPrevious] already set on their own — and to its duration
  /// stream (`PlaybackEnginePort.durationStream`), refining
  /// `currentTrack.durationMs` once the engine reports a real value. That
  /// second part matters for any track whose domain metadata doesn't
  /// already carry a real duration — a local file always starts at `0`
  /// ("not known"; see `LocalFileSourceAdapter`'s doc comment) until this
  /// fills it in, which the ±10s seek buttons and the scrubber both
  /// depend on to do anything at all (see
  /// [_clampToTrackDuration]/`PlaybackScrubber`'s own duration handling).
  ///
  /// Deliberately outside [_mutex]: both streams only ever narrow
  /// `position`/`currentTrack.durationMs` from data the engine itself
  /// reports, so there's nothing for either to race with, and gating them
  /// on the mutex would mean an update queued behind an in-flight
  /// seek/skip could momentarily show a stale value instead of the
  /// engine's actual current one.
  void _ensureEngineStreamsSubscribed() {
    if (_engineStreamsSubscribed) return;
    _engineStreamsSubscribed = true;
    final engine = ref.read(playbackEngineProvider);

    final positionSubscription = engine.positionStream.listen((position) {
      state = state.copyWith(
        playback: state.playback.copyWith(position: position),
      );
    });
    ref.onDispose(positionSubscription.cancel);

    final durationSubscription = engine.durationStream.listen((duration) {
      if (duration == null) return;
      final track = state.playback.currentTrack;
      if (track == null || track.durationMs == duration.inMilliseconds) {
        return;
      }
      final refined = track.copyWith(durationMs: duration.inMilliseconds);
      final queue = state.playback.queue;
      final index = state.playback.currentIndex;
      // `currentTrack` and `queue[currentIndex]` are separate fields (see
      // PlaybackState's own doc comment) -- refining only the former left
      // the latter permanently stuck at its original (often 0/"unknown")
      // duration. That queue is exactly what `persistSessionSnapshot`
      // saves, so a since-learned real duration was silently lost across
      // every session restore, and the Queue screen would keep showing
      // the stale value too. Located by index, not value, for the same
      // reason `currentIndex` exists at all: a duplicate track elsewhere
      // in the queue must not also get rewritten.
      final refinedQueue = index >= 0 && index < queue.length
          ? [
              for (final (i, entry) in queue.indexed)
                i == index ? refined : entry,
            ]
          : queue;
      state = state.copyWith(
        playback: state.playback.copyWith(
          currentTrack: refined,
          queue: refinedQueue,
        ),
      );
    });
    ref.onDispose(durationSubscription.cancel);
  }

  /// Plays [track]. When [queue] is given, it becomes the active queue —
  /// e.g. the track list a screen played this track from — so
  /// skipNext/skipPrevious have somewhere to go; otherwise the queue is
  /// just [track] on its own. [queueIndex] is [track]'s position within
  /// that queue — the caller (e.g. the screen that built the list [track]
  /// came from) is the one place that unambiguously knows this, so it's
  /// passed through rather than re-derived by searching the queue for a
  /// value-equal track (see core/domain/playback_engine_port.dart).
  Future<void> play(Track track, {List<Track>? queue, int queueIndex = 0}) {
    return _mutex.run(() => _play(track, queue: queue, queueIndex: queueIndex));
  }

  Future<void> _play(
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

    _ensureEngineStreamsSubscribed();
    state = state.copyWith(
      playback: state.playback.copyWith(
        currentTrack: track,
        currentIndex: ref.read(playbackEngineProvider).currentIndex,
        position: Duration.zero,
        queue: effectiveQueue,
      ),
      isPlaying: true,
    );
  }

  /// Resolves [playlist] to tracks and starts playing it from the top.
  /// Not itself serialized against other playback-mutating calls — it
  /// only mutates playback state via the (already-serialized) [play]
  /// below, so wrapping it too would deadlock waiting on itself.
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

  Future<void> pause() => _mutex.run(_pause);

  Future<void> _pause() async {
    final result = await ref.read(pauseTrackProvider)();
    if (result case ResultFailure()) return;
    state = state.copyWith(isPlaying: false);
  }

  /// Resumes the already-loaded current track via `ResumeTrack` — unlike
  /// [play], this never re-commits the queue, so it can't reset shuffle
  /// history the way re-entering [play] on resume used to (see
  /// core/usecases/resume_track.dart).
  Future<void> resume() => _mutex.run(_resume);

  Future<void> _resume() async {
    final track = state.playback.currentTrack;
    if (track == null) return;
    final result = await ref.read(resumeTrackProvider)(track);
    if (result case ResultFailure()) return;
    _ensureEngineStreamsSubscribed();
    state = state.copyWith(isPlaying: true);
  }

  /// Delegates to the already-serialized [pause]/[resume] — see
  /// [playPlaylist] for why this itself isn't also wrapped in the mutex.
  /// A pending restored session (see [restoreSession]) is handled as its
  /// own case: the engine has nothing loaded for it yet, so this loads it
  /// fresh via [_play] and seeks to the saved position, rather than
  /// [resume] — which would try to resume a track the engine was never
  /// given in the first place.
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else if (_pendingRestore case final snapshot?) {
      await _mutex.run(() => _resumeFromRestore(snapshot));
    } else if (state.playback.currentTrack != null) {
      await resume();
    }
  }

  Future<void> _resumeFromRestore(PlaybackSessionSnapshot snapshot) async {
    await _play(
      snapshot.currentTrack,
      queue: snapshot.queue,
      queueIndex: snapshot.queueIndex,
    );
    _pendingRestore = null;
    await _seekTo(snapshot.position);
  }

  /// Guards [skipNext]/[skipPrevious] against piling up behind each
  /// other -- confirmed on a real device against a queue of real (non-
  /// trivial to decode) audio files: each skip's full round trip
  /// (resolving the new track's source, handing it to `just_audio`,
  /// starting playback) is genuinely slow enough that a few impatient
  /// taps queue up several skips deep in [_mutex] before the first has
  /// even resolved. The mutex still correctly processes every one of
  /// them in order -- nothing is dropped or corrupted -- but from the
  /// screen, a run of taps that all land while one is still in flight
  /// looks and feels exactly like the button stopped responding, then
  /// suddenly jumped several tracks at once when the backlog finally
  /// drained. Silently ignoring a tap that arrives while one is already
  /// in flight, rather than queuing it, keeps every tap that actually
  /// does something visibly immediate.
  bool _skipInFlight = false;

  Future<void> skipNext() async {
    if (_skipInFlight) return;
    _skipInFlight = true;
    try {
      await _mutex.run(_skipNext);
    } finally {
      _skipInFlight = false;
    }
  }

  Future<void> _skipNext() async {
    final result = await ref.read(skipNextProvider)();
    switch (result) {
      case Success(value: final track):
        _ensureEngineStreamsSubscribed();
        final index = ref.read(playbackEngineProvider).currentIndex;
        state = state.copyWith(
          playback: state.playback.copyWith(
            currentTrack: _withKnownDuration(track, index),
            currentIndex: index,
            position: Duration.zero,
          ),
          isPlaying: true,
        );
      case ResultFailure():
        return;
    }
  }

  Future<void> skipPrevious() async {
    if (_skipInFlight) return;
    _skipInFlight = true;
    try {
      await _mutex.run(_skipPrevious);
    } finally {
      _skipInFlight = false;
    }
  }

  Future<void> _skipPrevious() async {
    final result = await ref.read(skipPreviousProvider)();
    switch (result) {
      case Success(value: final track):
        _ensureEngineStreamsSubscribed();
        final index = ref.read(playbackEngineProvider).currentIndex;
        state = state.copyWith(
          playback: state.playback.copyWith(
            currentTrack: _withKnownDuration(track, index),
            currentIndex: index,
            position: Duration.zero,
          ),
          isPlaying: true,
        );
      case ResultFailure():
        return;
    }
  }

  /// [track] just came back from [PlaybackEnginePort.skipNext]/
  /// [PlaybackEnginePort.skipPrevious] -- resolved from the *engine's own*
  /// internal queue, a separate copy from [PlaybackState.queue] (see that
  /// class's own doc comment) that [_ensureEngineStreamsSubscribed]'s
  /// duration-refinement listener never touches. Landing back on a track
  /// whose real duration was already learned earlier this session --
  /// simply by skipping to it again -- would otherwise regress it to
  /// `durationMs: 0` ("unknown"), showing `--:--` for a track this same
  /// session already knows the real length of. [state.playback.queue] is
  /// refined in place by that listener, so it's the more current of the
  /// two wherever they disagree; [index] (the engine's own authoritative
  /// position, matching `currentIndex`'s doc comment) is what locates the
  /// corresponding entry, not [track]'s value, for the same reason
  /// `currentIndex` exists at all -- a duplicate track elsewhere in the
  /// queue must not be consulted instead.
  Track _withKnownDuration(Track track, int index) {
    if (track.durationMs != 0) return track;
    final queue = state.playback.queue;
    if (index < 0 || index >= queue.length) return track;
    final knownDurationMs = queue[index].durationMs;
    return knownDurationMs == 0
        ? track
        : track.copyWith(durationMs: knownDurationMs);
  }

  /// Seeks [offset] relative to the current position — used by the ±10s
  /// buttons. The *target* passed to the engine is clamped to the
  /// track's own bounds via [_clampToTrackDuration] before computing the
  /// offset actually sent to [seekByProvider], so repeatedly seeking
  /// forward near the end of a track can't push the engine's position
  /// (or `state`'s) past the track's duration — without that, `+10s`
  /// pressed near the end would leave `position` reading past
  /// `duration`, and the *engine* itself (not just the UI-facing state)
  /// would end up holding that same out-of-range value, since it's the
  /// engine that receives the raw offset.
  Future<void> seekBy(Duration offset) => _mutex.run(() => _seekBy(offset));

  Future<void> _seekBy(Duration offset) async {
    final currentPosition = state.playback.position;
    final clampedTarget = _clampToTrackDuration(currentPosition + offset);
    final clampedOffset = clampedTarget - currentPosition;
    final result = await ref.read(seekByProvider)(
      currentPosition: currentPosition,
      offset: clampedOffset,
    );
    if (result case ResultFailure()) return;

    state = state.copyWith(
      playback: state.playback.copyWith(position: clampedTarget),
    );
  }

  /// Seeks to an absolute [target] position — used by
  /// `PlaybackScrubber`'s drag-to-seek, via the `SeekTo` use case.
  /// [target] is clamped to the track's bounds the same way [seekBy] is
  /// — the scrubber itself already only ever asks for a position within
  /// `[0, duration]`, but this doesn't rely on that.
  Future<void> seekTo(Duration target) => _mutex.run(() => _seekTo(target));

  Future<void> _seekTo(Duration target) async {
    final clampedTarget = _clampToTrackDuration(target);
    final result = await ref.read(seekToProvider)(clampedTarget);
    if (result case ResultFailure()) return;

    state = state.copyWith(
      playback: state.playback.copyWith(position: clampedTarget),
    );
  }

  /// Clamps [target] to `[Duration.zero, currentTrack's duration]` (or
  /// just the zero floor if nothing's loaded) — shared by [_seekBy] and
  /// [_seekTo] so neither can leave `position` negative or past the end
  /// of the track, which would otherwise show nonsensical values like a
  /// position greater than the duration next to it.
  ///
  /// A `durationMs` of exactly `0` is never a real track's actual length —
  /// it's `LocalFileSourceAdapter`'s "duration not known" sentinel (no tag
  /// reader exists to read a local file's real duration — see that
  /// class's own doc comment). Enforcing an upper bound of zero there
  /// would clamp *every* seek target straight back to the start, making
  /// both the ±10s buttons and the scrubber permanently stuck at 0:00 for
  /// any local track — indistinguishable from seeking being broken
  /// outright. So an unknown duration skips the upper-bound clamp
  /// entirely instead, and leaves it to the engine (which knows the
  /// file's real length once loaded) to bound the seek.
  Duration _clampToTrackDuration(Duration target) {
    var clamped = target < Duration.zero ? Duration.zero : target;
    final track = state.playback.currentTrack;
    if (track != null && track.durationMs > 0) {
      final trackDuration = Duration(milliseconds: track.durationMs);
      if (clamped > trackDuration) clamped = trackDuration;
    }
    return clamped;
  }

  /// Purely synchronous — no `await` means no interleaving is possible,
  /// so this doesn't need [_mutex] the way the async methods above do.
  void toggleImmersive() {
    state = state.copyWith(
      playback: ref.read(toggleImmersiveProvider)(state.playback),
    );
  }

  /// Toggles shuffle. The target value is computed synchronously, from
  /// [state] as it is right now, *before* the `await` below — and applied
  /// to [state] immediately — rather than read again once the engine call
  /// resolves. This is now belt-and-suspenders given [_mutex] already
  /// rules out a concurrent call starting before this one finishes, but
  /// it's kept since it's still correct and cheap.
  ///
  /// On failure, only the `shuffle` field is flipped back — read off
  /// [state] as it is *at that point*, not the `previous` snapshot from
  /// before the `await`. Restoring the whole snapshot would clobber any
  /// other change (a skip, a seek, another toggle) that completed on
  /// [state] while this call was awaiting the engine.
  Future<void> toggleShuffle() => _mutex.run(_toggleShuffle);

  Future<void> _toggleShuffle() async {
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
  Future<void> toggleRepeatMode() => _mutex.run(_toggleRepeatMode);

  Future<void> _toggleRepeatMode() async {
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
