import 'package:flutter/material.dart';

import '../../core/domain/track.dart';
import '../theme.dart';
import 'cover_art.dart';

/// The collapsed mini-player: a small, draggable circular bubble showing
/// cover art (a chat-head pattern) — shown instead of [MiniPlayerBar] once
/// the user hides it via [showHidePlayerSheet]. Purely presentational and
/// input-only: dragging/snapping is driven by the parent
/// (PersistentPlayerOverlay), which owns the animation and clamps this
/// widget's position to the visible screen bounds — this widget only
/// reports raw drag deltas and a release, and renders wherever it's told.
class FloatingPlayerBubble extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  const FloatingPlayerBubble({
    required this.track,
    required this.onTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: Container(
        width: kBubbleSize,
        height: kBubbleSize,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.ink,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: CoverArt(
            size: kBubbleSize - 8,
            borderRadius: 0,
            label: track.title,
          ),
        ),
      ),
    );
  }
}
