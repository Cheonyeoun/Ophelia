import '../error/failure.dart';
import '../error/result.dart';
import 'track.dart';

/// Port for browsing and linking folders on the device's own storage as a
/// music source — `Track`s with `sourceType: TrackSourceType.local` (see
/// docs/architecture.md §3.1). Implemented by an adapter under
/// lib/data/local_files/ (see §3.3) — the domain only depends on this
/// interface.
///
/// Deliberately separate from [LocalLibraryPort]: that port persists data
/// this app owns outright (playlists, profile, listening history); this
/// one wraps OS-level folder access (picking, scanning) plus the small
/// amount of bookkeeping (which folders are linked) needed to remember
/// that access across app restarts. A real adapter still uses the same
/// Drift database as [LocalLibraryPort] for that bookkeeping — see
/// `LocalFileSourceAdapter`'s own doc comment — but through a separate
/// class implementing this separate port, not by extending
/// `DriftLibraryAdapter`.
abstract interface class LocalFileSourcePort {
  /// Opens the platform's folder picker and returns the picked folder's
  /// identifier, or `null` if the user cancelled. This is *not* itself
  /// enough to make the folder available across app restarts — call
  /// [linkFolder] with the result to actually remember it (see
  /// `core/usecases/link_folder.dart`, which does both in sequence).
  ///
  /// What this identifier actually is is platform-dependent — see
  /// `LocalFileSourceAdapter`'s doc comment for exactly what each
  /// platform returns and why full recursive folder access can't be
  /// promised uniformly (most notably on Android's scoped storage and
  /// iOS's app sandbox).
  Future<Result<String?, Failure>> pickFolder();

  /// Scans [pathOrUri] (from [pickFolder] or [getLinkedFolders]) for
  /// audio files, returning each as a [Track] with
  /// `sourceType: TrackSourceType.local`. Each returned track's `id`
  /// encodes enough for [getSourcePath] to resolve it back to a playable
  /// path later — see that method.
  Future<Result<List<Track>, Failure>> scanFolder(String pathOrUri);

  /// Persists [pathOrUri] (from [pickFolder]) so it survives app
  /// restarts and shows up in [getLinkedFolders] — the write-side
  /// counterpart to [removeLinkedFolder]. Does not itself scan the
  /// folder; call [scanFolder] separately for its tracks.
  Future<Result<void, Failure>> linkFolder(String pathOrUri);

  Future<Result<List<String>, Failure>> getLinkedFolders();

  Future<Result<void, Failure>> removeLinkedFolder(String pathOrUri);

  /// Resolves [trackId] (as produced by [scanFolder]) back to its
  /// playable path, for `PlayTrack` to hand to
  /// `PlaybackEnginePort.play` — mirroring `DownloadPort.getLocalPath`/
  /// `MediaSourcePort.getStreamUrl`'s role for the other two source
  /// kinds (see play_track.dart). Fails with [NotFoundFailure] for any
  /// id this port didn't produce.
  Future<Result<String, Failure>> getSourcePath(String trackId);
}
