import 'package:flutter/material.dart';

import '../theme.dart';

/// The three-tab root navigation bar (Home, Library, Settings) — matches
/// `.navbar` / `.nav-item` in docs/design/. Only shown for the three root
/// tabs (docs/architecture.md §6); rendered by [RootScaffold] in
/// lib/app/router.dart.
class BottomNavBar extends StatelessWidget {
  static const _icons = [
    Icons.home_outlined,
    Icons.grid_view_outlined,
    Icons.settings_outlined,
  ];

  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.void_,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < _icons.length; i++)
            _NavItem(
              icon: _icons[i],
              active: i == currentIndex,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: active ? AppColors.pale : AppColors.mist),
            const SizedBox(height: 5),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: active ? AppColors.willow : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
