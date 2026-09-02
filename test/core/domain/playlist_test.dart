import 'package:test/test.dart';
import 'package:ophelia/core/domain/playlist.dart';

void main() {
  const playlist = Playlist(
    id: 'p1',
    name: 'My playlist',
    trackIds: ['t1', 't2', 't3'],
  );

  test('construction exposes the given field values', () {
    expect(playlist.id, 'p1');
    expect(playlist.name, 'My playlist');
    expect(playlist.trackIds, ['t1', 't2', 't3']);
  });

  test('two instances with the same values are equal', () {
    const other = Playlist(
      id: 'p1',
      name: 'My playlist',
      trackIds: ['t1', 't2', 't3'],
    );

    expect(playlist, equals(other));
    expect(playlist.hashCode, equals(other.hashCode));
  });

  test('a differing track order makes instances unequal', () {
    const other = Playlist(
      id: 'p1',
      name: 'My playlist',
      trackIds: ['t2', 't1', 't3'],
    );

    expect(playlist, isNot(equals(other)));
  });

  test('copyWith changes only the given field', () {
    final updated = playlist.copyWith(trackIds: ['t3', 't2', 't1']);

    expect(updated.trackIds, ['t3', 't2', 't1']);
    expect(updated.id, playlist.id);
    expect(updated.name, playlist.name);
  });
}
