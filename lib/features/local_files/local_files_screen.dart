import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout_metrics.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/screen_top_bar.dart';
import '../../app/widgets/track_row.dart';
import '../../core/error/result.dart';
import '../playback_ui/playback_controller.dart';

/// A linked folder's `path` (from [LocalFileSourcePort.getLinkedFolders])
/// is what this screen shows for it -- fine on Android/desktop, where
/// it's a real filesystem path, but on iOS it's the synthetic
/// `ios-files:`-prefixed, newline-joined set of individually-picked file
/// paths (see `LocalFileSourceAdapter`'s doc comment) which would
/// otherwise render as that raw, multi-line identifier. This picks a
/// human-readable label instead: the file count for an iOS file set, the
/// path itself for anything else.
String _displayLabelFor(String path) {
  const iosPrefix = 'ios-files:';
  if (!path.startsWith(iosPrefix)) return path;
  final count =
      path.substring(iosPrefix.length).split('\n').where((p) => p.isNotEmpty).length;
  return '$count file${count == 1 ? '' : 's'} selected';
}

/// Local Files — pushed from Library, no nav bar, mini-player still
/// shown. Lets the user link a device folder (via `LinkFolder`) as a
/// music source and browse/play what's found in it (via
/// `ScanLocalFolder`) — see `LocalFileSourceAdapter`'s own doc comment
/// for this feature's real, platform-specific limitations (Android SAF
/// path persistence, iOS per-file picking, no web support).
class LocalFilesScreen extends ConsumerWidget {
  const LocalFilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(linkedFoldersProvider);
    final bottomInset = ref.watch(bottomContentInsetProvider);

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: ScreenTopBar(
        title: 'Local Files',
        trailing: IconButton(
          icon: const Icon(Icons.create_new_folder_outlined, size: 18),
          color: AppColors.pale,
          tooltip: 'Add folder',
          onPressed: () async {
            final result = await ref.read(linkFolderProvider)();
            // A `null` value means the user cancelled the picker, not a
            // failure -- see LinkFolder's own doc comment.
            if (result case Success(value: final path?)) {
              ref.invalidate(linkedFoldersProvider);
              ref.invalidate(localFolderTracksProvider(path));
            }
          },
        ),
      ),
      body: folders.when(
        data: (data) => data.isEmpty
            ? const Center(
                child: Text(
                  'No folders linked yet',
                  style: TextStyle(fontSize: 12, color: AppColors.mist),
                ),
              )
            : ListView(
                padding: EdgeInsets.only(bottom: bottomInset),
                children: [
                  for (final folder in data)
                    _LinkedFolderSection(path: folder),
                ],
              ),
        error: (error, stack) => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _LinkedFolderSection extends ConsumerWidget {
  final String path;

  const _LinkedFolderSection({required this.path});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(localFolderTracksProvider(path));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
          child: Row(
            children: [
              const Icon(
                Icons.folder_outlined,
                size: 14,
                color: AppColors.paleDim,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _displayLabelFor(path),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.paleDim,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                color: AppColors.mist,
                tooltip: 'Remove folder',
                onPressed: () async {
                  await ref.read(unlinkFolderProvider)(path);
                  ref.invalidate(linkedFoldersProvider);
                  // The section for this path disappears once the list
                  // above refreshes, but its cached track list would
                  // otherwise linger in the container indefinitely --
                  // clear it so re-linking the same path later re-scans
                  // instead of serving a stale cached result.
                  ref.invalidate(localFolderTracksProvider(path));
                },
              ),
            ],
          ),
        ),
        tracks.when(
          data: (data) => data.isEmpty
              ? const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'No audio files found',
                    style: TextStyle(fontSize: 12, color: AppColors.mist),
                  ),
                )
              : Column(
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
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}
