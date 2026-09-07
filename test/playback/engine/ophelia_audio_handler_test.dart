import 'package:just_audio/just_audio.dart';
import 'package:test/test.dart';

import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/playback/engine/ophelia_audio_handler.dart';

/// Covers the parts of lib/playback/engine/ophelia_audio_handler.dart
/// that don't need a real native audio platform to exercise: the
/// source-path dispatch/failure-mapping logic (deliberately extracted as
/// top-level functions for exactly this reason -- see their doc
/// comments), and [OpheliaNavigationSnapshot]'s "nothing has happened
/// yet" default.
///
/// NOT covered here, and not coverable by any automated test on this
/// platform: [OpheliaAudioHandler]'s actual behavior once
/// `AudioPlayer.setAudioSource`/`play`/`pause`/`seek` are called (real
/// decoding and audio output), `audio_service`'s lock-screen/
/// notification/headset-button integration, and background survival.
/// `flutter test` has no native `just_audio`/`audio_service` platform
/// channel implementations registered, so calling into either plugin's
/// real methods here would either throw `MissingPluginException` or
/// exercise nothing meaningful. The shuffle/repeat/skip navigation
/// *decision* algorithm in `performSkipNext`/`performSkipPrevious` was
/// ported field-for-field from `FakePlaybackEnginePort`'s already-tested
/// algorithm (see test/data/fakes/fake_playback_engine_port_test.dart)
/// and reviewed for parity, but its integration with a real player is
/// unverified here -- see this task's manual-QA notes for how to verify
/// it for real, via `flutter run` on a device/emulator.
void main() {
  group('audioSourceForPath', () {
    test('an asset: prefix resolves to a Flutter asset source', () {
      final source = audioSourceForPath(
        '${assetSourcePrefix}assets/test_audio/test_track.wav',
      ) as UriAudioSource;

      expect(
        source.uri,
        Uri.parse('asset:///assets/test_audio/test_track.wav'),
      );
    });

    test('an http(s) URL resolves to a network source', () {
      final source =
          audioSourceForPath('https://stream.ophelia.fake/t1') as UriAudioSource;

      expect(source.uri, Uri.parse('https://stream.ophelia.fake/t1'));
    });

    test('anything else resolves to a local file source', () {
      final source = audioSourceForPath('/downloads/t1.mp3') as UriAudioSource;

      expect(source.uri, Uri.file('/downloads/t1.mp3'));
    });
  });

  group('failureForLoadException', () {
    test('a network (http/https) source path maps to NetworkFailure', () {
      final failure = failureForLoadException(
        Exception('connection refused'),
        'https://stream.ophelia.fake/t1',
      );

      expect(failure, isA<NetworkFailure>());
    });

    test('a local file or asset source path maps to StorageFailure', () {
      final failure = failureForLoadException(
        Exception('file not found'),
        '/downloads/t1.mp3',
      );

      expect(failure, isA<StorageFailure>());
    });

    test(
      'a PlayerException\'s own message is used, not just toString()',
      () {
        final failure = failureForLoadException(
          PlayerException(1, 'source not supported', null),
          '/downloads/t1.mp3',
        );

        expect(failure.message, 'source not supported');
      },
    );
  });

  group('OpheliaNavigationSnapshot.initial', () {
    test('represents an engine that has never played anything', () {
      final snapshot = OpheliaNavigationSnapshot.initial();

      expect(snapshot.currentTrack, isNull);
      expect(snapshot.currentSourcePath, isNull);
      expect(snapshot.position, Duration.zero);
      expect(snapshot.isPlaying, isFalse);
      expect(snapshot.queue, isEmpty);
      expect(snapshot.currentIndex, -1);
      expect(snapshot.shuffleHistory, isEmpty);
    });
  });
}
