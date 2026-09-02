import 'package:flutter/material.dart';

import '../theme.dart';

/// A row of pill-shaped filter chips, one active — matches `.segmented` /
/// `.seg-chip` / `.filter-row` in docs/design/.
class SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Wrap(
        spacing: 6,
        children: [
          for (var i = 0; i < labels.length; i++)
            _Chip(
              label: labels[i],
              active: i == selectedIndex,
              onTap: () => onChanged(i),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.ink2 : AppColors.ink,
          borderRadius: BorderRadius.circular(20),
          border: active ? Border.all(color: AppColors.willow) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? AppColors.pale : AppColors.mist,
          ),
        ),
      ),
    );
  }
}
