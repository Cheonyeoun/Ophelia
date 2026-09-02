import '../domain/playback_state.dart';

/// Flips between the Everyday and Immersive play screens (see
/// docs/architecture.md §6). A pure state transformation — no port is
/// involved since which screen is showing isn't persisted anywhere.
class ToggleImmersive {
  const ToggleImmersive();

  PlaybackState call(PlaybackState state) =>
      state.copyWith(isImmersive: !state.isImmersive);
}
