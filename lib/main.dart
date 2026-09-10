import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/error/result.dart';
import 'features/playback_ui/playback_controller.dart';

void main() {
  runApp(const ProviderScope(child: OpheliaApp()));
}

class OpheliaApp extends ConsumerStatefulWidget {
  const OpheliaApp({super.key});

  @override
  ConsumerState<OpheliaApp> createState() => _OpheliaAppState();
}

/// Runs `RestoreLastSession` once on startup, and saves the current
/// session whenever the app is backgrounded -- not just on a clean
/// [PlaybackController.pause] -- so a session survives the app being
/// killed outright (swiped away, low-memory kill) between launches, not
/// only a tidy pause-then-quit.
class _OpheliaAppState extends ConsumerState<OpheliaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSession());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _restoreSession() async {
    final result = await ref.read(restoreLastSessionProvider)();
    if (result case Success(value: final snapshot?)) {
      ref.read(playbackControllerProvider.notifier).restoreSession(snapshot);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ref.read(playbackControllerProvider.notifier).persistSessionSnapshot();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Ophelia',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
