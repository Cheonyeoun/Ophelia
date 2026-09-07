import 'package:test/test.dart';

import 'package:ophelia/data/fakes/fake_download_port.dart';
import 'package:ophelia/data/fakes/fake_media_source_port.dart';
import 'package:ophelia/playback/engine/just_audio_playback_adapter.dart';
import 'package:ophelia/playback/engine/ophelia_audio_handler.dart';

/// Deliberately narrow: every `PlaybackEnginePort` method on
/// [JustAudioPlaybackAdapter] other than the two covered below awaits
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
/// synchronous getters that never await the handler themselves, so they
/// can be read before it's ever been touched without risking a call into
/// the missing platform plugin.
void main() {
  test(
    'currentIndex is -1 before anything has ever played -- the same '
    '"nothing set" default FakePlaybackEnginePort starts at',
    () {
      final adapter = JustAudioPlaybackAdapter(
        mediaSource: FakeMediaSourcePort(),
        downloads: FakeDownloadPort(),
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
      );

      final snapshot =
          adapter.captureNavigationState() as OpheliaNavigationSnapshot;

      expect(snapshot.currentTrack, isNull);
      expect(snapshot.currentIndex, -1);
      expect(snapshot.queue, isEmpty);
      expect(snapshot.isPlaying, isFalse);
    },
  );
}
