import 'package:test/test.dart';
import 'package:ophelia/core/domain/user_profile.dart';
import 'package:ophelia/core/usecases/update_profile.dart';
import 'package:ophelia/data/fakes/fake_local_library_port.dart';

import '../../support/result_test_helpers.dart';

void main() {
  test('updates the user profile', () async {
    final library = FakeLocalLibraryPort();
    final updateProfile = UpdateProfile(library);
    const newProfile = UserProfile(displayName: 'New Name');

    unwrapValue(await updateProfile(newProfile));

    final saved = unwrapValue(await library.getProfile());
    expect(saved, newProfile);
  });
}
