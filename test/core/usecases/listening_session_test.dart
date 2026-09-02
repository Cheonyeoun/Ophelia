import 'package:test/test.dart';
import 'package:ophelia/core/usecases/listening_session.dart';

void main() {
  test('finish returns null when nothing has been started', () {
    final session = ListeningSession();

    expect(session.finish(), isNull);
  });

  test('finish returns a listening event with the real elapsed time', () {
    var clock = DateTime(2026, 1, 1, 12);
    final session = ListeningSession(now: () => clock);

    session.start('t1');
    clock = clock.add(const Duration(seconds: 30));
    final event = session.finish();

    expect(event, isNotNull);
    expect(event!.trackId, 't1');
    expect(event.playedAt, DateTime(2026, 1, 1, 12));
    expect(event.msPlayed, 30000);
  });

  test('finish clears the session, returning null on a second call', () {
    var clock = DateTime(2026, 1, 1, 12);
    final session = ListeningSession(now: () => clock);

    session.start('t1');
    clock = clock.add(const Duration(seconds: 5));
    session.finish();

    expect(session.finish(), isNull);
  });

  test('start replaces whatever was being tracked before', () {
    var clock = DateTime(2026, 1, 1, 12);
    final session = ListeningSession(now: () => clock);

    session.start('t1');
    clock = clock.add(const Duration(seconds: 5));
    session.start('t2');
    clock = clock.add(const Duration(seconds: 10));
    final event = session.finish();

    expect(event!.trackId, 't2');
    expect(event.msPlayed, 10000);
  });
}
