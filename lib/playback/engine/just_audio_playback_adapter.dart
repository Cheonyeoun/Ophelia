import 'package:audio_service/audio_service.dart';
import 'package:meta/meta.dart';

import '../../core/domain/download_port.dart';
import '../../core/domain/local_file_source_port.dart';
import '../../core/domain/media_source_port.dart';
import '../../core/domain/playback_engine_port.dart';
import '../../core/domain/playback_state.dart';
import '../../core/domain/track.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import 'ophelia_audio_handler.dart';

/// Real [PlaybackEnginePort] adapter, backed by [OpheliaAudioHandler]
/// (`audio_service` + `just_audio`) — see docs/architecture.md §7.
/// Replaces `FakePlaybackEnginePort` as the app's default
/// (lib/app/providers.dart); the fake remains for tests that want
/// predictable, hardware-free behavior.
///
/// `AudioService.init()` is itself asynchronous (it has to set up a
/// platform channel to a native background service before the handler is
/// usable), but every `PlaybackEnginePort` method here is called
/// synchronously-ish by `PlaybackController` right after an `await`, and
/// [currentIndex]/[captureNavigationState] are plain synchronous getters
/// with no `Future` in their signature at all. Rather than making the
/// whole app's playback wiring async just for this (which `main.dart`'s
/// startup sequence would otherwise need to account for), the handler is
/// created lazily -- on first use, not at construction -- and every
/// method awaits it before doing anything. [currentIndex] and
/// [captureNavigationState] fall back to "nothing has happened yet"
/// defaults (`-1`, an empty/null snapshot) when the handler hasn't
/// resolved yet, which is always the *correct* answer in that case: since
/// every mutating method awaits the handler before touching it, the
/// handler being unresolved means none of them has ever completed, which
/// means nothing has actually happened yet either.
class JustAudioPlaybackAdapter implements PlaybackEnginePort {
  final MediaSourcePort _mediaSource;
  final DownloadPort _downloads;
  final LocalFileSourcePort _localFileSource;

  Future<OpheliaAudioHandler>? _handlerFuture;
  OpheliaAudioHandler? _resolvedHandler;

  // Parameter names stay public (mediaSource/downloads/localFileSource)
  // while the fields they populate stay private -- an initializing
  // formal would force them to share the field's leading-underscore
  // name, which external callers (e.g. providers.dart) couldn't pass as
  // a named argument.
  JustAudioPlaybackAdapter({
    required MediaSourcePort mediaSource,
    required DownloadPort downloads,
    required LocalFileSourcePort localFileSource,
  })  : _mediaSource = mediaSource, // ignore: prefer_initializing_formals
        _downloads = downloads, // ignore: prefer_initializing_formals
        _localFileSource = localFileSource; // ignore: prefer_initializing_formals

  Future<OpheliaAudioHandler> get _handler {
    return _handlerFuture ??= AudioService.init(
      builder: () => OpheliaAudioHandler(resolveSource: resolveSource),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ophelia.ophelia.channel.audio',
        androidNotificationChannelName: 'Ophelia playback',
      ),
    ).then((handler) {
      _resolvedHandler = handler;
      return handler;
    });
  }

  /// Resolves whatever source a track the *engine itself* picked needs --
  /// [OpheliaAudioHandler]'s `skipNext`/`skipPrevious` land on a track the
  /// caller couldn't have predicted (especially under shuffle), so unlike
  /// the initial [play] call, there's no source path to pass in for it.
  ///
  /// Mirrors `PlayTrack`'s own source resolution for the very first track
  /// of a session (see core/usecases/play_track.dart) exactly, branch for
  /// branch: a local-folder track (`sourceType: TrackSourceType.local`)
  /// resolves via [LocalFileSourcePort] and never touches
  /// download/stream at all; anything else keeps the download-first,
  /// stream-fallback flow. The two must stay in sync -- this was missed
  /// entirely when local-folder support was added, which silently broke
  /// skip-next/previous for a local track (it fell through to
  /// `DownloadPort`/`MediaSourcePort`, which don't recognize a `local:`
  /// id and fail) until this fix.
  ///
  /// `@visibleForTesting`: pure port-delegation with no `AudioService`/
  /// `just_audio` involved, so -- unlike almost everything else on this
  /// class -- it's safe to call directly from a plain `flutter test`, no
  /// native platform plugin required. See this class's own test file.
  @visibleForTesting
  Future<Result<String, Failure>> resolveSource(Track track) async {
    if (track.sourceType == TrackSourceType.local) {
      return _localFileSource.getSourcePath(track.id);
    }

    final downloadedResult = await _downloads.isDownloaded(track.id);
    final bool isDownloaded;
    switch (downloadedResult) {
      case Success(value: final v):
        isDownloaded = v;
      case ResultFailure(failure: final f):
        return Result.failure(f);
    }

    return isDownloaded
        ? _downloads.getLocalPath(track.id)
        : _mediaSource.getStreamUrl(track.id);
  }

  @override
  Future<Result<void, Failure>> play(
    Track track,
    String sourcePath, {
    int queueIndex = 0,
  }) async {
    final handler = await _handler;
    return handler.performPlay(track, sourcePath, queueIndex: queueIndex);
  }

  @override
  Future<Result<void, Failure>> resume() async {
    final handler = await _handler;
    return handler.performResume();
  }

  @override
  Future<Result<void, Failure>> pause() async {
    final handler = await _handler;
    return handler.performPause();
  }

  @override
  Future<Result<void, Failure>> seek(Duration position) async {
    final handler = await _handler;
    return handler.performSeek(position);
  }

  @override
  Future<Result<Track, Failure>> skipNext() async {
    final handler = await _handler;
    return handler.performSkipNext();
  }

  @override
  Future<Result<Track, Failure>> skipPrevious() async {
    final handler = await _handler;
    return handler.performSkipPrevious();
  }

  @override
  Future<Result<void, Failure>> setQueue(List<Track> tracks) async {
    final handler = await _handler;
    return handler.performSetQueue(tracks);
  }

  @override
  Future<Result<void, Failure>> setShuffle(bool enabled) async {
    final handler = await _handler;
    return handler.performSetShuffle(enabled);
  }

  @override
  Future<Result<void, Failure>> setRepeatMode(RepeatMode repeatMode) async {
    final handler = await _handler;
    return handler.performSetRepeatMode(repeatMode);
  }

  @override
  PlaybackNavigationSnapshot captureNavigationState() {
    return _resolvedHandler?.performCaptureNavigationState() ??
        OpheliaNavigationSnapshot.initial();
  }

  @override
  Future<Result<void, Failure>> restoreNavigationState(
    PlaybackNavigationSnapshot snapshot,
  ) async {
    final handler = await _handler;
    return handler.performRestoreNavigationState(snapshot);
  }

  @override
  int get currentIndex => _resolvedHandler?.currentIndex ?? -1;

  @override
  Stream<Duration> get positionStream {
    if (_resolvedHandler != null) return _resolvedHandler!.positionStream;
    return Stream.fromFuture(_handler).asyncExpand(
      (handler) => handler.positionStream,
    );
  }
}
