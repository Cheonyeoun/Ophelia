import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/playback_ui/mini_player_visibility_controller.dart';
import '../theme.dart';

/// Swipe-down confirmation for the mini-player — a themed sheet (Void/
/// Ink/Willow/Mist/Pale, Fraunces/Inter), not a system [AlertDialog], so
/// it matches the rest of the app rather than breaking the visual
/// language for one interaction. Swiping down only ever opens this; only
/// tapping "Hide" here actually collapses the mini-player to its bubble
/// (see [MiniPlayerVisibilityController.hide]) — there is no dismiss-on
/// swipe-alone path.
Future<void> showHidePlayerSheet(BuildContext context, WidgetRef ref) async {
  final hide = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const _HidePlayerSheet(),
  );
  if (hide == true) {
    ref.read(miniPlayerVisibilityProvider.notifier).hide();
  }
}

class _HidePlayerSheet extends StatelessWidget {
  const _HidePlayerSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Hide player?', style: frauncesStyle(fontSize: 18)),
              const SizedBox(height: 6),
              const Text(
                'It stays out of the way as a small bubble — tap it any '
                'time to bring the player back.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.mist),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.paleDim),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Hide',
                        style: TextStyle(
                          color: AppColors.willow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
