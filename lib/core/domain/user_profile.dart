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

  UserProfile copyWith({
    String? displayName,
    String? backgroundImagePath,
    String? profileImagePath,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      profileImagePath: profileImagePath ?? this.profileImagePath,
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
