import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';

/// The top bar used by pushed, full-screen routes (Search, Downloads,
/// Profile, Everyday Play) — a back chevron, a Fraunces title, and an
/// optional trailing action, matching `.top-bar` in docs/design/.
class ScreenTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? trailing;
  final VoidCallback? onBack;

  const ScreenTopBar({this.title, this.trailing, this.onBack, super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.pale,
            onPressed: onBack ?? () => context.pop(),
          ),
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: frauncesStyle(fontSize: 16),
              ),
            )
          else
            const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
