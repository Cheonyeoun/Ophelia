import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/track.dart';
import '../../features/playback_ui/mini_player_visibility_controller.dart';
import '../../features/playback_ui/playback_controller.dart';
import '../layout_metrics.dart';
import '../theme.dart';
import 'floating_player_bubble.dart';
import 'hide_player_sheet.dart';
import 'measure_size.dart';
import 'mini_player_bar.dart';

/// Distance/velocity a drag needs to clear before it counts as a deliberate
/// swipe rather than an accidental nudge — shared by every direction below.
const double _kSwipeDistanceThreshold = 44;
const double _kSwipeVelocityThreshold = 380;

/// The persistent mini-player, extended with gesture controls and a
/// collapsible floating-bubble state (see the top-level task this
/// implements). One instance is built by [AppShell] — same as
/// [MiniPlayerBar] always was — so its `State`, including the bubble's
/// drag animation controllers, survives navigation without remounting;
/// only [MiniPlayerVisibilityController] actually needs to be
/// provider-backed (see that class's doc comment), everything else here
/// is transient gesture/animation bookkeeping local to this one widget
/// instance.
class PersistentPlayerOverlay extends ConsumerStatefulWidget {
  final bool isRootTabRoute;

  const PersistentPlayerOverlay({required this.isRootTabRoute, super.key});

  @override
  ConsumerState<PersistentPlayerOverlay> createState() =>
      _PersistentPlayerOverlayState();
}

class _PersistentPlayerOverlayState extends ConsumerState<PersistentPlayerOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _barSnapController;
  Animation<Offset>? _barSnapAnimation;
  Offset _barDrag = Offset.zero;

  late final AnimationController _bubbleSnapController;
  Animation<Offset>? _bubbleSnapAnimation;
  Offset? _liveBubbleOffset;

  @override
  void initState() {
    super.initState();
    _barSnapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..addListener(() {
        final animation = _barSnapAnimation;
        if (animation == null) return;
        setState(() => _barDrag = animation.value);
      });
    _bubbleSnapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        final animation = _bubbleSnapAnimation;
        if (animation == null) return;
        setState(() => _liveBubbleOffset = animation.value);
      })
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed) return;
        final animation = _bubbleSnapAnimation;
        if (animation == null) return;
        ref
            .read(miniPlayerVisibilityProvider.notifier)
            .setBubbleOffset(animation.value);
        _liveBubbleOffset = null;
      });
  }

  @override
  void dispose() {
    _barSnapController.dispose();
    _bubbleSnapController.dispose();
    super.dispose();
  }

  double get _bottomOffset =>
      (widget.isRootTabRoute ? kNavBarHeight : 0) + kMiniPlayerGap;

  void _animateBarBackToRest() {
    _barSnapAnimation = Tween<Offset>(begin: _barDrag, end: Offset.zero)
        .animate(CurvedAnimation(parent: _barSnapController, curve: Curves.easeOut));
    _barSnapController.forward(from: 0);
  }

  /// Guards [_navigateToEverydayPlay] against pushing the route twice --
  /// a fast double-tap, or a tap arriving right on the heels of a
  /// swipe-up, can both register before the pushed page has visually
  /// covered the mini-player (a single frame is enough), and
  /// `context.push` has no such guard of its own. Cleared once the
  /// pushed route is actually popped, not on some fixed delay, so the
  /// exact same gesture works again the moment the user is back.
  bool _navigatingToEverydayPlay = false;

  void _navigateToEverydayPlay(BuildContext context, {double? velocity}) {
    if (_navigatingToEverydayPlay) return;
    _navigatingToEverydayPlay = true;
    _animateBarBackToRest();
    context.push<void>('/everyday-play', extra: velocity).whenComplete(() {
      _navigatingToEverydayPlay = false;
    });
  }

  Future<void> _handleVerticalDragEnd(
    BuildContext context,
    DragEndDetails details,
  ) async {
    final velocity = details.velocity.pixelsPerSecond.dy;
    final draggedUp = _barDrag.dy < -_kSwipeDistanceThreshold ||
        velocity < -_kSwipeVelocityThreshold;
    final draggedDown = _barDrag.dy > _kSwipeDistanceThreshold ||
        velocity > _kSwipeVelocityThreshold;

    if (draggedUp) {
      _navigateToEverydayPlay(context, velocity: velocity);
      return;
    }
    _animateBarBackToRest();
    if (draggedDown) {
      await showHidePlayerSheet(context, ref);
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final draggedLeft = _barDrag.dx < -_kSwipeDistanceThreshold ||
        velocity < -_kSwipeVelocityThreshold;
    final draggedRight = _barDrag.dx > _kSwipeDistanceThreshold ||
        velocity > _kSwipeVelocityThreshold;

    final controller = ref.read(playbackControllerProvider.notifier);
    if (draggedLeft) {
      controller.skipNext();
    } else if (draggedRight) {
      controller.skipPrevious();
    }
    _animateBarBackToRest();
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(
      playbackControllerProvider.select((s) => s.playback.currentTrack),
    );
    final visibility = ref.watch(miniPlayerVisibilityProvider);

    if (track == null) {
      // Nothing loaded -- report zero height so scrollable screens don't
      // reserve space for a player that isn't showing (see
      // bottomContentInsetProvider), matching docs/architecture.md §6.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(miniPlayerHeightProvider.notifier).report(0);
      });
      return const SizedBox.shrink();
    }

    // The inner Stack (not AppShell's outer one) is required, not just
    // convenient: a `Positioned` (from `_buildBar`/`_buildBubble`) can
    // only be a *direct* child of a `Stack` -- returning it straight out
    // of `LayoutBuilder`'s builder, with only AppShell's `Positioned.fill`
    // above it, trips Flutter's "Incorrect use of ParentDataWidget" check,
    // since `LayoutBuilder` itself introduces a render object between
    // them.
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            visibility.hidden
                ? _buildBubble(context, constraints, track, visibility)
                : _buildBar(context, track),
          ],
        );
      },
    );
  }

  Widget _buildBar(BuildContext context, Track track) {
    final isPlaying = ref.watch(
      playbackControllerProvider.select((s) => s.isPlaying),
    );

    return Positioned(
      left: 12,
      right: 12,
      bottom: _bottomOffset,
      child: Transform.translate(
        offset: Offset(_barDrag.dx, _barDrag.dy.clamp(-80.0, 80.0)),
        child: GestureDetector(
          onVerticalDragUpdate: (d) =>
              setState(() => _barDrag += Offset(0, d.delta.dy)),
          onVerticalDragEnd: (d) => _handleVerticalDragEnd(context, d),
          onHorizontalDragUpdate: (d) =>
              setState(() => _barDrag += Offset(d.delta.dx, 0)),
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          child: MeasureSize(
            onChange: (size) =>
                ref.read(miniPlayerHeightProvider.notifier).report(size.height),
            child: MiniPlayerBar(
              track: track,
              isPlaying: isPlaying,
              onTap: () => _navigateToEverydayPlay(context),
              onPlayPause: () => ref
                  .read(playbackControllerProvider.notifier)
                  .togglePlayPause(),
            ),
          ),
        ),
      ),
    );
  }

  Rect _bubbleBounds(BoxConstraints constraints) {
    final media = MediaQuery.of(context);
    final minX = kBubbleMargin;
    final minY = media.padding.top + kBubbleMargin;
    final maxX = constraints.maxWidth - kBubbleSize - kBubbleMargin;
    final maxY = constraints.maxHeight -
        kBubbleSize -
        kBubbleMargin -
        _bottomOffset -
        media.padding.bottom;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Offset _clampToBounds(Offset offset, Rect bounds) {
    return Offset(
      offset.dx.clamp(bounds.left, bounds.right),
      offset.dy.clamp(bounds.top, bounds.bottom),
    );
  }

  Widget _buildBubble(
    BuildContext context,
    BoxConstraints constraints,
    Track track,
    MiniPlayerVisibilityState visibility,
  ) {
    final bounds = _bubbleBounds(constraints);
    final current = _liveBubbleOffset ??
        visibility.bubbleOffset ??
        Offset(bounds.right, bounds.bottom);
    final clamped = _clampToBounds(current, bounds);

    return Positioned(
      left: clamped.dx,
      top: clamped.dy,
      child: FloatingPlayerBubble(
        track: track,
        onTap: () =>
            ref.read(miniPlayerVisibilityProvider.notifier).show(),
        onPanStart: (_) {
          _bubbleSnapController.stop();
          setState(() => _liveBubbleOffset = clamped);
        },
        // Reads `_liveBubbleOffset` itself as the drag's running base, not
        // the `clamped` local captured when *this* build ran: `setState`
        // schedules a rebuild for the next frame rather than running one
        // synchronously, so a burst of pointer-move events delivered
        // before that rebuild flushes (routine for a fast real flick, and
        // near-guaranteed for `adb shell input swipe`, which was how this
        // was actually caught) all close over the same stale `clamped` --
        // each update would overwrite the last instead of accumulating,
        // so the bubble barely moved no matter how far the finger
        // travelled.
        onPanUpdate: (details) => setState(() {
          final base = _liveBubbleOffset ?? clamped;
          _liveBubbleOffset = _clampToBounds(base + details.delta, bounds);
        }),
        onPanEnd: (details) {
          final current = _liveBubbleOffset ?? clamped;
          final startX = current.dx + kBubbleSize / 2;
          final snapToRight = startX > constraints.maxWidth / 2;
          final target = Offset(
            snapToRight ? bounds.right : bounds.left,
            current.dy,
          );
          _bubbleSnapAnimation = Tween<Offset>(begin: current, end: target)
              .animate(CurvedAnimation(
            parent: _bubbleSnapController,
            curve: Curves.easeOutCubic,
          ));
          _bubbleSnapController.forward(from: 0);
        },
      ),
    );
  }
}
