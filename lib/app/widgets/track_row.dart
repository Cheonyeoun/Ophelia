import 'package:flutter/material.dart';

import '../theme.dart';
import 'cover_art.dart';

/// A single track/artist/album result row — matches `.track-row` /
/// `.track-meta` in docs/design/.
///
/// [subtitle] is optional: omitting it (rather than passing a repeated
/// placeholder like "Unknown artist" on every row) collapses this to a
/// lighter single-line row, for a list of entries that genuinely have no
/// second line of metadata worth showing — see `LocalFilesScreen`.
class TrackRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TrackRow({
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        child: Row(
          children: [
            CoverArt(size: 44, label: title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.pale,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mist,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
