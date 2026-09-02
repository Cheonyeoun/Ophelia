/// A 0..1 factor for compressing fixed sizes/spacing as a screen gets
/// shorter, instead of letting them overflow. `1.0` once [availableHeight]
/// reaches [comfortableHeight] or more; shrinks linearly down to
/// [minScale] by the time it reaches [tightHeight].
///
/// Used by the two player screens (lib/features/playback_ui/) — the only
/// screens laid out as a single fixed-size column rather than something
/// scrollable, so they're the ones that can't just grow a scrollbar on a
/// short device.
double compactScale({
  required double availableHeight,
  double comfortableHeight = 700,
  double tightHeight = 560,
  double minScale = 0.7,
}) {
  if (availableHeight >= comfortableHeight) return 1.0;
  if (availableHeight <= tightHeight) return minScale;
  final t =
      (availableHeight - tightHeight) / (comfortableHeight - tightHeight);
  return minScale + (1.0 - minScale) * t;
}
