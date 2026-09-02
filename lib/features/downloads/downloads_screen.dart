import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/playback_controller.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/screen_top_bar.dart';
import '../../app/widgets/track_row.dart';
import '../../core/domain/track.dart';

/// Downloads — pushed from Library/Settings, no nav bar, mini-player
/// still shown. Matches the "Downloads" frame in
/// docs/design/ophelia-ui-mockup-2.html.
///
/// `DownloadPort` only exposes a per-track `isDownloaded` check, not a
/// listing with size/date, so this shows title/artist without the
/// mockup's "8.4 MB" byte counts or the storage-used summary — both
/// would need a port method that doesn't exist yet.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloaded = ref.watch(downloadedTracksProvider);

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: const ScreenTopBar(title: 'Downloads'),
      body: downloaded.when(
        data: (tracks) => tracks.isEmpty
            ? const Center(
                child: Text(
                  'No downloads yet',
                  style: TextStyle(fontSize: 12, color: AppColors.mist),
                ),
              )
            : ListView(
                children: [
                  for (final track in tracks) _DownloadRow(track: track, queue: tracks),
                ],
              ),
        error: (error, stack) => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _DownloadRow extends ConsumerWidget {
  final Track track;
  final List<Track> queue;

  const _DownloadRow({required this.track, required this.queue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackRow(
      title: track.title,
      subtitle: track.artist,
      onTap: () =>
          ref.read(playbackControllerProvider.notifier).play(track, queue: queue),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        color: AppColors.mist,
        tooltip: 'Remove download',
        onPressed: () => ref.read(removeDownloadProvider)(track.id),
      ),
    );
  }
}
