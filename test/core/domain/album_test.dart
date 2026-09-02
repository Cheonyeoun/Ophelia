import 'package:test/test.dart';
import 'package:ophelia/core/domain/album.dart';

void main() {
  const album = Album(
    id: 'a1',
    title: 'Album title',
    artist: 'Artist',
    coverArtPath: '/cover.jpg',
  );

  test('construction exposes the given field values', () {
    expect(album.id, 'a1');
    expect(album.title, 'Album title');
    expect(album.artist, 'Artist');
    expect(album.coverArtPath, '/cover.jpg');
  });

  test('two instances with the same values are equal', () {
    const other = Album(
      id: 'a1',
      title: 'Album title',
      artist: 'Artist',
      coverArtPath: '/cover.jpg',
    );

    expect(album, equals(other));
    expect(album.hashCode, equals(other.hashCode));
  });

  test('a differing field makes instances unequal', () {
    const other = Album(
      id: 'a1',
      title: 'Different title',
      artist: 'Artist',
      coverArtPath: '/cover.jpg',
    );

    expect(album, isNot(equals(other)));
  });

  test('copyWith changes only the given field', () {
    final updated = album.copyWith(artist: 'New artist');

    expect(updated.artist, 'New artist');
    expect(updated.id, album.id);
    expect(updated.title, album.title);
    expect(updated.coverArtPath, album.coverArtPath);
  });

  test('copyWith(clearCoverArtPath: true) sets coverArtPath to null', () {
    final updated = album.copyWith(clearCoverArtPath: true);

    expect(updated.coverArtPath, isNull);
    expect(updated.id, album.id);
    expect(updated.title, album.title);
    expect(updated.artist, album.artist);
  });
}
