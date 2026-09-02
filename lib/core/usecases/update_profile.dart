import '../domain/local_library_port.dart';
import '../domain/user_profile.dart';
import '../error/failure.dart';
import '../error/result.dart';

/// Creates or updates the local user's profile.
class UpdateProfile {
  final LocalLibraryPort library;

  UpdateProfile(this.library);

  Future<Result<void, Failure>> call(UserProfile profile) =>
      library.saveProfile(profile);
}
