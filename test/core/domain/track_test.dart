import 'package:test/test.dart';
import 'package:ophelia/core/domain/track.dart';

void main() {
  const track = Track(
    id: 't1',
    title: 'Song',
    artist: 'Artist',
    album: 'Album',
    durationMs: 210000,
    coverArtPath: '/cover.jpg',
    sourceType: TrackSourceType.streamed,
  );

  test('construction exposes the given field values', () {
    expect(track.id, 't1');
    expect(track.title, 'Song');
    expect(track.artist, 'Artist');
    expect(track.album, 'Album');
    expect(track.durationMs, 210000);
    expect(track.coverArtPath, '/cover.jpg');
    expect(track.sourceType, TrackSourceType.streamed);
  });

  test('two instances with the same values are equal', () {
    const other = Track(
      id: 't1',
      title: 'Song',
      artist: 'Artist',
      album: 'Album',
      durationMs: 210000,
      coverArtPath: '/cover.jpg',
      sourceType: TrackSourceType.streamed,
    );

    expect(track, equals(other));
    expect(track.hashCode, equals(other.hashCode));
  });

  test('a differing field makes instances unequal', () {
    const other = Track(
      id: 't1',
      title: 'Different title',
      artist: 'Artist',
      album: 'Album',
      durationMs: 210000,
      coverArtPath: '/cover.jpg',
      sourceType: TrackSourceType.streamed,
    );

    expect(track, isNot(equals(other)));
  });

  test('copyWith changes only the given field', () {
    final updated = track.copyWith(title: 'New title');

    expect(updated.title, 'New title');
    expect(updated.id, track.id);
    expect(updated.artist, track.artist);
    expect(updated.album, track.album);
    expect(updated.durationMs, track.durationMs);
    expect(updated.coverArtPath, track.coverArtPath);
    expect(updated.sourceType, track.sourceType);
  });

  test('copyWith(clearCoverArtPath: true) sets coverArtPath to null', () {
    final updated = track.copyWith(clearCoverArtPath: true);

    expect(updated.coverArtPath, isNull);
    expect(updated.id, track.id);
    expect(updated.title, track.title);
    expect(updated.artist, track.artist);
    expect(updated.album, track.album);
    expect(updated.durationMs, track.durationMs);
    expect(updated.sourceType, track.sourceType);
  });
}
