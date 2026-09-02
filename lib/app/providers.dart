import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/domain/download_port.dart';
import '../core/domain/export_import_port.dart';
import '../core/domain/local_library_port.dart';
import '../core/domain/media_source_port.dart';
import '../core/domain/playback_engine_port.dart';
import '../core/domain/playlist.dart';
import '../core/domain/track.dart';
import '../core/domain/user_profile.dart';
import '../core/error/result.dart';
import '../core/usecases/build_queue.dart';
import '../core/usecases/compute_top_songs.dart';
import '../core/usecases/download_track.dart';
import '../core/usecases/export_library.dart';
import '../core/usecases/import_library.dart';
import '../core/usecases/listening_session.dart';
import '../core/usecases/pause_track.dart';
import '../core/usecases/play_track.dart';
import '../core/usecases/remove_download.dart';
import '../core/usecases/save_playlist.dart';
import '../core/usecases/search_catalog.dart';
import '../core/usecases/seek_by.dart';
import '../core/usecases/skip_next.dart';
import '../core/usecases/skip_previous.dart';
import '../core/usecases/toggle_immersive.dart';
import '../core/usecases/toggle_repeat_mode.dart';
import '../core/usecases/toggle_shuffle.dart';
import '../core/usecases/update_profile.dart';
import '../data/fakes/fake_download_port.dart';
import '../data/fakes/fake_export_import_port.dart';
import '../data/fakes/fake_local_library_port.dart';
import '../data/fakes/fake_media_source_port.dart';
import '../data/fakes/fake_playback_engine_port.dart';

// Top-level provider wiring / composition root (docs/architecture.md
// §3.4). Screens call use cases through these providers — never
// adapters/fakes directly. Swapping a real adapter in for a fake later
// means overriding the one port provider it backs; nothing else changes.
//
// The port providers below wire in the fakes from lib/data/fakes/ —
// temporary, UI-development-only stand-ins (see that folder's doc
// comments) — until the real adapters under lib/data/ and
// lib/playback/engine/ exist.

final mediaSourceProvider = Provider<MediaSourcePort>(
  (ref) => FakeMediaSourcePort(),
);

final localLibraryProvider = Provider<LocalLibraryPort>(
  (ref) => FakeLocalLibraryPort(),
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

final seekByProvider = Provider<SeekBy>(
  (ref) => SeekBy(ref.watch(playbackEngineProvider)),
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

final toggleImmersiveProvider = Provider<ToggleImmersive>(
  (ref) => const ToggleImmersive(),
);

final toggleShuffleProvider = Provider<ToggleShuffle>(
  (ref) => ToggleShuffle(ref.watch(playbackEngineProvider)),
);

final toggleRepeatModeProvider = Provider<ToggleRepeatMode>(
  (ref) => ToggleRepeatMode(ref.watch(playbackEngineProvider)),
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
