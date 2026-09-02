import 'package:test/test.dart';
import 'package:ophelia/core/domain/listening_event.dart';

void main() {
  final playedAt = DateTime.utc(2026, 1, 1, 12);
  final event = ListeningEvent(
    trackId: 't1',
    playedAt: playedAt,
    msPlayed: 180000,
  );

  test('construction exposes the given field values', () {
    expect(event.trackId, 't1');
    expect(event.playedAt, playedAt);
    expect(event.msPlayed, 180000);
  });

  test('two instances with the same values are equal', () {
    final other = ListeningEvent(
      trackId: 't1',
      playedAt: playedAt,
      msPlayed: 180000,
    );

    expect(event, equals(other));
    expect(event.hashCode, equals(other.hashCode));
  });

  test('a differing field makes instances unequal', () {
    final other = ListeningEvent(
      trackId: 't1',
      playedAt: playedAt,
      msPlayed: 90000,
    );

    expect(event, isNot(equals(other)));
  });

  test('copyWith changes only the given field', () {
    final updated = event.copyWith(msPlayed: 200000);

    expect(updated.msPlayed, 200000);
    expect(updated.trackId, event.trackId);
    expect(updated.playedAt, event.playedAt);
  });
}
