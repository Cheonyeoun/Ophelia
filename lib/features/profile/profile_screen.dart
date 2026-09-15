import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout_metrics.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/cover_art.dart';
import '../../app/widgets/screen_top_bar.dart';
import '../../app/widgets/track_row.dart';
import '../../core/domain/track.dart';
import '../../core/domain/user_profile.dart';
import '../../core/error/result.dart';
import '../playback_ui/playback_controller.dart';

/// Profile — pushed from Settings, no nav bar, mini-player still shown.
/// Matches the "Profile" frame in docs/design/ophelia-ui-mockup.html:
/// bruise is used here (the glass-card highlight) and nowhere else,
/// exactly as the mockup's own note prescribes. Only ever pushed once a
/// profile row exists (see SettingsScreen's "Set up profile" gate), but
/// every read below still degrades gracefully if [userProfileProvider]
/// is somehow null rather than assuming that gate always held.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Opens the image picker and, if the user picked one, saves it as
  /// [profile]'s background or profile picture (per [background]) via
  /// [UpdateProfile] — a no-op if the picker returned nothing (cancelled)
  /// or [profile] is still null (nothing to attach the picked image to
  /// yet; see this class's own doc comment on why that's not the normal
  /// path here).
  Future<void> _pickImage(
    WidgetRef ref,
    UserProfile? profile, {
    required bool background,
  }) async {
    if (profile == null) return;
    final result = await ref
        .read(imagePickerPortProvider)
        .pickAndPersistImage();
    final path = switch (result) {
      Success(value: final p) => p,
      ResultFailure() => null,
    };
    if (path == null) return;

    final updated = background
        ? profile.copyWith(backgroundImagePath: path)
        : profile.copyWith(profileImagePath: path);
    await ref.read(updateProfileProvider)(updated);
    ref.invalidate(userProfileProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final topSongs = ref.watch(topSongsProvider);
    final bottomInset = ref.watch(bottomContentInsetProvider);
    final currentProfile = profile.value;

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: ScreenTopBar(
        trailing: IconButton(
          icon: const Icon(Icons.photo_camera_outlined, size: 18),
          color: AppColors.paleDim,
          tooltip: 'Change background',
          onPressed: () => _pickImage(ref, currentProfile, background: true),
        ),
      ),
      body: Stack(
        children: [
          if (currentProfile?.backgroundImagePath != null)
            Positioned.fill(
              child: _BackgroundImage(
                path: currentProfile!.backgroundImagePath!,
              ),
            ),
          ListView(
            padding: EdgeInsets.fromLTRB(18, 0, 18, bottomInset),
            children: [
              const SizedBox(height: 8),
              _ProfileAvatar(
                imagePath: currentProfile?.profileImagePath,
                onTap: () => _pickImage(ref, currentProfile, background: false),
              ),
              const SizedBox(height: 10),
              profile.maybeWhen(
                data: (data) => data == null
                    ? const SizedBox.shrink()
                    : _EditableDisplayName(profile: data),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 18),
              topSongs.when(
                data: (data) => data.isEmpty
                    ? const _EmptyTopSongs()
                    : _TopSongs(tracks: data),
                error: (error, stack) => const _EmptyTopSongs(),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  final String path;

  const _BackgroundImage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(path), fit: BoxFit.cover),
        // A flat scrim, not the mockup's decorative dual-gradient --
        // this is a real user photo, not a fixed backdrop, so the only
        // job left for anything drawn over it is keeping the avatar/name
        // legible regardless of what that photo looks like.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.void_.withValues(alpha: 0.55),
                AppColors.void_,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const _ProfileAvatar({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.ink2,
            backgroundImage: path == null ? null : FileImage(File(path)),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 12,
              color: AppColors.paleDim,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tap the display name to edit it in place; a themed check/close pair
/// replaces the usual keyboard-only submit so the edit is discoverable
/// without knowing to press enter. Local `_editing` state lives here,
/// not on [ProfileScreen] itself, so the rest of that screen stays a
/// plain [ConsumerWidget].
class _EditableDisplayName extends ConsumerStatefulWidget {
  final UserProfile profile;

  const _EditableDisplayName({required this.profile});

  @override
  ConsumerState<_EditableDisplayName> createState() =>
      _EditableDisplayNameState();
}

class _EditableDisplayNameState extends ConsumerState<_EditableDisplayName> {
  bool _editing = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.profile.displayName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    _controller.text = widget.profile.displayName;
    setState(() => _editing = true);
  }

  Future<void> _save() async {
    setState(() => _editing = false);
    final name = _controller.text.trim();
    // An emptied-out name is discarded rather than saved -- a profile
    // with no name at all isn't a state anything else here (or
    // SettingsScreen's own `_ProfileRow`) is prepared to display.
    if (name.isEmpty || name == widget.profile.displayName) return;
    await ref.read(updateProfileProvider)(
      widget.profile.copyWith(displayName: name),
    );
    ref.invalidate(userProfileProvider);
  }

  @override
  Widget build(BuildContext context) {
    if (!_editing) {
      return GestureDetector(
        onTap: _startEditing,
        child: Text(
          widget.profile.displayName,
          textAlign: TextAlign.center,
          style: frauncesStyle(fontSize: 18),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 180,
          child: TextField(
            controller: _controller,
            autofocus: true,
            textAlign: TextAlign.center,
            style: frauncesStyle(fontSize: 18),
            decoration: const InputDecoration(
              isDense: true,
              border: UnderlineInputBorder(),
            ),
            onSubmitted: (_) => _save(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check, size: 18),
          color: AppColors.willow,
          onPressed: _save,
        ),
      ],
    );
  }
}

/// A fresh profile (or one that's simply never had any real playback
/// yet) has no listening history to rank -- shown honestly instead of
/// an empty glassmorphic card and a "Top 5 songs" label sitting over
/// nothing.
class _EmptyTopSongs extends StatelessWidget {
  const _EmptyTopSongs();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'Nothing played yet',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: AppColors.mist),
      ),
    );
  }
}

class _TopSongs extends ConsumerWidget {
  final List<Track> tracks;

  const _TopSongs({required this.tracks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mostHeard = tracks.first;
    return Column(
      children: [
        _GlassCard(
          title: mostHeard.title,
          subtitle: mostHeard.artist,
          onTap: () => ref
              .read(playbackControllerProvider.notifier)
              .play(mostHeard, queue: tracks),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 6, 0, 10),
          child: Text(
            'Top 5 songs',
            style: TextStyle(fontSize: 12, color: AppColors.mist),
          ),
        ),
        for (final (index, track) in tracks.indexed)
          TrackRow(
            title: track.title,
            subtitle: track.artist,
            onTap: () => ref
                .read(playbackControllerProvider.notifier)
                .play(track, queue: tracks, queueIndex: index),
          ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GlassCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bruise.withValues(alpha: 0.08),
          border: Border.all(color: AppColors.bruise.withValues(alpha: 0.28)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most heard this week',
              style: TextStyle(fontSize: 10, color: AppColors.bruise),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CoverArt(size: 48, label: title),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.pale,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.paleDim,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
