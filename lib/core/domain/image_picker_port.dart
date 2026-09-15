import '../error/failure.dart';
import '../error/result.dart';

/// Port for letting the user pick an image from their device and
/// persisting it as this app's own file, for a [UserProfile]'s
/// `backgroundImagePath`/`profileImagePath` — see
/// docs/architecture.md §3.1. Implemented by an adapter under
/// lib/data/images/ (see §3.3) — the domain only depends on this
/// interface.
abstract interface class ImagePickerPort {
  /// Opens the platform's image picker and, if the user picked one,
  /// copies it into this app's own persistent storage before returning
  /// that copy's path — never the picker's own transient path (typically
  /// a temp/cache location the OS makes no promise about beyond this
  /// launch), the same way a downloaded audio track is copied into this
  /// app's own storage rather than played from wherever it was fetched
  /// from (see `DownloadPort.download`). `null` if the user cancelled.
  Future<Result<String?, Failure>> pickAndPersistImage();
}
