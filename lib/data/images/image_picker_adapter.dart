import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/domain/image_picker_port.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';

/// Real [ImagePickerPort] adapter: `package:image_picker` for the OS
/// image picker, `package:path_provider` + `dart:io` to copy the picked
/// file into this app's own persistent `profile_images/` subdirectory of
/// its documents directory before ever handing back a path — see that
/// port's own doc comment for why the picker's own (typically temp/
/// cache) path is never returned as-is.
///
/// Not directly unit-testable in `flutter test`'s Dart-VM harness --
/// both `ImagePicker` and `getApplicationDocumentsDirectory()` need a
/// real platform channel, the same constraint `LocalFileSourceAdapter`'s
/// own doc comment describes for `file_picker`. `FakeImagePickerPort`
/// (lib/data/fakes/) stands in for every test/dev purpose instead.
class ImagePickerAdapter implements ImagePickerPort {
  final ImagePicker _picker;

  ImagePickerAdapter({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  Future<Result<String?, Failure>> pickAndPersistImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return const Result.success(null);

      final documentsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(documentsDir.path, 'profile_images'));
      await imagesDir.create(recursive: true);

      // Timestamped, not the picked file's own name -- two different
      // pictures picked from the same source (e.g. a screenshot re-saved
      // under the same name) must never collide and silently overwrite
      // each other's persisted copy.
      final destPath = p.join(
        imagesDir.path,
        '${DateTime.now().microsecondsSinceEpoch}${p.extension(picked.path)}',
      );
      await File(picked.path).copy(destPath);
      return Result.success(destPath);
    } catch (e) {
      return Result.failure(StorageFailure(e.toString()));
    }
  }
}
