import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout_metrics.dart';
import '../../app/playback_controller.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/screen_top_bar.dart';
import '../../app/widgets/segmented_tabs.dart';
import '../../app/widgets/track_row.dart';
import '../../core/domain/track.dart';
import '../../core/error/result.dart';

/// Search — pushed from Home, no nav bar, mini-player still shown.
/// Matches the "Search" frame in docs/design/ophelia-ui-mockup-2.html.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _filters = ['All', 'Songs', 'Artists', 'Albums'];

  final _controller = TextEditingController();
  int _filterIndex = 0;
  List<Track> _results = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onQueryChanged(String query) async {
    final result = await ref.read(searchCatalogProvider)(query);
    if (!mounted) return;
    setState(() {
      _results = switch (result) {
        Success(value: final tracks) => tracks,
        ResultFailure() => const [],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = ref.watch(bottomContentInsetProvider);

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: const ScreenTopBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 14, color: AppColors.paleDim),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: _onQueryChanged,
                      style: const TextStyle(fontSize: 13, color: AppColors.pale),
                      decoration: const InputDecoration(
                        hintText: 'Search songs, artists, albums',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.paleDim),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SegmentedTabs(
            labels: _filters,
            selectedIndex: _filterIndex,
            onChanged: (i) => setState(() => _filterIndex = i),
          ),
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Text(
                      'Search for songs, artists, or albums',
                      style: TextStyle(fontSize: 12, color: AppColors.mist),
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    children: [
                      for (final (index, track) in _results.indexed)
                        TrackRow(
                          title: track.title,
                          subtitle: '${track.artist} · song',
                          onTap: () => ref
                              .read(playbackControllerProvider.notifier)
                              .play(track, queue: _results, queueIndex: index),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
