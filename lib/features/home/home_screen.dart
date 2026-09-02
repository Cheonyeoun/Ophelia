import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout_metrics.dart';
import '../../app/playback_controller.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/track_row.dart';

/// The Home root tab — matches the "Home" frame in
/// docs/design/ophelia-ui-mockup.html.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final tracks = ref.watch(allTracksProvider);
    final downloaded = ref.watch(downloadedTracksProvider);
    final bottomInset = ref.watch(bottomContentInsetProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.only(bottom: 24 + bottomInset),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.push('/search'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, size: 16, color: AppColors.mist),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search songs, artists',
                            style: TextStyle(fontSize: 13, color: AppColors.mist),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text('Good evening', style: frauncesStyle(fontSize: 20)),
                const SizedBox(height: 4),
                const Text(
                  'Where your library left off',
                  style: TextStyle(fontSize: 12, color: AppColors.mist),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ...playlists.maybeWhen(
                  data: (data) => data
                      .map((p) => _LibCard(title: p.name, subtitle: '${p.trackIds.length} tracks'))
                      .toList(),
                  orElse: () => const <Widget>[],
                ),
                downloaded.maybeWhen(
                  data: (data) => _LibCard(
                    title: 'Downloaded',
                    subtitle: '${data.length} tracks',
                    onTap: () => context.push('/downloads'),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SectionLabel('Recently played'),
          tracks.when(
            data: (data) => Column(
              children: [
                for (final track in data.take(5))
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
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _LibCard({required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.ink2,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.pale),
              ),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.mist)),
            ],
          ),
        ),
      ),
    );
  }
}
