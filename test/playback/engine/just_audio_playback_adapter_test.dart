import 'package:test/test.dart';

import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/data/fakes/fake_download_port.dart';
import 'package:ophelia/data/fakes/fake_local_file_source_port.dart';
import 'package:ophelia/data/fakes/fake_media_source_port.dart';
import 'package:ophelia/playback/engine/just_audio_playback_adapter.dart';
import 'package:ophelia/playback/engine/ophelia_audio_handler.dart';

import '../../support/result_test_helpers.dart';

/// Deliberately narrow: every `PlaybackEnginePort` method on
/// [JustAudioPlaybackAdapter] other than the three covered below awaits
/// `AudioService.init()` before doing anything (see that class's doc
/// comment), which needs a real native `audio_service` platform plugin
/// to ever resolve -- unavailable in `flutter test`, and not something
/// to fake a passing result for. Actually driving playback, real lock-
/// screen/notification controls, and surviving backgrounding can only be
/// verified by running the app for real (`flutter run` on a device or
/// emulator) -- see this task's manual-QA notes.
///
/// What *is* safe to test here: [JustAudioPlaybackAdapter.currentIndex]
/// and [JustAudioPlaybackAdapter.captureNavigationState] are plain
/// synchronous getters that never await the handler themselves, and
/// [JustAudioPlaybackAdapter.resolveSource] is pure port delegation with
/// no `AudioService`/`just_audio` involved -- none of the three ever
/// risk a call into the missing platform plugin.
void main() {
  test(
    'currentIndex is -1 before anything has ever played -- the same '
    '"nothing set" default FakePlaybackEnginePort starts at',
    () {
      final adapter = JustAudioPlaybackAdapter(
        mediaSource: FakeMediaSourcePort(),
        downloads: FakeDownloadPort(),
        localFileSource: FakeLocalFileSourcePort(),
      );

      expect(adapter.currentIndex, -1);
    },
  );

  test(
    'captureNavigationState before anything has ever played returns the '
    'same "nothing has happened yet" snapshot a freshly constructed '
    'engine would have',
    () {
      final adapter = JustAudioPlaybackAdapter(
        mediaSource: FakeMediaSourcePort(),
        downloads: FakeDownloadPort(),
        localFileSource: FakeLocalFileSourcePort(),
      );

      final snapshot =
          adapter.captureNavigationState() as OpheliaNavigationSnapshot;

      expect(snapshot.currentTrack, isNull);
      expect(snapshot.currentIndex, -1);
      expect(snapshot.queue, isEmpty);
      expect(snapshot.isPlaying, isFalse);
    },
  );

  group('resolveSource', () {
    const localTrack = Track(
      id: 'local:/music/song.mp3',
      title: 'Song',
      artist: 'Someone',
      album: 'Some Folder',
      durationMs: 1000,
      sourceType: TrackSourceType.local,
    );

    test(
      'a local-folder track resolves via LocalFileSourcePort, never '
      'touching DownloadPort/MediaSourcePort at all -- the exact bug '
      'this test file exists to catch: skip-next/previous landing on a '
      'local track used to fall through to the catalog resolution path '
      'and fail',
      () async {
        final adapter = JustAudioPlaybackAdapter(
          mediaSource: FakeMediaSourcePort(),
          downloads: FakeDownloadPort(seed: []),
          localFileSource: FakeLocalFileSourcePort(
            tracksByFolder: {
              '/music': [localTrack],
            },
          ),
        );

        final path = unwrapValue(await adapter.resolveSource(localTrack));

        expect(path, '/fake-local/${localTrack.id}');
      },
    );

    test(
      'propagates a failure from LocalFileSourcePort for a local track '
      'it does not recognize, rather than falling through to the '
      'catalog resolution path',
      () async {
        const unknownLocalTrack = Track(
          id: 'local:/music/missing.mp3',
          title: 'Missing',
          artist: 'Nobody',
          album: 'Nowhere',
          durationMs: 1000,
          sourceType: TrackSourceType.local,
        );
        final adapter = JustAudioPlaybackAdapter(
          mediaSource: FakeMediaSourcePort(),
          downloads: FakeDownloadPort(seed: []),
          localFileSource: FakeLocalFileSourcePort(),
        );

        final failure = unwrapFailure(
          await adapter.resolveSource(unknownLocalTrack),
        );

        expect(failure, isA<NotFoundFailure>());
      },
    );

    test(
      'a non-local track still uses the download-first, stream-fallback '
      'flow, unaffected by LocalFileSourcePort existing',
      () async {
        final track = FakeMediaSourcePort().tracks.first;
        final adapter = JustAudioPlaybackAdapter(
          mediaSource: FakeMediaSourcePort(),
          downloads: FakeDownloadPort(seed: []),
          localFileSource: FakeLocalFileSourcePort(),
        );

        final path = unwrapValue(await adapter.resolveSource(track));

        expect(path, 'https://stream.ophelia.fake/${track.id}');
      },
    );
  });
}
