import 'package:flutter/material.dart';

import '../../core/domain/track.dart';
import '../theme.dart';
import 'cover_art.dart';

/// The persistent mini-player — matches `.mini-player` in docs/design/.
/// Shown on every screen except Everyday/Immersive Play, hidden entirely
/// when nothing is loaded (see docs/architecture.md §6). Rendered once by
/// the navigation shell (lib/app/router.dart) so it survives navigation
/// without remounting.
class MiniPlayerBar extends StatelessWidget {
  final Track track;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;

  const MiniPlayerBar({
    required this.track,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayPause,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: kMiniPlayerHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // Keyed by track id so a skip (swipe-left/right on the
              // wrapping gesture detector, or any other track change)
              // cross-fades the cover art instead of snapping it —
              // the visual cue that registers the change actually
              // happened, per docs/architecture.md's mini-player gesture
              // spec.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: CoverArt(
                  key: ValueKey(track.id),
                  size: 32,
                  borderRadius: 6,
                  label: track.title,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  track.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.pale,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                color: AppColors.pale,
                onPressed: onPlayPause,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
