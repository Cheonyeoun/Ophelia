import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/playback_controller.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/cover_art.dart';
import '../../app/widgets/screen_top_bar.dart';
import '../../app/widgets/track_row.dart';

/// Profile — pushed from Settings, no nav bar, mini-player still shown.
/// Matches the "Profile" frame in docs/design/ophelia-ui-mockup.html:
/// bruise is used here (the glass-card highlight) and nowhere else,
/// exactly as the mockup's own note prescribes.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final topSongs = ref.watch(topSongsProvider);

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: const ScreenTopBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          const SizedBox(height: 8),
          const CircleAvatar(radius: 32, backgroundColor: AppColors.ink2),
          const SizedBox(height: 10),
          profile.maybeWhen(
            data: (data) => Column(
              children: [
                Text(
                  data?.displayName ?? '',
                  textAlign: TextAlign.center,
                  style: frauncesStyle(fontSize: 18),
                ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 18),
          topSongs.maybeWhen(
            data: (data) => data.isEmpty
                ? const SizedBox.shrink()
                : _GlassCard(
                    title: data.first.title,
                    subtitle: data.first.artist,
                    onTap: () => ref
                        .read(playbackControllerProvider.notifier)
                        .play(data.first, queue: data),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 6, 0, 10),
            child: Text('Top 5 songs', style: TextStyle(fontSize: 12, color: AppColors.mist)),
          ),
          topSongs.when(
            data: (data) => Column(
              children: [
                for (final track in data)
                  TrackRow(
                    title: track.title,
                    subtitle: track.artist,
                    onTap: () => ref
                        .read(playbackControllerProvider.notifier)
                        .play(track, queue: data),
                  ),
              ],
            ),
            error: (error, stack) => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GlassCard({required this.title, required this.subtitle, required this.onTap});

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
                const CoverArt(size: 48),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.pale)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.paleDim)),
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
