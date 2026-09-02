import 'package:test/test.dart';
import 'package:ophelia/core/domain/user_profile.dart';

void main() {
  const profile = UserProfile(
    displayName: 'Jane',
    backgroundImagePath: '/bg.jpg',
    profileImagePath: '/avatar.jpg',
  );

  test('construction exposes the given field values', () {
    expect(profile.displayName, 'Jane');
    expect(profile.backgroundImagePath, '/bg.jpg');
    expect(profile.profileImagePath, '/avatar.jpg');
  });

  test('two instances with the same values are equal', () {
    const other = UserProfile(
      displayName: 'Jane',
      backgroundImagePath: '/bg.jpg',
      profileImagePath: '/avatar.jpg',
    );

    expect(profile, equals(other));
    expect(profile.hashCode, equals(other.hashCode));
  });

  test('a differing field makes instances unequal', () {
    const other = UserProfile(
      displayName: 'Jane',
      backgroundImagePath: '/different-bg.jpg',
      profileImagePath: '/avatar.jpg',
    );

    expect(profile, isNot(equals(other)));
  });

  test('copyWith changes only the given field', () {
    final updated = profile.copyWith(displayName: 'Janet');

    expect(updated.displayName, 'Janet');
    expect(updated.backgroundImagePath, profile.backgroundImagePath);
    expect(updated.profileImagePath, profile.profileImagePath);
  });

  test(
    'copyWith(clearBackgroundImagePath: true) sets backgroundImagePath to '
    'null',
    () {
      final updated = profile.copyWith(clearBackgroundImagePath: true);

      expect(updated.backgroundImagePath, isNull);
      expect(updated.displayName, profile.displayName);
      expect(updated.profileImagePath, profile.profileImagePath);
    },
  );

  test(
    'copyWith(clearProfileImagePath: true) sets profileImagePath to null',
    () {
      final updated = profile.copyWith(clearProfileImagePath: true);

      expect(updated.profileImagePath, isNull);
      expect(updated.displayName, profile.displayName);
      expect(updated.backgroundImagePath, profile.backgroundImagePath);
    },
  );
}
