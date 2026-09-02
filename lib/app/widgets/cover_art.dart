import 'package:flutter/material.dart';

import '../theme.dart';

/// Placeholder cover art — a rounded, `ink2`-tinted square, matching
/// `.cover-sm` / `.ed-cover` in docs/design/. Real cover art loading is a
/// future adapter concern.
class CoverArt extends StatelessWidget {
  final double size;
  final double borderRadius;

  const CoverArt({required this.size, this.borderRadius = 8, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.ink2,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
