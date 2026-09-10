import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the persistent mini-player is showing as the full bar or
/// collapsed to a small floating bubble (see
/// lib/app/widgets/persistent_player_overlay.dart), and — while
/// collapsed — the bubble's last snapped position, so it reappears where
/// the user left it rather than resetting on every rebuild.
class MiniPlayerVisibilityState {
  final bool hidden;
  final Offset? bubbleOffset;

  const MiniPlayerVisibilityState({required this.hidden, this.bubbleOffset});

  MiniPlayerVisibilityState copyWith({bool? hidden, Offset? bubbleOffset}) {
    return MiniPlayerVisibilityState(
      hidden: hidden ?? this.hidden,
      bubbleOffset: bubbleOffset ?? this.bubbleOffset,
    );
  }
}

/// Controls whether the mini-player is collapsed to a bubble — toggled by
/// the swipe-down "Hide player?" sheet (hide) and by tapping the bubble
/// (show). Deliberately holds [MiniPlayerVisibilityState.bubbleOffset]
/// too, rather than leaving it as private `State` on the overlay widget:
/// the overlay's own `State` already persists across navigation the same
/// way the mini-player itself always has (see
/// lib/app/widgets/persistent_player_overlay.dart's doc comment), but
/// routing it through here keeps that persistence out of a raw
/// `StatefulWidget` field and consistent with how the rest of this app's
/// cross-navigation UI state is managed (see e.g. `MiniPlayerHeight` in
/// lib/app/layout_metrics.dart).
class MiniPlayerVisibilityController extends Notifier<MiniPlayerVisibilityState> {
  @override
  MiniPlayerVisibilityState build() =>
      const MiniPlayerVisibilityState(hidden: false);

  void hide() => state = state.copyWith(hidden: true);

  void show() => state = state.copyWith(hidden: false);

  void setBubbleOffset(Offset offset) =>
      state = state.copyWith(bubbleOffset: offset);
}

final miniPlayerVisibilityProvider = NotifierProvider<
    MiniPlayerVisibilityController, MiniPlayerVisibilityState>(
  MiniPlayerVisibilityController.new,
);
