import 'package:flutter/material.dart';

import '../../core/error/failure.dart';
import '../theme.dart';

/// A centered message plus a retry button, for an `AsyncValue.error`
/// branch — so a real failure (network, storage, not-found) gets a
/// visible, actionable state instead of silently rendering as if there
/// were just no data (see app/providers.dart's playlist/artist
/// providers).
class ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ErrorState({required this.error, required this.onRetry, super.key});

  String get _message =>
      error is Failure ? (error as Failure).message : 'Something went wrong';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.mist),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(fontSize: 12, color: AppColors.willow),
            ),
          ),
        ],
      ),
    );
  }
}
