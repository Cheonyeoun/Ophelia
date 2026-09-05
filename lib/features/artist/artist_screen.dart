import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout_metrics.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/error_state.dart';
import '../../app/widgets/screen_top_bar.dart';
import '../../app/widgets/track_row.dart';
import '../playback_ui/playback_controller.dart';

/// Artist detail — pushed from tapping an artist (currently: the Library
/// Artists tab), no nav bar, mini-player still shown. There's no
/// dedicated "Artist" frame in docs/design/, so this follows the same
/// top-bar-plus-track-list shape as Downloads/Profile — the closest
/// existing pattern for "a title and a list of tracks."
///
/// Routed by artist *name* (see app/router.dart's `/artist/:name`), not
/// an id — `Track.artist` is a plain string with no separate `Artist.id`
/// reference anywhere yet (see core/domain/artist.dart), so name is the
/// only identifier the catalog actually has to group by.
class ArtistScreen extends ConsumerWidget {
  final String artistName;

  const ArtistScreen({required this.artistName, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(artistTracksProvider(artistName));
    final bottomInset = ref.watch(bottomContentInsetProvider);

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: ScreenTopBar(title: artistName),
      body: tracks.when(
        data: (data) => data.isEmpty
            ? const Center(
                child: Text(
                  'No tracks from this artist',
                  style: TextStyle(fontSize: 12, color: AppColors.mist),
                ),
              )
            : ListView(
                padding: EdgeInsets.only(bottom: bottomInset),
                children: [
                  for (final (index, track) in data.indexed)
                    TrackRow(
                      title: track.title,
                      subtitle: track.album,
                      onTap: () => ref
                          .read(playbackControllerProvider.notifier)
                          .play(track, queue: data, queueIndex: index),
                    ),
                ],
              ),
        error: (error, stack) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(artistTracksProvider(artistName)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
