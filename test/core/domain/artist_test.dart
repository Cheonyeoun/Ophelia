import 'package:test/test.dart';
import 'package:ophelia/core/domain/artist.dart';

void main() {
  const artist = Artist(id: 'ar1', name: 'Artist name');

  test('construction exposes the given field values', () {
    expect(artist.id, 'ar1');
    expect(artist.name, 'Artist name');
  });

  test('two instances with the same values are equal', () {
    const other = Artist(id: 'ar1', name: 'Artist name');

    expect(artist, equals(other));
    expect(artist.hashCode, equals(other.hashCode));
  });

  test('a differing field makes instances unequal', () {
    const other = Artist(id: 'ar1', name: 'Different name');

    expect(artist, isNot(equals(other)));
  });

  test('copyWith changes only the given field', () {
    final updated = artist.copyWith(name: 'New name');

    expect(updated.name, 'New name');
    expect(updated.id, artist.id);
  });
}
