import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color tokens from docs/design/ (both mockup files share these).
/// Willow drives everyday UI state; bruise is reserved for the single
/// profile highlight moment — never used elsewhere.
abstract final class AppColors {
  static const void_ = Color(0xFF0A0A0E);
  static const ink = Color(0xFF16161C);
  static const ink2 = Color(0xFF1D1D24);
  static const willow = Color(0xFF7E9B89);
  static const bruise = Color(0xFF9483A0);
  static const mist = Color(0xFF6E6E78);
  static const pale = Color(0xFFEDEDEF);
  static const paleDim = Color(0xFFB9B9C0);
  static const hairline = Color(0xFF1B1B21);
  static const flowTrack = Color(0xFF2C2C32);
}

/// Shared layout constants so the navigation shell (bottom nav bar height)
/// and the mini-player overlay that floats above it agree on the same
/// number — see lib/app/router.dart.
const double kNavBarHeight = 72;

/// A seed default only — used for one frame before the mini-player's
/// real height is measured (see [MeasureSize] in lib/app/router.dart),
/// and as its fallback while nothing is being measured at all.
const double kMiniPlayerHeight = 56;

/// The gap between the floating mini-player and whatever's below it
/// (the nav bar, or the screen edge). Unlike [kMiniPlayerHeight], this
/// doesn't depend on content/font metrics, so it doesn't need measuring.
const double kMiniPlayerGap = 8;

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final fraunces = GoogleFonts.frauncesTextTheme(base.textTheme);
  final inter = GoogleFonts.interTextTheme(base.textTheme);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.void_,
    colorScheme: base.colorScheme.copyWith(
      surface: AppColors.void_,
      primary: AppColors.willow,
      secondary: AppColors.bruise,
    ),
    textTheme: inter.copyWith(
      headlineSmall: fraunces.headlineSmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.pale,
      ),
      titleLarge: fraunces.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.pale,
      ),
      titleMedium: fraunces.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.pale,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(color: AppColors.pale),
      bodySmall: inter.bodySmall?.copyWith(color: AppColors.mist),
    ),
    iconTheme: const IconThemeData(color: AppColors.paleDim),
  );
}

/// The Fraunces display face, used for titles/greetings/track names —
/// Inter (the theme's default body font) stays quiet for chrome and
/// metadata, per docs/design/'s "visual language" note.
TextStyle frauncesStyle({
  required double fontSize,
  FontWeight fontWeight = FontWeight.w500,
  Color color = AppColors.pale,
}) {
  return GoogleFonts.fraunces(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: -0.2,
  );
}
