import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout_metrics.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/screen_top_bar.dart';
import '../../app/widgets/track_row.dart';
import '../playback_ui/playback_controller.dart';

/// Playlist detail — pushed from tapping a playlist card in Library or
/// Home, no nav bar, mini-player still shown. Same top-bar-plus-track-
/// list shape as Downloads/Profile/ArtistScreen — there's no dedicated
/// "Playlist" frame in docs/design/ to match instead.
///
/// Tapping a track plays it and starts the queue *from that point*: the
/// full, ordered playlist is passed as the queue with that track's own
/// position as `queueIndex`, so skipNext/skipPrevious carry on through
/// the rest of the playlist afterward — the same pattern every other
/// track list in the app already uses.
class PlaylistScreen extends ConsumerWidget {
  final String playlistId;

  const PlaylistScreen({required this.playlistId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(playlistProvider(playlistId));
    final tracks = ref.watch(playlistTracksProvider(playlistId));
    final bottomInset = ref.watch(bottomContentInsetProvider);

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: ScreenTopBar(
        title: playlist.maybeWhen(
          data: (p) => p?.name,
          orElse: () => null,
        ),
      ),
      body: tracks.when(
        data: (data) => data.isEmpty
            ? const Center(
                child: Text(
                  'No tracks in this playlist',
                  style: TextStyle(fontSize: 12, color: AppColors.mist),
                ),
              )
            : ListView(
                padding: EdgeInsets.only(bottom: bottomInset),
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
      ),
    );
  }
}
