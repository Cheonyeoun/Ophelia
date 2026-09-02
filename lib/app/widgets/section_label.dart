import 'package:flutter/material.dart';

import '../theme.dart';

/// A small mist-colored section heading — matches `.section-title` /
/// `.set-section-label` / `.top5-title` in docs/design/.
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsets padding;

  const SectionLabel(
    this.text, {
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 10),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.mist),
      ),
    );
  }
}
