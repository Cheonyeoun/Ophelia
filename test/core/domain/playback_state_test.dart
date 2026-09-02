import 'package:test/test.dart';
import 'package:ophelia/core/domain/playback_state.dart';
import 'package:ophelia/core/domain/track.dart';

void main() {
  const trackA = Track(
    id: 't1',
    title: 'Song A',
    artist: 'Artist',
    album: 'Album',
    durationMs: 200000,
    sourceType: TrackSourceType.streamed,
  );
  const trackB = Track(
    id: 't2',
    title: 'Song B',
    artist: 'Artist',
    album: 'Album',
    durationMs: 220000,
    sourceType: TrackSourceType.downloaded,
  );

  final state = PlaybackState(
    currentTrack: trackA,
    position: const Duration(seconds: 30),
    queue: [trackA, trackB],
    isImmersive: false,
    repeatMode: RepeatMode.off,
    shuffle: false,
  );

  test('construction exposes the given field values', () {
    expect(state.currentTrack, trackA);
    expect(state.position, const Duration(seconds: 30));
    expect(state.queue, [trackA, trackB]);
    expect(state.isImmersive, isFalse);
    expect(state.repeatMode, RepeatMode.off);
    expect(state.shuffle, isFalse);
  });

  test('two instances with the same values are equal', () {
    final other = PlaybackState(
      currentTrack: trackA,
      position: const Duration(seconds: 30),
      queue: [trackA, trackB],
      isImmersive: false,
      repeatMode: RepeatMode.off,
      shuffle: false,
    );

    expect(state, equals(other));
    expect(state.hashCode, equals(other.hashCode));
  });

  test('a differing queue makes instances unequal', () {
    final other = PlaybackState(
      currentTrack: trackA,
      position: const Duration(seconds: 30),
      queue: [trackB, trackA],
      isImmersive: false,
      repeatMode: RepeatMode.off,
      shuffle: false,
    );

    expect(state, isNot(equals(other)));
  });

  test('copyWith changes only the given field', () {
    final updated = state.copyWith(
      isImmersive: true,
      repeatMode: RepeatMode.all,
    );

    expect(updated.isImmersive, isTrue);
    expect(updated.repeatMode, RepeatMode.all);
    expect(updated.currentTrack, state.currentTrack);
    expect(updated.position, state.position);
    expect(updated.queue, state.queue);
    expect(updated.shuffle, state.shuffle);
  });

  test('copyWith(clearCurrentTrack: true) sets currentTrack to null', () {
    final updated = state.copyWith(clearCurrentTrack: true);

    expect(updated.currentTrack, isNull);
    expect(updated.position, state.position);
    expect(updated.queue, state.queue);
    expect(updated.isImmersive, state.isImmersive);
    expect(updated.repeatMode, state.repeatMode);
    expect(updated.shuffle, state.shuffle);
  });

  test('mutating the source list after construction does not affect the '
      'playback state', () {
    final source = [trackA, trackB];
    final defensive = PlaybackState(
      position: const Duration(seconds: 5),
      queue: source,
      isImmersive: false,
      repeatMode: RepeatMode.off,
      shuffle: false,
    );

    source.add(trackA);
    source.clear();

    expect(defensive.queue, [trackA, trackB]);
  });

  test('queue cannot be mutated directly', () {
    expect(() => state.queue.add(trackA), throwsUnsupportedError);
  });
}
