import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../app/layout_metrics.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/screen_top_bar.dart';
import '../../app/widgets/track_row.dart';
import '../../core/domain/track.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../playback_ui/playback_controller.dart';

/// A linked folder's `path` (from [LocalFileSourcePort.getLinkedFolders])
/// split into what [_FolderHeader] actually shows for it: a short,
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
    return (
      primary: '$count file${count == 1 ? '' : 's'} selected',
      secondary: null,
    );
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
///
/// Built for real scale (a linked folder can hold thousands of files),
/// not just the handful used in tests/demos:
/// - Every track list here is a lazy `SliverList.builder`, not a plain
///   eagerly-built `Column` — only what's actually on screen (plus a
///   small cache margin) is ever built at once.
/// - `localFolderTracksProvider` (a plain, non-`autoDispose` provider
///   family) already caches each folder's scan by path — reopening this
///   screen, or any unrelated rebuild, reuses that cached result instead
///   of re-scanning; only linking/unlinking a folder, or the manual
///   pull-to-refresh below, ever invalidates it.
/// - The actual filesystem walk behind that scan runs off the UI thread
///   (see `LocalFileSourceAdapter.scanFolder`'s own doc comment on
///   `compute`), so opening a large folder can't visibly freeze the app.
/// - Filtering (the search field below) only ever narrows an
///   already-cached scan result client-side — it triggers no I/O and no
///   provider invalidation at all.
class LocalFilesScreen extends ConsumerStatefulWidget {
  const LocalFilesScreen({super.key});

  @override
  ConsumerState<LocalFilesScreen> createState() => _LocalFilesScreenState();
}

class _LocalFilesScreenState extends ConsumerState<LocalFilesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(linkedFoldersProvider);
    final folders = await ref.read(linkedFoldersProvider.future);
    for (final folder in folders) {
      ref.invalidate(localFolderTracksProvider(folder));
    }
    // Waited on too, not just kicked off -- otherwise the refresh
    // spinner would disappear the instant the (near-instant) folder-list
    // re-read finishes, well before the actual re-scans it just
    // triggered have done any real work.
    await Future.wait([
      for (final folder in folders)
        ref.read(localFolderTracksProvider(folder).future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
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
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(f.message)));
                }
            }
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: folders.when(
          data: (data) => data.isEmpty
              ? const _MessageScrollView(message: 'No folders linked yet')
              : _FolderList(
                  folders: data,
                  query: _query,
                  searchController: _searchController,
                  onQueryChanged: (value) => setState(() => _query = value),
                  bottomInset: bottomInset,
                ),
          error: (error, stack) =>
              const _MessageScrollView(message: "Couldn't load linked folders"),
          loading: () =>
              const _MessageScrollView(message: 'Loading…', showSpinner: true),
        ),
      ),
    );
  }
}

/// A single centered message, wrapped in a scroll view of its own --
/// [RefreshIndicator] needs a scrollable descendant to attach its
/// pull-down gesture to no matter which state this screen is in, not
/// just once real folder content exists.
class _MessageScrollView extends StatelessWidget {
  final String message;
  final bool showSpinner;

  const _MessageScrollView({required this.message, this.showSpinner = false});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showSpinner) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  message,
                  style: const TextStyle(fontSize: 12, color: AppColors.mist),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The linked-folders list proper: a search field pinned above every
/// folder's (lazily-built) track list. A single [CustomScrollView] with
/// one flat sliver sequence across *every* folder -- not one scrollable
/// per folder -- so scroll position, virtualization, and the pinned
/// search field all behave as one continuous list regardless of how many
/// folders are linked.
class _FolderList extends ConsumerWidget {
  final List<String> folders;
  final String query;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final double bottomInset;

  const _FolderList({
    required this.folders,
    required this.query,
    required this.searchController,
    required this.onQueryChanged,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedQuery = query.trim().toLowerCase();

    // Computed up front, across every folder, so a search that matches
    // nothing anywhere can say so once -- rather than every individual
    // folder section separately claiming "no matches" underneath a wall
    // of otherwise-empty headers.
    var anyFolderStillLoading = false;
    var anyMatchAnywhere = normalizedQuery.isEmpty;
    if (normalizedQuery.isNotEmpty) {
      for (final folder in folders) {
        final tracks = ref.watch(localFolderTracksProvider(folder));
        tracks.whenData((data) {
          if (data.any(
            (t) => t.title.toLowerCase().contains(normalizedQuery),
          )) {
            anyMatchAnywhere = true;
          }
        });
        if (tracks.isLoading) anyFolderStillLoading = true;
      }
    }

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SearchFieldHeader(
            controller: searchController,
            onChanged: onQueryChanged,
          ),
        ),
        for (final folder in folders)
          ..._folderSlivers(ref, folder, normalizedQuery),
        if (normalizedQuery.isNotEmpty &&
            !anyMatchAnywhere &&
            !anyFolderStillLoading)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No tracks match "$query"',
                  style: const TextStyle(fontSize: 12, color: AppColors.mist),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
      ],
    );
  }

  List<Widget> _folderSlivers(
    WidgetRef ref,
    String folder,
    String normalizedQuery,
  ) {
    final tracksAsync = ref.watch(localFolderTracksProvider(folder));
    final label = _folderLabelFor(folder);

    return [
      SliverToBoxAdapter(
        child: _FolderHeader(path: folder, label: label, tracks: tracksAsync),
      ),
      tracksAsync.when(
        data: (tracks) {
          final filtered = normalizedQuery.isEmpty
              ? tracks
              : tracks
                    .where(
                      (t) => t.title.toLowerCase().contains(normalizedQuery),
                    )
                    .toList();

          if (tracks.isEmpty) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'No audio files found',
                  style: TextStyle(fontSize: 12, color: AppColors.mist),
                ),
              ),
            );
          }
          // A folder with tracks but no matches for the current search
          // disappears entirely rather than printing its own "no
          // matches" line -- with several linked folders, that would
          // otherwise repeat once per folder for the exact same reason.
          // The one combined message above covers "nothing anywhere
          // matched" instead.
          if (filtered.isEmpty) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }

          return SliverList.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final track = filtered[index];
              return _FadeInRow(
                key: ValueKey(track.id),
                child: TrackRow(
                  title: track.title,
                  // A local file has no real tag reader (see
                  // LocalFileSourceAdapter's doc comment) -- every one of
                  // its tracks shares the exact same placeholder artist,
                  // so repeating it on every single row adds visual
                  // noise without adding information. Collapsing to a
                  // single-line row instead is the honest way to show
                  // "no metadata here" without pretending there's a real
                  // artist to report.
                  subtitle: track.artist == unknownArtistPlaceholder
                      ? null
                      : track.artist,
                  onTap: () => ref
                      .read(playbackControllerProvider.notifier)
                      .play(track, queue: filtered, queueIndex: index),
                ),
              );
            },
          );
        },
        error: (error, stack) => SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              error is Failure ? error.message : "Couldn't read this folder",
              style: const TextStyle(fontSize: 12, color: AppColors.mist),
            ),
          ),
        ),
        loading: () => const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Scanning folder…',
                    style: TextStyle(fontSize: 12, color: AppColors.mist),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class _FolderHeader extends ConsumerWidget {
  final String path;
  final ({String primary, String? secondary}) label;
  final AsyncValue<List<Track>> tracks;

  const _FolderHeader({
    required this.path,
    required this.label,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackCount = tracks.maybeWhen(
      data: (data) => data.length,
      orElse: () => null,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
      child: Row(
        children: [
          const Icon(Icons.folder_outlined, size: 14, color: AppColors.paleDim),
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
                    style: const TextStyle(fontSize: 11, color: AppColors.mist),
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
    );
  }
}

/// The search field, as a [SliverPersistentHeader] so it stays visible
/// (`pinned: true`) while scrolling through however many tracks are
/// below it -- scrolling to find one file by eye in a folder of
/// thousands is exactly the unusable scenario this exists to avoid.
class _SearchFieldHeader extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  _SearchFieldHeader({required this.controller, required this.onChanged});

  static const _height = 52.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.void_),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: AppColors.pale),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search this folder',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.mist),
            prefixIcon: const Icon(
              Icons.search,
              size: 18,
              color: AppColors.mist,
            ),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.mist,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
            filled: true,
            fillColor: AppColors.ink2,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchFieldHeader oldDelegate) => true;
}

/// A subtle, restrained one-shot entrance for a row as it's first built —
/// deliberately simple (a plain fade-and-slight-rise via
/// [TweenAnimationBuilder], no controller to manage or dispose) rather
/// than anything bouncy. Note this re-plays whenever `SliverList.builder`
/// recreates a row's `Element` after scrolling it far enough away to
/// dispose (an inherent tradeoff of true list virtualization at real
/// scale) -- still subtle enough not to read as attention-grabbing on
/// every re-entry, just consistently present as rows populate the list.
class _FadeInRow extends StatelessWidget {
  final Widget child;

  const _FadeInRow({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 6),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
