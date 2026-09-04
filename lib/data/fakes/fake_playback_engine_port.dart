import 'dart:math';

import '../../core/domain/playback_engine_port.dart';
import '../../core/domain/playback_state.dart';
import '../../core/domain/track.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';

/// [FakePlaybackEnginePort]'s [PlaybackNavigationSnapshot] — every field
/// [captureNavigationState] needs to fully undo a failed attempt, taken
/// together rather than piecemeal (see that method's doc comment).
class _NavigationSnapshot implements PlaybackNavigationSnapshot {
  final Track? currentTrack;
  final String? currentSourcePath;
  final Duration position;
  final bool isPlaying;
  final List<Track> queue;
  final int currentIndex;
  final List<int> shuffleHistory;

  _NavigationSnapshot({
    required this.currentTrack,
    required this.currentSourcePath,
    required this.position,
    required this.isPlaying,
    required this.queue,
    required this.currentIndex,
    required this.shuffleHistory,
  });
}

/// **Temporary, UI-development-only fake — not a production adapter.**
///
/// In-memory stand-in for [PlaybackEnginePort] that tracks the "playing"
/// track, position, and queue in memory instead of driving `just_audio` —
/// enough for screens (and tests) to exercise transport controls before a
/// real adapter exists under lib/playback/engine/.
class FakePlaybackEnginePort implements PlaybackEnginePort {
  Track? currentTrack;
  String? currentSourcePath;
  Duration position = Duration.zero;
  List<Track> queue = const [];
  bool isPlaying = false;
  bool shuffle = false;
  RepeatMode repeatMode = RepeatMode.off;

  /// Position of [currentTrack] within [queue] — the source of truth for
  /// skipNext/skipPrevious, set directly by [setQueue] and moved by ±1 on
  /// skip. Kept separate from matching on [currentTrack]'s id or value so
  /// duplicate tracks in the queue don't confuse navigation.
  int currentIndex = -1;

  /// Indices already visited during the current shuffle "round", in
  /// order, with [currentIndex] always last — lets skipPrevious undo a
  /// shuffle pick instead of drawing a fresh random one.
  final List<int> _shuffleHistory = [];

  final Random _random;

  FakePlaybackEnginePort({Random? random}) : _random = random ?? Random();

  @override
  Future<Result<void, Failure>> play(
    Track track,
    String sourcePath, {
    int queueIndex = 0,
  }) async {
    if (queue.isEmpty || queueIndex < 0 || queueIndex >= queue.length) {
      return Result.failure(
        NotFoundFailure(
          'queueIndex $queueIndex is out of range for a queue of '
          '${queue.length} track(s)',
        ),
      );
    }
    currentTrack = track;
    currentSourcePath = sourcePath;
    position = Duration.zero;
    isPlaying = true;
    currentIndex = queueIndex;
    _shuffleHistory
      ..clear()
      ..add(currentIndex);
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> resume() async {
    isPlaying = true;
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> pause() async {
    isPlaying = false;
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> seek(Duration position) async {
    this.position = position;
    return const Result.success(null);
  }

  @override
  Future<Result<Track, Failure>> skipNext() async {
    if (currentIndex == -1 || queue.isEmpty) {
      return Result.failure(const NotFoundFailure('no next track'));
    }

    if (repeatMode == RepeatMode.one) {
      _moveToCurrentIndex();
      return Result.success(currentTrack!);
    }

    if (shuffle) {
      return _shuffleNext();
    }

    if (currentIndex >= queue.length - 1) {
      if (repeatMode == RepeatMode.all) {
        currentIndex = 0;
        _moveToCurrentIndex();
        return Result.success(currentTrack!);
      }
      return Result.failure(const NotFoundFailure('no next track'));
    }

    currentIndex++;
    _moveToCurrentIndex();
    return Result.success(currentTrack!);
  }

  @override
  Future<Result<Track, Failure>> skipPrevious() async {
    if (currentIndex == -1 || queue.isEmpty) {
      return Result.failure(const NotFoundFailure('no previous track'));
    }

    if (repeatMode == RepeatMode.one) {
      _moveToCurrentIndex();
      return Result.success(currentTrack!);
    }

    if (shuffle) {
      return _shufflePrevious();
    }

    if (currentIndex <= 0) {
      if (repeatMode == RepeatMode.all) {
        currentIndex = queue.length - 1;
        _moveToCurrentIndex();
        return Result.success(currentTrack!);
      }
      return Result.failure(const NotFoundFailure('no previous track'));
    }

    currentIndex--;
    _moveToCurrentIndex();
    return Result.success(currentTrack!);
  }

  @override
  Future<Result<void, Failure>> setQueue(List<Track> tracks) async {
    queue = List.unmodifiable(tracks);
    currentIndex = queue.isEmpty ? -1 : 0;
    _shuffleHistory
      ..clear()
      ..add(currentIndex);
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> setShuffle(bool enabled) async {
    shuffle = enabled;
    if (enabled) {
      _shuffleHistory
        ..clear()
        ..add(currentIndex);
    }
    return const Result.success(null);
  }

  @override
  Future<Result<void, Failure>> setRepeatMode(RepeatMode mode) async {
    repeatMode = mode;
    return const Result.success(null);
  }

  @override
  PlaybackNavigationSnapshot captureNavigationState() => _NavigationSnapshot(
        currentTrack: currentTrack,
        currentSourcePath: currentSourcePath,
        position: position,
        isPlaying: isPlaying,
        queue: queue,
        currentIndex: currentIndex,
        shuffleHistory: List.unmodifiable(_shuffleHistory),
      );

  @override
  Future<Result<void, Failure>> restoreNavigationState(
    PlaybackNavigationSnapshot snapshot,
  ) async {
    final s = snapshot as _NavigationSnapshot;
    currentTrack = s.currentTrack;
    currentSourcePath = s.currentSourcePath;
    position = s.position;
    isPlaying = s.isPlaying;
    queue = s.queue;
    currentIndex = s.currentIndex;
    _shuffleHistory
      ..clear()
      ..addAll(s.shuffleHistory);
    return const Result.success(null);
  }

  Result<Track, Failure> _shuffleNext() {
    final unplayed = [
      for (var i = 0; i < queue.length; i++)
        if (!_shuffleHistory.contains(i)) i,
    ];

    if (unplayed.isNotEmpty) {
      final next = unplayed[_random.nextInt(unplayed.length)];
      _shuffleHistory.add(next);
      currentIndex = next;
      _moveToCurrentIndex();
      return Result.success(currentTrack!);
    }

    // Every track has been visited this round.
    if (repeatMode == RepeatMode.off) {
      return Result.failure(const NotFoundFailure('no next track'));
    }
    final others = [
      for (var i = 0; i < queue.length; i++) if (i != currentIndex) i,
    ];
    if (others.isEmpty) {
      // Only one track in the queue — nothing else to shuffle to.
      _moveToCurrentIndex();
      return Result.success(currentTrack!);
    }
    final next = others[_random.nextInt(others.length)];
    _shuffleHistory
      ..clear()
      ..add(currentIndex)
      ..add(next);
    currentIndex = next;
    _moveToCurrentIndex();
    return Result.success(currentTrack!);
  }

  Result<Track, Failure> _shufflePrevious() {
    if (_shuffleHistory.length <= 1) {
      return Result.failure(const NotFoundFailure('no previous track'));
    }
    _shuffleHistory.removeLast();
    currentIndex = _shuffleHistory.last;
    _moveToCurrentIndex();
    return Result.success(currentTrack!);
  }

  void _moveToCurrentIndex() {
    final track = queue[currentIndex];
    currentTrack = track;
    // A placeholder path derived from the new track's id, just so this
    // fake's exposed state is never internally inconsistent (a
    // currentTrack whose currentSourcePath still points at the track it
    // replaced). A real adapter will need to resolve the actual
    // stream-vs-downloaded source on skip, the same way PlayTrack does
    // (see core/usecases/play_track.dart) — an open design question for
    // when that adapter is built, not solved here.
    currentSourcePath = '/fake-source/${track.id}';
    position = Duration.zero;
  }
}
