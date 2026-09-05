import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/app/providers.dart';
import 'package:ophelia/app/router.dart';
import 'package:ophelia/core/domain/listening_event.dart';
import 'package:ophelia/core/domain/local_library_port.dart';
import 'package:ophelia/core/domain/playlist.dart';
import 'package:ophelia/core/domain/user_profile.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/error/result.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';
import 'package:ophelia/features/playback_ui/playback_controller.dart';
import 'package:ophelia/main.dart';

/// Wraps a [FakeLocalLibraryPort], but always fails [getPlaylist] --
/// counting calls so a test can prove a retry action actually re-invokes
/// the lookup rather than being a dead button.
class _FailingPlaylistLibrary implements LocalLibraryPort {
  final FakeLocalLibraryPort inner;
  int getPlaylistCallCount = 0;

  _FailingPlaylistLibrary(this.inner);

  @override
  Future<Result<Playlist, Failure>> getPlaylist(String id) async {
    getPlaylistCallCount++;
    return Result.failure(const StorageFailure('library unavailable'));
  }

  @override
  Future<Result<List<Playlist>, Failure>> getPlaylists() => inner.getPlaylists();

  @override
  Future<Result<void, Failure>> savePlaylist(Playlist playlist) =>
      inner.savePlaylist(playlist);

  @override
  Future<Result<void, Failure>> deletePlaylist(String id) =>
      inner.deletePlaylist(id);

  @override
  Future<Result<UserProfile, Failure>> getProfile() => inner.getProfile();

  @override
  Future<Result<void, Failure>> saveProfile(UserProfile profile) =>
      inner.saveProfile(profile);

  @override
  Future<Result<void, Failure>> recordListeningEvent(ListeningEvent event) =>
      inner.recordListeningEvent(event);

  @override
  Future<Result<List<ListeningEvent>, Failure>> getListeningEvents() =>
      inner.getListeningEvents();
}

/// Covers the previously-missing playlist navigation gap: tapping a
/// playlist card in Library (and Home) now pushes a playlist detail
/// screen instead of immediately playing the whole playlist.
void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localLibraryProvider.overrideWithValue(FakeLocalLibraryPort()),
        ],
        child: const OpheliaApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(OpheliaApp)));
  }

  testWidgets(
    'tapping a playlist card in Library pushes the playlist screen with '
    'its name and ordered tracks, and back returns to Library',
    (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);
      router.go('/library');
      await tester.pumpAndSettle();

      expect(find.text('Night drift'), findsOneWidget);
      await tester.tap(find.text('Night drift'));
      await tester.pumpAndSettle();

      // samplePlaylists' 'Night drift' is [t3, t1, t5] -> Low Tide,
      // Marble & Ash, Quiet Rooms, in that order -- and nothing else.
      expect(find.text('Low Tide'), findsOneWidget);
      expect(find.text('Marble & Ash'), findsOneWidget);
      expect(find.text('Quiet Rooms'), findsOneWidget);
      expect(find.text('Salt Air'), findsNothing);

      // Tapping a playlist card must not have played the playlist
      // immediately (that used to be the old behavior) -- only tapping a
      // track inside the detail screen should.
      expect(
        container.read(playbackControllerProvider).playback.currentTrack,
        isNull,
      );

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('Low Tide'), findsNothing);
      expect(find.text('Night drift'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping a track in the playlist plays it, queued from the whole '
    'playlist starting at that track',
    (tester) async {
      final container = await pumpApp(tester);
      final router = container.read(routerProvider);
      router.push('/playlist/p1');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Marble & Ash'));
      await tester.pumpAndSettle();

      final playback = container.read(playbackControllerProvider).playback;
      expect(playback.currentTrack?.title, 'Marble & Ash');
      expect(
        playback.queue.map((track) => track.title),
        ['Low Tide', 'Marble & Ash', 'Quiet Rooms'],
      );
    },
  );

  testWidgets(
    'a playlist id containing a slash round-trips through the route via '
    'Uri.encodeComponent',
    (tester) async {
      final trickyPlaylist = Playlist(
        id: 'night/drift',
        name: 'Tricky Id',
        trackIds: ['t1'],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLibraryProvider.overrideWithValue(
              FakeLocalLibraryPort(playlists: [trickyPlaylist]),
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
      router.go('/library');
      await tester.pumpAndSettle();

      expect(find.text('Tricky Id'), findsOneWidget);
      await tester.tap(find.text('Tricky Id'));
      await tester.pumpAndSettle();

      // An unencoded id would make go_router see 'night' and 'drift' as
      // two separate path segments and fail to match '/playlist/:id' at
      // all, so landing here with the right playlist's own track (t1,
      // 'Marble & Ash') proves the id round-tripped intact.
      expect(tester.takeException(), isNull);
      expect(find.text('Marble & Ash'), findsOneWidget);
    },
  );

  testWidgets(
    'a ResultFailure from getPlaylist renders the error state with a '
    'working retry action, not an empty-tracks message',
    (tester) async {
      final failingLibrary = _FailingPlaylistLibrary(FakeLocalLibraryPort());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLibraryProvider.overrideWithValue(failingLibrary),
          ],
          child: const OpheliaApp(),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(OpheliaApp)),
      );
      final router = container.read(routerProvider);

      router.push('/playlist/p1');
      await tester.pumpAndSettle();

      expect(find.text('No tracks in this playlist'), findsNothing);
      expect(find.text('library unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      final callsBeforeRetry = failingLibrary.getPlaylistCallCount;
      expect(callsBeforeRetry, greaterThan(0));

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(
        failingLibrary.getPlaylistCallCount,
        greaterThan(callsBeforeRetry),
      );
      expect(find.text('library unavailable'), findsOneWidget);
    },
  );
}
