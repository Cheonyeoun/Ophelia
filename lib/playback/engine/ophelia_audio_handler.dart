import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/domain/playback_engine_port.dart';
import '../../core/domain/playback_state.dart';
import '../../core/domain/track.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';

/// [OpheliaAudioHandler]'s [PlaybackNavigationSnapshot] -- mirrors
/// [FakePlaybackEnginePort]'s `_NavigationSnapshot` field-for-field (see
/// data/fakes/fake_playback_engine_port.dart) so [JustAudioPlaybackAdapter]
/// can capture/restore state identically regardless of which engine is
/// behind it.
class OpheliaNavigationSnapshot implements PlaybackNavigationSnapshot {
  final Track? currentTrack;
  final String? currentSourcePath;
  final Duration position;
  final bool isPlaying;
  final List<Track> queue;
  final int currentIndex;
  final List<int> shuffleHistory;

  OpheliaNavigationSnapshot({
    required this.currentTrack,
    required this.currentSourcePath,
    required this.position,
    required this.isPlaying,
    required this.queue,
    required this.currentIndex,
    required this.shuffleHistory,
  });

  /// The state of an engine that has never played anything -- what
  /// [JustAudioPlaybackAdapter.captureNavigationState] returns when
  /// called before the handler has even finished initializing (see that
  /// class's doc comment for why that's always a safe, correct answer).
  factory OpheliaNavigationSnapshot.initial() => OpheliaNavigationSnapshot(
        currentTrack: null,
        currentSourcePath: null,
        position: Duration.zero,
        isPlaying: false,
        queue: const [],
        currentIndex: -1,
        shuffleHistory: const [],
      );
}

/// A [Track] source path starting with this prefix names a Flutter asset
/// key (the rest of the string, passed to `AudioSource.asset`) rather
/// than a network URL or a local file path -- used by
/// `FakeDownloadPort`'s sample data (see data/fakes/sample_data.dart) to
/// point one sample track at the bundled manual-QA test asset, since
/// there's otherwise no way to tell "play this bundled asset" apart from
/// "play this file path" in a single sourcePath string.
const assetSourcePrefix = 'asset:';

/// Dispatches a [Track] source path (see `PlaybackEnginePort.play`'s doc
/// comment) to the right kind of `just_audio` [AudioSource] -- an asset
/// (see [assetSourcePrefix]), a network stream, or a local file. A
/// top-level, dependency-free function (no `AudioPlayer` involved) so
/// this dispatch logic can be unit-tested directly, unlike the rest of
/// [OpheliaAudioHandler], which needs a real native audio platform to
/// exercise at all.
AudioSource audioSourceForPath(String sourcePath) {
  if (sourcePath.startsWith(assetSourcePrefix)) {
    return AudioSource.asset(sourcePath.substring(assetSourcePrefix.length));
  }
  final uri = Uri.tryParse(sourcePath);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return AudioSource.uri(uri);
  }
  return AudioSource.file(sourcePath);
}

/// Maps a `just_audio` load/playback exception to the [Failure] subtype
/// matching what kind of source [sourcePath] was -- a [NetworkFailure]
/// for a stream URL, a [StorageFailure] for a local file or asset. See
/// [audioSourceForPath]'s doc comment on why this is a top-level function.
Failure failureForLoadException(Object e, String sourcePath) {
  final message =
      e is PlayerException ? (e.message ?? e.toString()) : e.toString();
  final isNetwork =
      sourcePath.startsWith('http://') || sourcePath.startsWith('https://');
  return isNetwork ? NetworkFailure(message) : StorageFailure(message);
}

/// Real playback engine, wired to `audio_service` (background/lock-
/// screen/notification integration) and `just_audio` (actual decoding
/// and output) -- see docs/architecture.md §3.1, §3.3, §7.
///
/// Owns all queue/index/shuffle/repeat navigation state and decision
/// logic itself, porting `FakePlaybackEnginePort`'s exact algorithm
/// (unplayed-this-round shuffle history, repeat-all wraparound, ...)
/// rather than delegating to `just_audio`'s own built-in shuffle/repeat
/// (`AudioPlayer.shuffle()`/`setLoopMode`), which has no obligation to
/// pick the same track the fake -- and every test/use case written
/// against it -- expects. `just_audio`'s player is used here purely as a
/// single-track player: whenever navigation logic lands on a new index,
/// this loads that track's resolved source into it directly, rather than
/// building a `ConcatenatingAudioSource` playlist and letting `just_audio`
/// itself decide what "next" means.
///
/// This is deliberately the *single* place navigation decisions are
/// made, reachable equally from [JustAudioPlaybackAdapter] (the app's own
/// transport controls, via `PlaybackEnginePort`) and from the
/// `AudioHandler` overrides below (the OS's lock-screen/notification/
/// headset-button controls) -- so a skip pressed from the lock screen and
/// a skip pressed in the app itself land on exactly the same track.
class OpheliaAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  /// Resolves [Track] to a playable source path (a stream URL or a local
  /// file path -- see `PlaybackEnginePort.play`'s doc comment), the same
  /// download-first-stream-fallback logic `PlayTrack` uses for the first
  /// track of a session. Injected as a plain function rather than typed
  /// `MediaSourcePort`/`DownloadPort` dependencies so this handler --
  /// which `AudioService.init()` constructs on its own, with no access to
  /// this app's Riverpod container -- doesn't need to know those port
  /// types exist; [JustAudioPlaybackAdapter] supplies the real
  /// implementation.
  final Future<Result<String, Failure>> Function(Track track) _resolveSource;

  final Random _random;

  Track? currentTrack;
  String? currentSourcePath;
  Duration _lastKnownPosition = Duration.zero;
  bool _isPlaying = false;
  List<Track> _trackQueue = const [];

  /// Position of [currentTrack] within [_trackQueue] -- see
  /// `PlaybackEnginePort.currentIndex`'s doc comment; kept as a plain
  /// field (not derived from `just_audio`) for the same reason this
  /// whole handler owns navigation itself rather than delegating to it.
  int currentIndex = -1;

  bool shuffle = false;
  RepeatMode repeatMode = RepeatMode.off;

  /// Indices already visited during the current shuffle "round", in
  /// order, with [currentIndex] always last -- see
  /// `FakePlaybackEnginePort._shuffleHistory`'s doc comment; identical
  /// role here.
  final List<int> _shuffleHistory = [];

  // Parameter names stay public while the fields they populate stay
  // private -- see the identical note on JustAudioPlaybackAdapter's
  // constructor.
  OpheliaAudioHandler({
    required Future<Result<String, Failure>> Function(Track track)
        resolveSource,
    Random? random,
  })  : _resolveSource = resolveSource, // ignore: prefer_initializing_formals
        _random = random ?? Random() {
    _player.playbackEventStream.listen(_broadcastPlaybackState);
    _player.positionStream.listen((position) {
      _lastKnownPosition = position;
    });
  }

  /// Forwarded directly from `just_audio` -- see
  /// `PlaybackEnginePort.positionStream`'s doc comment.
  Stream<Duration> get positionStream => _player.positionStream;

  Future<Result<void, Failure>> performPlay(
    Track track,
    String sourcePath, {
    int queueIndex = 0,
  }) async {
    if (_trackQueue.isEmpty ||
        queueIndex < 0 ||
        queueIndex >= _trackQueue.length) {
      return Result.failure(
        NotFoundFailure(
          'queueIndex $queueIndex is out of range for a queue of '
          '${_trackQueue.length} track(s)',
        ),
      );
    }

    try {
      await _player.setAudioSource(audioSourceForPath(sourcePath));
    } catch (e) {
      return Result.failure(failureForLoadException(e, sourcePath));
    }

    currentTrack = track;
    currentSourcePath = sourcePath;
    currentIndex = queueIndex;
    _lastKnownPosition = Duration.zero;
    _isPlaying = true;
    _shuffleHistory
      ..clear()
      ..add(currentIndex);
    _broadcastMediaItem();
    unawaited(_player.play());
    return const Result.success(null);
  }

  Future<Result<void, Failure>> performResume() async {
    _isPlaying = true;
    try {
      unawaited(_player.play());
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }

  Future<Result<void, Failure>> performPause() async {
    try {
      await _player.pause();
      _isPlaying = false;
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }

  Future<Result<void, Failure>> performSeek(Duration position) async {
    try {
      await _player.seek(position);
      _lastKnownPosition = position;
      return const Result.success(null);
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }

  Future<Result<Track, Failure>> performSkipNext() async {
    if (currentIndex == -1 || _trackQueue.isEmpty) {
      return const Result.failure(NotFoundFailure('no next track'));
    }

    if (repeatMode == RepeatMode.one) {
      return _tryMoveTo(currentIndex);
    }

    if (shuffle) {
      return _shuffleNext();
    }

    if (currentIndex >= _trackQueue.length - 1) {
      if (repeatMode == RepeatMode.all) {
        return _tryMoveTo(0);
      }
      return const Result.failure(NotFoundFailure('no next track'));
    }

    return _tryMoveTo(currentIndex + 1);
  }

  Future<Result<Track, Failure>> performSkipPrevious() async {
    if (currentIndex == -1 || _trackQueue.isEmpty) {
      return const Result.failure(NotFoundFailure('no previous track'));
    }

    if (repeatMode == RepeatMode.one) {
      return _tryMoveTo(currentIndex);
    }

    if (shuffle) {
      return _shufflePrevious();
    }

    if (currentIndex <= 0) {
      if (repeatMode == RepeatMode.all) {
        return _tryMoveTo(_trackQueue.length - 1);
      }
      return const Result.failure(NotFoundFailure('no previous track'));
    }

    return _tryMoveTo(currentIndex - 1);
  }

  Future<Result<void, Failure>> performSetQueue(List<Track> tracks) async {
    _trackQueue = List.unmodifiable(tracks);
    currentIndex = _trackQueue.isEmpty ? -1 : 0;
    _shuffleHistory
      ..clear()
      ..add(currentIndex);
    queue.add([for (final track in tracks) _toMediaItem(track)]);
    return const Result.success(null);
  }

  Future<Result<void, Failure>> performSetShuffle(bool enabled) async {
    shuffle = enabled;
    if (enabled) {
      _shuffleHistory
        ..clear()
        ..add(currentIndex);
    }
    return const Result.success(null);
  }

  Future<Result<void, Failure>> performSetRepeatMode(RepeatMode mode) async {
    repeatMode = mode;
    return const Result.success(null);
  }

  PlaybackNavigationSnapshot performCaptureNavigationState() =>
      OpheliaNavigationSnapshot(
        currentTrack: currentTrack,
        currentSourcePath: currentSourcePath,
        position: _lastKnownPosition,
        isPlaying: _isPlaying,
        queue: _trackQueue,
        currentIndex: currentIndex,
        shuffleHistory: List.unmodifiable(_shuffleHistory),
      );

  Future<Result<void, Failure>> performRestoreNavigationState(
    PlaybackNavigationSnapshot snapshot,
  ) async {
    final s = snapshot as OpheliaNavigationSnapshot;
    currentTrack = s.currentTrack;
    currentSourcePath = s.currentSourcePath;
    _lastKnownPosition = s.position;
    _isPlaying = s.isPlaying;
    _trackQueue = s.queue;
    currentIndex = s.currentIndex;
    _shuffleHistory
      ..clear()
      ..addAll(s.shuffleHistory);
    queue.add([for (final track in _trackQueue) _toMediaItem(track)]);
    _broadcastMediaItem();

    // Nothing was ever loaded before this restore point -- the failed
    // attempt this is undoing was the very first play ever, so there's
    // no real player state to revert (see
    // JustAudioPlaybackAdapter.captureNavigationState's doc comment).
    final trackToRestore = currentTrack;
    final sourceToRestore = currentSourcePath;
    if (trackToRestore == null || sourceToRestore == null) {
      try {
        await _player.stop();
      } catch (_) {
        // Best-effort -- there's nothing meaningful to roll back to if
        // even stopping fails, and this is already inside a rollback.
      }
      return const Result.success(null);
    }

    try {
      await _player.setAudioSource(
        audioSourceForPath(sourceToRestore),
        initialPosition: _lastKnownPosition,
      );
      if (_isPlaying) {
        unawaited(_player.play());
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure(failureForLoadException(e, sourceToRestore));
    }
  }

  Future<Result<Track, Failure>> _shuffleNext() async {
    final previousIndex = currentIndex;
    final unplayed = [
      for (var i = 0; i < _trackQueue.length; i++)
        if (!_shuffleHistory.contains(i)) i,
    ];

    if (unplayed.isNotEmpty) {
      final next = unplayed[_random.nextInt(unplayed.length)];
      final result = await _tryMoveTo(next);
      if (result case Success()) _shuffleHistory.add(next);
      return result;
    }

    // Every track has been visited this round.
    if (repeatMode == RepeatMode.off) {
      return const Result.failure(NotFoundFailure('no next track'));
    }
    final others = [
      for (var i = 0; i < _trackQueue.length; i++)
        if (i != previousIndex) i,
    ];
    if (others.isEmpty) {
      // Only one track in the queue -- nothing else to shuffle to.
      return _tryMoveTo(previousIndex);
    }
    final next = others[_random.nextInt(others.length)];
    final result = await _tryMoveTo(next);
    if (result case Success()) {
      _shuffleHistory
        ..clear()
        ..add(previousIndex)
        ..add(next);
    }
    return result;
  }

  Future<Result<Track, Failure>> _shufflePrevious() async {
    if (_shuffleHistory.length <= 1) {
      return const Result.failure(NotFoundFailure('no previous track'));
    }
    final target = _shuffleHistory[_shuffleHistory.length - 2];
    final result = await _tryMoveTo(target);
    if (result case Success()) _shuffleHistory.removeLast();
    return result;
  }

  /// Resolves and loads `_trackQueue[index]`, committing to it (updating
  /// [currentIndex]/[currentTrack]/[currentSourcePath] and starting
  /// playback) only if that succeeds -- a failed resolve or load leaves
  /// every field exactly as it was, unlike [FakePlaybackEnginePort]'s
  /// equivalent (`_moveToCurrentIndex`), which can't fail at all. Callers
  /// are responsible for updating `_shuffleHistory` themselves, since
  /// where that happens differs between a plain skip and a shuffle pick.
  Future<Result<Track, Failure>> _tryMoveTo(int index) async {
    final track = _trackQueue[index];

    final sourceResult = await _resolveSource(track);
    final String sourcePath;
    switch (sourceResult) {
      case Success(value: final v):
        sourcePath = v;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }

    try {
      await _player.setAudioSource(audioSourceForPath(sourcePath));
    } catch (e) {
      return Result.failure(failureForLoadException(e, sourcePath));
    }

    currentIndex = index;
    currentTrack = track;
    currentSourcePath = sourcePath;
    _lastKnownPosition = Duration.zero;
    _isPlaying = true;
    _broadcastMediaItem();
    unawaited(_player.play());
    return Result.success(track);
  }

  MediaItem _toMediaItem(Track track) => MediaItem(
        id: track.id,
        title: track.title,
        artist: track.artist,
        album: track.album,
        duration: Duration(milliseconds: track.durationMs),
        artUri: track.coverArtPath == null
            ? null
            : Uri.tryParse(track.coverArtPath!),
      );

  void _broadcastMediaItem() {
    final track = currentTrack;
    mediaItem.add(track == null ? null : _toMediaItem(track));
  }

  void _broadcastPlaybackState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: currentIndex == -1 ? null : currentIndex,
        repeatMode: switch (repeatMode) {
          RepeatMode.off => AudioServiceRepeatMode.none,
          RepeatMode.one => AudioServiceRepeatMode.one,
          RepeatMode.all => AudioServiceRepeatMode.all,
        },
        shuffleMode: shuffle
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }

  // -- AudioHandler overrides: the OS side (lock screen, notification,
  // headset buttons) of the single shared navigation logic above. Each
  // just calls the same `perform*` method the app's own
  // JustAudioPlaybackAdapter calls, discarding the Result -- there's no
  // channel back to the OS for a domain Failure, so a failed OS-triggered
  // action (e.g. skipping past the end of the queue) simply does nothing,
  // the same way a disabled skip button would.

  @override
  Future<void> play() async {
    await performResume();
  }

  @override
  Future<void> pause() async {
    await performPause();
  }

  @override
  Future<void> seek(Duration position) async {
    await performSeek(position);
  }

  @override
  Future<void> skipToNext() async {
    await performSkipNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await performSkipPrevious();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await performSetShuffle(shuffleMode == AudioServiceShuffleMode.all);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await performSetRepeatMode(switch (repeatMode) {
      AudioServiceRepeatMode.none => RepeatMode.off,
      AudioServiceRepeatMode.one => RepeatMode.one,
      AudioServiceRepeatMode.all ||
      AudioServiceRepeatMode.group =>
        RepeatMode.all,
    });
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    await _player.stop();
    await super.stop();
  }
}
