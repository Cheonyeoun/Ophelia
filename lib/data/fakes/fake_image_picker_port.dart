import '../../core/domain/image_picker_port.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';

/// **Temporary, UI-development-only fake — not a production adapter.**
///
/// In-memory stand-in for [ImagePickerPort]: no real image picker, no
/// real filesystem access — [nextPickedPath] stands in for whatever a
/// real pick-and-persist round trip would have returned.
class FakeImagePickerPort implements ImagePickerPort {
  /// What [pickAndPersistImage] returns next — set this before calling
  /// it to simulate the user picking an image, or leave it `null` to
  /// simulate cancelling the picker.
  String? nextPickedPath;

  FakeImagePickerPort({this.nextPickedPath});

  @override
  Future<Result<String?, Failure>> pickAndPersistImage() async {
    return Result.success(nextPickedPath);
  }
}
