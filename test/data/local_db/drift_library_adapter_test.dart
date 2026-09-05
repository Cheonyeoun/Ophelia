import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:ophelia/core/domain/listening_event.dart';
import 'package:ophelia/core/domain/playlist.dart';
import 'package:ophelia/core/domain/user_profile.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/data/local_db/database.dart'
    hide Playlist, ListeningEvent;
import 'package:ophelia/data/local_db/drift_library_adapter.dart';

import '../../support/result_test_helpers.dart';

void main() {
  late OpheliaDatabase database;
  late DriftLibraryAdapter adapter;

  setUp(() {
    // In-memory, not the real isolate-backed connection -- see
    // docs/architecture.md §5.3 and OpheliaDatabase's own doc comment on
    // why the executor is overridable.
    database = OpheliaDatabase(NativeDatabase.memory());
    adapter = DriftLibraryAdapter(database);
  });

  tearDown(() => database.close());

  group('playlists', () {
    test('getPlaylists is empty against a fresh database', () async {
      expect(unwrapValue(await adapter.getPlaylists()), isEmpty);
    });

    test('savePlaylist creates a new playlist, retrievable by id and in '
        'getPlaylists', () async {
      final playlist = Playlist(
        id: 'p1',
        name: 'Night drift',
        trackIds: ['t3', 't1', 't5'],
      );

      unwrapValue(await adapter.savePlaylist(playlist));

      expect(unwrapValue(await adapter.getPlaylist('p1')), playlist);
      expect(unwrapValue(await adapter.getPlaylists()), [playlist]);
    });

    test('savePlaylist preserves track order, including a track appearing '
        'more than once', () async {
      final playlist = Playlist(
        id: 'p1',
        name: 'Repeats',
        trackIds: ['t1', 't2', 't1'],
      );

      unwrapValue(await adapter.savePlaylist(playlist));

      expect(
        unwrapValue(await adapter.getPlaylist('p1')).trackIds,
        ['t1', 't2', 't1'],
      );
    });

    test('savePlaylist updates an existing playlist (same id) instead of '
        'creating a second one', () async {
      await adapter.savePlaylist(
        Playlist(id: 'p1', name: 'Original', trackIds: ['t1']),
      );

      final updated = Playlist(
        id: 'p1',
        name: 'Renamed',
        trackIds: ['t2', 't3'],
      );
      unwrapValue(await adapter.savePlaylist(updated));

      final all = unwrapValue(await adapter.getPlaylists());
      expect(all, [updated]);
    });

    test('getPlaylist fails with NotFoundFailure for an unknown id', () async {
      final failure = unwrapFailure(await adapter.getPlaylist('missing'));
      expect(failure, isA<NotFoundFailure>());
    });

    test('deletePlaylist removes a playlist', () async {
      await adapter.savePlaylist(
        Playlist(id: 'p1', name: 'Gone soon', trackIds: ['t1']),
      );

      unwrapValue(await adapter.deletePlaylist('p1'));

      expect(unwrapValue(await adapter.getPlaylists()), isEmpty);
    });

    test(
      'deletePlaylist fails with NotFoundFailure for an unknown id',
      () async {
        final failure = unwrapFailure(await adapter.deletePlaylist('missing'));
        expect(failure, isA<NotFoundFailure>());
      },
    );

    test(
      'deleting a playlist cascades to its playlist_tracks rows, instead '
      'of leaving them behind as orphans referencing a playlist that no '
      'longer exists',
      () async {
        await adapter.savePlaylist(
          Playlist(id: 'p1', name: 'Night drift', trackIds: ['t3', 't1']),
        );

        final tracksBefore = await database.select(database.playlistTracks).get();
        expect(tracksBefore, hasLength(2));

        unwrapValue(await adapter.deletePlaylist('p1'));

        final tracksAfter = await database.select(database.playlistTracks).get();
        expect(tracksAfter, isEmpty);
      },
    );
  });

  group('profile', () {
    test('getProfile fails with NotFoundFailure before one is ever saved', () async {
      final failure = unwrapFailure(await adapter.getProfile());
      expect(failure, isA<NotFoundFailure>());
    });

    test('saveProfile creates the profile when none exists yet', () async {
      const profile = UserProfile(
        displayName: 'Maren Iyer',
        backgroundImagePath: '/images/bg.jpg',
        profileImagePath: '/images/avatar.jpg',
      );

      unwrapValue(await adapter.saveProfile(profile));

      expect(unwrapValue(await adapter.getProfile()), profile);
    });

    test('saveProfile updates the existing profile rather than creating a '
        'second row', () async {
      await adapter.saveProfile(
        const UserProfile(displayName: 'Original Name'),
      );
      await adapter.saveProfile(
        const UserProfile(displayName: 'Updated Name'),
      );

      expect(
        unwrapValue(await adapter.getProfile()).displayName,
        'Updated Name',
      );
      final rows = await database.select(database.profile).get();
      expect(rows, hasLength(1));
    });

    test('saveProfile can clear an optional path back to null', () async {
      await adapter.saveProfile(
        const UserProfile(
          displayName: 'Maren Iyer',
          backgroundImagePath: '/images/bg.jpg',
        ),
      );
      await adapter.saveProfile(const UserProfile(displayName: 'Maren Iyer'));

      final profile = unwrapValue(await adapter.getProfile());
      expect(profile.backgroundImagePath, isNull);
    });
  });

  group('listening events', () {
    test('getListeningEvents is empty against a fresh database', () async {
      expect(unwrapValue(await adapter.getListeningEvents()), isEmpty);
    });

    test('recordListeningEvent persists events, returned by '
        'getListeningEvents', () async {
      final event = ListeningEvent(
        trackId: 't1',
        playedAt: DateTime.utc(2026, 8, 20, 9, 30),
        msPlayed: 180000,
      );

      unwrapValue(await adapter.recordListeningEvent(event));

      final events = unwrapValue(await adapter.getListeningEvents());
      expect(events, hasLength(1));
      expect(events.single.trackId, 't1');
      expect(events.single.msPlayed, 180000);
      // Drift's default DateTime storage is whole-seconds precision, so
      // compare via isAtSameMomentAs after truncating milliseconds rather
      // than requiring exact equality down to the millisecond.
      expect(
        events.single.playedAt.difference(event.playedAt).inSeconds,
        0,
      );
    });

    test('recordListeningEvent accumulates multiple events for the same '
        'track without overwriting earlier ones', () async {
      await adapter.recordListeningEvent(
        ListeningEvent(
          trackId: 't1',
          playedAt: DateTime.utc(2026, 8, 20),
          msPlayed: 100,
        ),
      );
      await adapter.recordListeningEvent(
        ListeningEvent(
          trackId: 't1',
          playedAt: DateTime.utc(2026, 8, 21),
          msPlayed: 200,
        ),
      );

      final events = unwrapValue(await adapter.getListeningEvents());
      expect(events, hasLength(2));
    });
  });
}
