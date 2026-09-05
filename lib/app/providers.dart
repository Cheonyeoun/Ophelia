import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/domain/download_port.dart';
import '../core/domain/export_import_port.dart';
import '../core/domain/local_library_port.dart';
import '../core/domain/media_source_port.dart';
import '../core/domain/playback_engine_port.dart';
import '../core/domain/playlist.dart';
import '../core/domain/settings.dart';
import '../core/domain/settings_port.dart';
import '../core/domain/track.dart';
import '../core/domain/user_profile.dart';
import '../core/error/result.dart';
import '../core/usecases/build_queue.dart';
import '../core/usecases/compute_top_songs.dart';
import '../core/usecases/download_track.dart';
import '../core/usecases/export_library.dart';
import '../core/usecases/get_artist_tracks.dart';
import '../core/usecases/get_playlist_tracks.dart';
import '../core/usecases/import_library.dart';
import '../core/usecases/listening_session.dart';
import '../core/usecases/pause_track.dart';
import '../core/usecases/play_track.dart';
import '../core/usecases/remove_download.dart';
import '../core/usecases/resume_track.dart';
import '../core/usecases/save_playlist.dart';
import '../core/usecases/search_catalog.dart';
import '../core/usecases/seek_by.dart';
import '../core/usecases/seek_to.dart';
import '../core/usecases/set_connected_server.dart';
import '../core/usecases/set_download_quality.dart';
import '../core/usecases/set_streaming_quality.dart';
import '../core/usecases/skip_next.dart';
import '../core/usecases/skip_previous.dart';
import '../core/usecases/toggle_gapless_playback.dart';
import '../core/usecases/toggle_immersive.dart';
import '../core/usecases/toggle_repeat_mode.dart';
import '../core/usecases/toggle_shuffle.dart';
import '../core/usecases/toggle_wifi_only_downloads.dart';
import '../core/usecases/update_profile.dart';
import '../data/fakes/fake_download_port.dart';
import '../data/fakes/fake_export_import_port.dart';
import '../data/fakes/fake_media_source_port.dart';
import '../data/fakes/fake_playback_engine_port.dart';
import '../data/fakes/fake_settings_port.dart';
import '../data/local_db/database.dart' hide Playlist;
import '../data/local_db/drift_library_adapter.dart';
import '../features/settings/settings_state.dart';

// Top-level provider wiring / composition root (docs/architecture.md
// §3.4). Screens call use cases through these providers — never
// adapters/fakes directly. Swapping a real adapter in for a fake later
// means overriding the one port provider it backs; nothing else changes.
//
// Most port providers below still wire in the fakes from lib/data/fakes/
// — temporary, UI-development-only stand-ins (see that folder's doc
// comments) — until their real adapters exist. `localLibraryProvider` is
// the first exception: it's backed by the real `DriftLibraryAdapter`
// (lib/data/local_db/) now. Widget tests that want the fake's predictable
// sample data instead must override it explicitly in their `ProviderScope`
// with `FakeLocalLibraryPort()`.

final mediaSourceProvider = Provider<MediaSourcePort>(
  (ref) => FakeMediaSourcePort(),
);

/// The app's single Drift database instance — see
/// lib/data/local_db/database.dart. Closed when this provider is
/// disposed so the background isolate it opened doesn't leak.
final opheliaDatabaseProvider = Provider<OpheliaDatabase>((ref) {
  final db = OpheliaDatabase();
  ref.onDispose(db.close);
  return db;
});

final localLibraryProvider = Provider<LocalLibraryPort>(
  (ref) => DriftLibraryAdapter(ref.watch(opheliaDatabaseProvider)),
);

final downloadPortProvider = Provider<DownloadPort>(
  (ref) => FakeDownloadPort(),
);

final playbackEngineProvider = Provider<PlaybackEnginePort>(
  (ref) => FakePlaybackEnginePort(),
);

final exportImportProvider = Provider<ExportImportPort>(
  (ref) => FakeExportImportPort(),
);

final settingsPortProvider = Provider<SettingsPort>(
  (ref) => FakeSettingsPort(),
);

/// Shared between PlayTrack, PauseTrack, SkipNext, and SkipPrevious so
/// they agree on what's currently being timed (see
/// core/usecases/listening_session.dart).
final listeningSessionProvider = Provider<ListeningSession>(
  (ref) => ListeningSession(),
);

final playTrackProvider = Provider<PlayTrack>(
  (ref) => PlayTrack(
    ref.watch(playbackEngineProvider),
    ref.watch(mediaSourceProvider),
    ref.watch(downloadPortProvider),
    ref.watch(listeningSessionProvider),
  ),
);

final pauseTrackProvider = Provider<PauseTrack>(
  (ref) => PauseTrack(
    ref.watch(playbackEngineProvider),
    ref.watch(localLibraryProvider),
    ref.watch(listeningSessionProvider),
  ),
);

final resumeTrackProvider = Provider<ResumeTrack>(
  (ref) => ResumeTrack(
    ref.watch(playbackEngineProvider),
    ref.watch(listeningSessionProvider),
  ),
);

final seekByProvider = Provider<SeekBy>(
  (ref) => SeekBy(ref.watch(playbackEngineProvider)),
);

final seekToProvider = Provider<SeekTo>(
  (ref) => SeekTo(ref.watch(playbackEngineProvider)),
);

final skipNextProvider = Provider<SkipNext>(
  (ref) => SkipNext(
    ref.watch(playbackEngineProvider),
    ref.watch(localLibraryProvider),
    ref.watch(listeningSessionProvider),
  ),
);

final skipPreviousProvider = Provider<SkipPrevious>(
  (ref) => SkipPrevious(
    ref.watch(playbackEngineProvider),
    ref.watch(localLibraryProvider),
    ref.watch(listeningSessionProvider),
  ),
);

final searchCatalogProvider = Provider<SearchCatalog>(
  (ref) => SearchCatalog(ref.watch(mediaSourceProvider)),
);

final buildQueueProvider = Provider<BuildQueue>(
  (ref) => BuildQueue(
    ref.watch(mediaSourceProvider),
    ref.watch(playbackEngineProvider),
  ),
);

final getArtistTracksProvider = Provider<GetArtistTracks>(
  (ref) => GetArtistTracks(ref.watch(mediaSourceProvider)),
);

final getPlaylistTracksProvider = Provider<GetPlaylistTracks>(
  (ref) => GetPlaylistTracks(ref.watch(mediaSourceProvider)),
);

final toggleImmersiveProvider = Provider<ToggleImmersive>(
  (ref) => const ToggleImmersive(),
);

final toggleShuffleProvider = Provider<ToggleShuffle>(
  (ref) => ToggleShuffle(ref.watch(playbackEngineProvider)),
);

final toggleRepeatModeProvider = Provider<ToggleRepeatMode>(
  (ref) => ToggleRepeatMode(ref.watch(playbackEngineProvider)),
);

final setStreamingQualityProvider = Provider<SetStreamingQuality>(
  (ref) => SetStreamingQuality(ref.watch(settingsPortProvider)),
);

final toggleGaplessPlaybackProvider = Provider<ToggleGaplessPlayback>(
  (ref) => ToggleGaplessPlayback(ref.watch(settingsPortProvider)),
);

final setDownloadQualityProvider = Provider<SetDownloadQuality>(
  (ref) => SetDownloadQuality(ref.watch(settingsPortProvider)),
);

final toggleWifiOnlyDownloadsProvider = Provider<ToggleWifiOnlyDownloads>(
  (ref) => ToggleWifiOnlyDownloads(ref.watch(settingsPortProvider)),
);

final setConnectedServerProvider = Provider<SetConnectedServer>(
  (ref) => SetConnectedServer(ref.watch(settingsPortProvider)),
);

/// The Settings screen's presentation-layer Notifier (see
/// features/settings/settings_state.dart) — declared here, not alongside
/// the `SettingsController` class, since provider construction belongs in
/// the composition root (docs/architecture.md §4).
final settingsControllerProvider =
    NotifierProvider<SettingsController, Settings>(
  SettingsController.new,
);

final downloadTrackProvider = Provider<DownloadTrack>(
  (ref) => DownloadTrack(ref.watch(downloadPortProvider)),
);

final removeDownloadProvider = Provider<RemoveDownload>(
  (ref) => RemoveDownload(ref.watch(downloadPortProvider)),
);

final computeTopSongsProvider = Provider<ComputeTopSongs>(
  (ref) => ComputeTopSongs(ref.watch(localLibraryProvider)),
);

final exportLibraryProvider = Provider<ExportLibrary>(
  (ref) => ExportLibrary(ref.watch(exportImportProvider)),
);

final importLibraryProvider = Provider<ImportLibrary>(
  (ref) => ImportLibrary(ref.watch(exportImportProvider)),
);

final savePlaylistProvider = Provider<SavePlaylist>(
  (ref) => SavePlaylist(ref.watch(localLibraryProvider)),
);

final updateProfileProvider = Provider<UpdateProfile>(
  (ref) => UpdateProfile(ref.watch(localLibraryProvider)),
);

// ---------------------------------------------------------------------
// Read-only view data for screens, derived from the use cases above.
// There's no dedicated "recently played" or "all tracks" use case, so
// these call SearchCatalog with an empty query — matched against the
// fake catalog's full contents — rather than inventing a new use case
// for a listing this thin layer can already produce.
// ---------------------------------------------------------------------

final allTracksProvider = FutureProvider<List<Track>>((ref) async {
  final result = await ref.watch(searchCatalogProvider)('');
  return switch (result) {
    Success(value: final tracks) => tracks,
    ResultFailure() => const [],
  };
});

final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final result = await ref.watch(localLibraryProvider).getPlaylists();
  return switch (result) {
    Success(value: final playlists) => playlists,
    ResultFailure() => const [],
  };
});

/// A single playlist by id, for the playlist detail screen. A
/// [ResultFailure] (not found, storage, ...) is rethrown rather than
/// swallowed into a default value, so it surfaces as a real
/// `AsyncValue.error` the screen can show and retry — unlike
/// [userProfileProvider]'s "missing profile is a normal, not-yet-set-up
/// state" case, there's no legitimate reading of "this playlist id
/// doesn't resolve" other than an actual problem.
final playlistProvider = FutureProvider.family<Playlist, String>((
  ref,
  id,
) async {
  final result = await ref.watch(localLibraryProvider).getPlaylist(id);
  return switch (result) {
    Success(value: final playlist) => playlist,
    ResultFailure(failure: final f) => throw f,
  };
});

/// [id]'s playlist, resolved to full tracks in order, for the playlist
/// detail screen to display and play from. A failure resolving the
/// playlist itself propagates here too (awaiting [playlistProvider]'s
/// failed future rethrows it) — both routes are watched from
/// `PlaylistScreen`, but retrying either or both invalidates from
/// scratch.
final playlistTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  id,
) async {
  final playlist = await ref.watch(playlistProvider(id).future);
  final result = await ref.watch(getPlaylistTracksProvider)(playlist);
  return switch (result) {
    Success(value: final tracks) => tracks,
    ResultFailure(failure: final f) => throw f,
  };
});

/// Every track credited to [artistName], for the artist detail screen. A
/// [ResultFailure] is rethrown, not swallowed — see [playlistProvider]'s
/// doc comment for why an empty list must only ever mean "genuinely no
/// tracks," never "something went wrong."
final artistTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  artistName,
) async {
  final result = await ref.watch(getArtistTracksProvider)(artistName);
  return switch (result) {
    Success(value: final tracks) => tracks,
    ResultFailure(failure: final f) => throw f,
  };
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final result = await ref.watch(localLibraryProvider).getProfile();
  return switch (result) {
    Success(value: final profile) => profile,
    ResultFailure() => null,
  };
});

/// Tracks currently downloaded. `DownloadPort` only exposes a per-track
/// `isDownloaded` check, not a listing, so this checks every catalog
/// track — fine at this sample-data scale, not how a real adapter with
/// thousands of tracks should do it.
final downloadedTracksProvider = FutureProvider<List<Track>>((ref) async {
  final allTracks = await ref.watch(allTracksProvider.future);
  final downloads = ref.watch(downloadPortProvider);
  final downloaded = <Track>[];
  for (final track in allTracks) {
    final result = await downloads.isDownloaded(track.id);
    if (result case Success(value: true)) {
      downloaded.add(track);
    }
  }
  return downloaded;
});

/// The top tracks by play count over the last 7 days, resolved from
/// ComputeTopSongs's track ids to full [Track]s for display.
final topSongsProvider = FutureProvider<List<Track>>((ref) async {
  final result = await ref.watch(computeTopSongsProvider)(
    window: const Duration(days: 7),
  );
  final ids = switch (result) {
    Success(value: final v) => v,
    ResultFailure() => const <String>[],
  };
  final allTracks = await ref.watch(allTracksProvider.future);
  final byId = {for (final track in allTracks) track.id: track};
  return [for (final id in ids) if (byId[id] != null) byId[id]!];
});
