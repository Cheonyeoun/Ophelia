/// The local user's profile. Immutable value type — no Flutter, no package
/// imports (see Docs/Architecture.md §3.1).
class UserProfile {
  final String displayName;
  final String? backgroundImagePath;
  final String? profileImagePath;

  const UserProfile({
    required this.displayName,
    this.backgroundImagePath,
    this.profileImagePath,
  });

  /// Set [clearBackgroundImagePath]/[clearProfileImagePath] to clear the
  /// corresponding path to null — passing the path alone can't distinguish
  /// "leave unchanged" from "set to null".
  UserProfile copyWith({
    String? displayName,
    String? backgroundImagePath,
    bool clearBackgroundImagePath = false,
    String? profileImagePath,
    bool clearProfileImagePath = false,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      backgroundImagePath: clearBackgroundImagePath
          ? null
          : (backgroundImagePath ?? this.backgroundImagePath),
      profileImagePath: clearProfileImagePath
          ? null
          : (profileImagePath ?? this.profileImagePath),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          backgroundImagePath == other.backgroundImagePath &&
          profileImagePath == other.profileImagePath;

  @override
  int get hashCode =>
      Object.hash(displayName, backgroundImagePath, profileImagePath);
}
