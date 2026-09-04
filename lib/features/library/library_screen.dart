import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout_metrics.dart';
import '../../app/playback_controller.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/segmented_tabs.dart';
import '../../app/widgets/track_row.dart';
import '../../core/domain/playlist.dart';

/// The Library root tab — matches the "Library" frame in
/// docs/design/ophelia-ui-mockup-2.html.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  static const _tabs = ['Playlists', 'Artists', 'Albums', 'Songs'];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Library', style: frauncesStyle(fontSize: 16)),
                ),
                IconButton(
                  icon: const Icon(Icons.download_outlined, size: 18),
                  color: AppColors.paleDim,
                  tooltip: 'Downloads',
                  onPressed: () => context.push('/downloads'),
                ),
              ],
            ),
          ),
          SegmentedTabs(
            labels: _tabs,
            selectedIndex: _selected,
            onChanged: (i) => setState(() => _selected = i),
          ),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (_selected) {
      0 => _PlaylistsGrid(),
      1 => const _TrackDerivedList(field: _TrackField.artist),
      2 => const _TrackDerivedList(field: _TrackField.album),
      _ => const _SongsList(),
    };
  }
}

class _PlaylistsGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final bottomInset = ref.watch(bottomContentInsetProvider);
    return playlists.when(
      data: (data) => GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.4,
        children: [
          for (final playlist in data) _PlaylistCard(playlist: playlist),
        ],
      ),
      error: (error, stack) => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _PlaylistCard extends ConsumerWidget {
  final Playlist playlist;

  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () =>
          ref.read(playbackControllerProvider.notifier).playPlaylist(playlist),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.ink2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              playlist.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.pale,
              ),
            ),
            Text(
              '${playlist.trackIds.length} tracks',
              style: const TextStyle(fontSize: 10, color: AppColors.mist),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TrackField { artist, album }

class _TrackDerivedList extends ConsumerWidget {
  final _TrackField field;

  const _TrackDerivedList({required this.field});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(allTracksProvider);
    final bottomInset = ref.watch(bottomContentInsetProvider);
    return tracks.when(
      data: (data) {
        final values = <String>{};
        for (final track in data) {
          values.add(field == _TrackField.artist ? track.artist : track.album);
        }
        final sorted = values.toList()..sort();
        return ListView(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8 + bottomInset),
          children: [
            for (final value in sorted)
              TrackRow(
                title: value,
                subtitle: field == _TrackField.artist ? 'artist' : 'album',
              ),
          ],
        );
      },
      error: (error, stack) => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _SongsList extends ConsumerWidget {
  const _SongsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(allTracksProvider);
    final bottomInset = ref.watch(bottomContentInsetProvider);
    return tracks.when(
      data: (data) => ListView(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8 + bottomInset),
        children: [
          for (final (index, track) in data.indexed)
            TrackRow(
              title: track.title,
              subtitle: track.artist,
              onTap: () => ref
                  .read(playbackControllerProvider.notifier)
                  .play(track, queue: data, queueIndex: index),
            ),
        ],
      ),
      error: (error, stack) => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
