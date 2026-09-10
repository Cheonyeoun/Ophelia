import 'package:flutter/material.dart';

import '../theme.dart';

/// Placeholder cover art — a rounded, `ink2`-tinted square, matching
/// `.cover-sm` / `.ed-cover` in docs/design/. Real cover art loading is a
/// future adapter concern; until then this is a deliberate placeholder,
/// not a blank box standing in for a missing image, but a quiet one —
/// docs/design/'s whole visual language is "Fraunces carries titles and
/// personality; Inter stays quiet for chrome and metadata", and a
/// placeholder is chrome, not personality:
///
/// - With a [label] (almost always a track's title), it shows that
///   title's first letter, small and dim rather than a bold dominant
///   glyph — enough to read as "no artwork for this one" rather than a
///   rendering bug, and to give every track a distinct enough look for
///   [MiniPlayerBar]'s cover-art cross-fade on skip to actually be
///   visible (cross-fading between two identical blank boxes would show
///   nothing), without becoming the loudest thing on the screen.
/// - Without one (e.g. a purely decorative slot with no associated
///   track), it falls back to the same small, dim note icon instead of
///   an empty box, for the same reason.
/// - [gradient] adds the soft willow-tinted glow docs/design/ gives the
///   large cover specifically (`.ed-cover`'s radial-gradient, the same
///   treatment `ImmersivePlayScreen`'s own background already uses) —
///   `false` (a flat `ink2` square, matching `.cover-sm`/`.mini-cover`)
///   is right for every smaller, denser context: track rows, the
///   mini-player, the bubble.
class CoverArt extends StatelessWidget {
  final double size;
  final double borderRadius;
  final String? label;
  final bool gradient;

  const CoverArt({
    required this.size,
    this.borderRadius = 8,
    this.label,
    this.gradient = false,
    super.key,
  });

  String? get _initial {
    final trimmed = label?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initial = _initial;
    final markColor = AppColors.paleDim.withValues(alpha: 0.5);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const ColoredBox(color: AppColors.ink2),
            if (gradient)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.4),
                    radius: 1.1,
                    colors: [
                      AppColors.willow.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            if (initial != null)
              Text(
                initial,
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w500,
                  color: markColor,
                ),
              )
            else
              Icon(
                Icons.music_note_rounded,
                size: size * 0.4,
                color: markColor,
              ),
          ],
        ),
      ),
    );
  }
}
