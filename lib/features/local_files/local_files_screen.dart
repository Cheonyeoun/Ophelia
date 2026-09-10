import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../app/layout_metrics.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/screen_top_bar.dart';
import '../../app/widgets/track_row.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../playback_ui/playback_controller.dart';

/// A linked folder's `path` (from [LocalFileSourcePort.getLinkedFolders])
/// split into what [_LinkedFolderSection] actually shows for it: a short,
/// legible [primary] label plus an optional dimmer [secondary] line for
/// the rest -- the raw absolute path Android/desktop returns (e.g.
/// `/storage/emulated/0/Recordings/Record`) is exactly the kind of thing
/// that reads as noise crammed into one line, when the folder's own name
/// (`Record`) is what actually identifies it at a glance. On iOS, where
/// [path] is instead the synthetic `ios-files:`-prefixed, newline-joined
/// set of individually-picked file paths (see `LocalFileSourceAdapter`'s
/// doc comment), [primary] is a file count and there is no [secondary].
({String primary, String? secondary}) _folderLabelFor(String path) {
  const iosPrefix = 'ios-files:';
  if (path.startsWith(iosPrefix)) {
    final count = path
        .substring(iosPrefix.length)
        .split('\n')
        .where((p) => p.isNotEmpty)
        .length;
    return (primary: '$count file${count == 1 ? '' : 's'} selected', secondary: null);
  }
  final name = p.basename(path);
  final parent = p.dirname(path);
  // A basename of '' (path was itself '/' or similar) or a dirname with
  // nothing meaningful in it ('.', '/') isn't worth showing as a second
  // line -- fall back to the full path as the primary label instead.
  if (name.isEmpty) return (primary: path, secondary: null);
  final showParent = parent != '.' && parent != p.separator;
  return (primary: name, secondary: showParent ? parent : null);
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
            switch (result) {
              // A `null` value means the user cancelled the picker, not a
              // failure -- see LinkFolder's own doc comment.
              case Success(value: final path?):
                ref.invalidate(linkedFoldersProvider);
                ref.invalidate(localFolderTracksProvider(path));
              case Success(value: null):
                break;
              case ResultFailure(failure: final f):
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(f.message)),
                  );
                }
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
    final label = _folderLabelFor(path);
    final trackCount = tracks.maybeWhen(
      data: (data) => data.length,
      orElse: () => null,
    );

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            label.primary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.pale,
                            ),
                          ),
                        ),
                        if (trackCount != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '· $trackCount track${trackCount == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mist,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (label.secondary != null)
                      Text(
                        label.secondary!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mist,
                        ),
                      ),
                  ],
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
          error: (error, stack) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              error is Failure ? error.message : "Couldn't read this folder",
              style: const TextStyle(fontSize: 12, color: AppColors.mist),
            ),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}
