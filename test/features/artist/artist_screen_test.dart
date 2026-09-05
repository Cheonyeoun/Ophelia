import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/app/router.dart';
import 'package:ophelia/core/domain/media_source_port.dart';
import 'package:ophelia/core/domain/track.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/error/result.dart';
import 'package:ophelia/data/fakes/fake_media_source_port.dart';
import 'package:ophelia/main.dart';

/// Wraps a [FakeMediaSourcePort], but always fails [getTracksByArtist] --
/// counting calls so a test can prove a retry action actually re-invokes
/// the use case rather than being a dead button.
class _FailingArtistTracksMediaSource implements MediaSourcePort {
  final FakeMediaSourcePort inner;
  int getTracksByArtistCallCount = 0;

  _FailingArtistTracksMediaSource(this.inner);

  @override
  Future<Result<List<Track>, Failure>> getTracksByArtist(
    String artistName,
  ) async {
    getTracksByArtistCallCount++;
    return Result.failure(const NetworkFailure('catalog unavailable'));
  }

  @override
  Future<Result<List<Track>, Failure>> search(String query) =>
      inner.search(query);

  @override
  Future<Result<String, Failure>> getStreamUrl(String trackId) =>
      inner.getStreamUrl(trackId);

  @override
  Future<Result<Track, Failure>> getTrackMetadata(String trackId) =>
      inner.getTrackMetadata(trackId);

  @override
  Future<Result<String, Failure>> getCoverArt(String trackId) =>
      inner.getCoverArt(trackId);
}

/// Covers the previously-missing artist navigation gap: tapping an
/// artist (in Library's Artists tab) now pushes an artist detail screen
/// instead of going nowhere.
void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OpheliaApp()));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(OpheliaApp)));
  }

  testWidgets(
    'tapping an artist in Library pushes the artist screen with their '
    'name and tracks, and back returns to Library',
    (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);
      router.go('/library');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Artists'));
      await tester.pumpAndSettle();

      expect(find.text('Wren Callahan'), findsOneWidget);
      await tester.tap(find.text('Wren Callahan'));
      await tester.pumpAndSettle();

      // The artist screen's title and both of that artist's tracks. The
      // title check tolerates the Library row underneath still being in
      // the widget tree -- the tracks are the reliable proof we're
      // actually on the artist screen with the right data.
      expect(find.text('Wren Callahan'), findsWidgets);
      expect(find.text('Marble & Ash'), findsOneWidget);
      // 'Salt Air' is both t2's title and t1/t2's album, so it
      // legitimately appears more than once here -- findsWidgets just
      // confirms it shows at all.
      expect(find.text('Salt Air'), findsWidgets);
      // A track by a different artist must not show up here.
      expect(find.text('Low Tide'), findsNothing);

      router.pop();
      await tester.pumpAndSettle();

      // Back on Library's Artists tab; the artist screen's content is
      // gone.
      expect(find.text('Marble & Ash'), findsNothing);
      expect(find.text('Wren Callahan'), findsOneWidget);
    },
  );

  testWidgets(
    'an artist name containing a literal % round-trips through the '
    'route without being double-decoded',
    (tester) async {
      const trickyTrack = Track(
        id: 'tricky',
        title: 'Off Beat',
        artist: '50% Off',
        album: 'Sale',
        durationMs: 180000,
        sourceType: TrackSourceType.streamed,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaSourceProvider.overrideWithValue(
              FakeMediaSourcePort(tracks: const [trickyTrack]),
            ),
          ],
          child: const OpheliaApp(),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(OpheliaApp)),
      );
      final router = container.read(routerProvider);

      // Mirrors exactly what library_screen.dart does when pushing this
      // route. A manual Uri.decodeComponent on receipt would double
      // decode this and throw a FormatException trying to parse '% O'
      // (from the already-decoded '50% Off') as percent-encoding.
      router.push('/artist/${Uri.encodeComponent('50% Off')}');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('50% Off'), findsOneWidget);
      expect(find.text('Off Beat'), findsOneWidget);
    },
  );

  testWidgets(
    'a ResultFailure from GetArtistTracks renders the error state with '
    'a working retry action, not an empty-tracks message',
    (tester) async {
      final failingMediaSource = _FailingArtistTracksMediaSource(
        FakeMediaSourcePort(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaSourceProvider.overrideWithValue(failingMediaSource),
          ],
          child: const OpheliaApp(),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(OpheliaApp)),
      );
      final router = container.read(routerProvider);

      router.push('/artist/${Uri.encodeComponent('Wren Callahan')}');
      await tester.pumpAndSettle();

      expect(find.text('No tracks from this artist'), findsNothing);
      expect(find.text('catalog unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      final callsBeforeRetry = failingMediaSource.getTracksByArtistCallCount;
      expect(callsBeforeRetry, greaterThan(0));

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Retry actually re-invoked the use case, not just re-rendered the
      // same cached failure.
      expect(
        failingMediaSource.getTracksByArtistCallCount,
        greaterThan(callsBeforeRetry),
      );
      expect(find.text('catalog unavailable'), findsOneWidget);
    },
  );
}
