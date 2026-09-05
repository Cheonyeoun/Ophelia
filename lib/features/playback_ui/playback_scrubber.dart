import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// `mm:ss` formatting shared by the scrubber's live time label and
/// Everyday Play's static position/duration row.
String formatPlaybackDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Keys identifying the scrubber's parts (the line's opacity, the thumb,
/// the time label) so tests can find them from outside this library —
/// the widgets themselves are private.
const playbackScrubberLineKey = ValueKey('playbackScrubberLine');
const playbackScrubberThumbKey = ValueKey('playbackScrubberThumb');
const playbackScrubberTimeLabelKey = ValueKey('playbackScrubberTimeLabel');

/// An interactive playback progress scrubber, replacing the previously
/// static flow-line in Everyday and Immersive Play. Progressive
/// disclosure: touching near the (very thin) line reveals a small
/// willow thumb and a live time label above it; dragging moves the
/// thumb and updates the label, but [onSeek] only fires once, on
/// release, not on every drag frame, to avoid stuttery seeking. The
/// thumb fades back out [_PlaybackScrubberState._hideDelay] after the
/// last interaction; a new touch resets that timer.
///
/// The widget's own layout height genuinely *is* the 44px
/// accessibility-minimum touch target — Flutter never hit-tests outside
/// a parent's real layout bounds, no matter how far a descendant paints
/// beyond them via `Clip.none`, so the touch target can't be "faked" by
/// visually overflowing a smaller box. The ~2px visible line is centered
/// inside that full-height box via [Center] instead.
///
/// A single [GestureDetector] wraps the *entire* stack — line, thumb,
/// and label together — rather than sitting as a separate layer
/// underneath them: with the thumb/label as separate siblings on top,
/// grabbing the visible thumb to start a new drag would hit whichever
/// sibling paints topmost at that point instead of reliably reaching the
/// detector.
///
/// [lineAlwaysVisible] controls whether the line itself is always shown
/// (Everyday Play — only the thumb/label appear and disappear) or hidden
/// until first touched, fading out again together with the thumb
/// (Immersive Play, reinforcing its minimal philosophy — see
/// immersive_play_screen.dart).
class PlaybackScrubber extends StatefulWidget {
  final String trackId;
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final bool lineAlwaysVisible;

  const PlaybackScrubber({
    required this.trackId,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.lineAlwaysVisible = true,
    super.key,
  });

  @override
  State<PlaybackScrubber> createState() => _PlaybackScrubberState();
}

class _PlaybackScrubberState extends State<PlaybackScrubber> {
  static const _hideDelay = Duration(milliseconds: 2500);
  static const _fadeDuration = Duration(milliseconds: 150);
  static const _touchTargetHeight = 44.0;
  static const _thumbDiameter = 14.0;
  static const _labelGap = 4.0;
  static const _thumbTop = (_touchTargetHeight - _thumbDiameter) / 2;
  static const _labelBottomOffset = _touchTargetHeight - _thumbTop + _labelGap;

  /// The step [onIncrease]/[onDecrease] (the semantics slider actions)
  /// move by — the same increment the transport's own ±10s buttons use.
  static const _stepDuration = Duration(seconds: 10);

  Timer? _hideTimer;
  bool _revealed = false;

  /// The fraction the thumb is currently being dragged to, or `null`
  /// when not dragging (in which case the display falls back to the
  /// actual playback position) — kept separate from the real position so
  /// dragging never fires a seek itself; only [_commitSeek] (on release)
  /// does.
  double? _dragFraction;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlaybackScrubber oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The track (or, for the same track, its duration) changed while a
    // drag was in progress -- e.g. it was skipped from elsewhere while
    // this finger was still down. Compared by id, not just duration: two
    // different tracks can share the same duration, which would have let
    // a stale drag survive a track change undetected. The in-flight drag
    // fraction was computed against the old track and means nothing
    // against the new one, so drop it rather than committing a seek to a
    // nonsensical position on release. No setState needed --
    // didUpdateWidget already runs immediately before the rebuild that's
    // about to happen because the widget changed.
    if (_dragFraction != null &&
        (oldWidget.trackId != widget.trackId ||
            oldWidget.duration != widget.duration)) {
      _dragFraction = null;
    }
  }

  double get _actualFraction => widget.duration == Duration.zero
      ? 0.0
      : (widget.position.inMilliseconds / widget.duration.inMilliseconds)
          .clamp(0.0, 1.0);

  double get _displayFraction => _dragFraction ?? _actualFraction;

  Duration get _displayDuration => Duration(
        milliseconds:
            (widget.duration.inMilliseconds * _displayFraction).round(),
      );

  void _reveal() {
    _hideTimer?.cancel();
    if (!_revealed) setState(() => _revealed = true);
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDelay, () {
      if (mounted) setState(() => _revealed = false);
    });
  }

  void _updateDrag(double localX, double width) {
    if (width <= 0) return;
    setState(() => _dragFraction = (localX / width).clamp(0.0, 1.0));
  }

  void _commitSeek() {
    final target = _displayDuration;
    _dragFraction = null;
    widget.onSeek(target);
    _scheduleHide();
  }

  /// The tap or drag recognizer lost the gesture arena before ever
  /// starting -- e.g. an ancestor scrollable claims a mostly-vertical
  /// pointer movement instead, or the platform cancels the pointer
  /// outright. Once a drag has actually *started* (`onHorizontalDragStart`
  /// already fired), Flutter's gesture contract guarantees it ends via
  /// [_commitSeek] (`onHorizontalDragEnd`), never this callback -- so this
  /// only ever runs before any drag fraction was set. What it does need to
  /// clean up is `onTapDown`'s reveal: that fires eagerly, before the arena
  /// resolves, so a cancelled tap can leave the thumb shown with no
  /// interaction left to schedule its hide -- exactly failure mode (b) from
  /// the PR review. Scheduling the hide here (same as a normal release)
  /// covers that; clearing [_dragFraction] is just for symmetry/safety.
  void _cancelInteraction() {
    if (_dragFraction != null) {
      setState(() => _dragFraction = null);
    }
    _scheduleHide();
  }

  Duration _clampToDuration(Duration target) {
    if (target < Duration.zero) return Duration.zero;
    return target > widget.duration ? widget.duration : target;
  }

  void _step(Duration delta) {
    final clamped = _clampToDuration(_displayDuration + delta);
    _reveal();
    widget.onSeek(clamped);
    _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      slider: true,
      label: 'Playback position',
      value: formatPlaybackDuration(_displayDuration),
      increasedValue: formatPlaybackDuration(
        _clampToDuration(_displayDuration + _stepDuration),
      ),
      decreasedValue: formatPlaybackDuration(
        _clampToDuration(_displayDuration - _stepDuration),
      ),
      onIncrease: () => _step(_stepDuration),
      onDecrease: () => _step(-_stepDuration),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _reveal(),
        onTapUp: (_) => _commitSeek(),
        onTapCancel: _cancelInteraction,
        onHorizontalDragStart: (details) {
          _reveal();
          _updateDrag(details.localPosition.dx, context.size?.width ?? 0);
        },
        onHorizontalDragUpdate: (details) => _updateDrag(
          details.localPosition.dx,
          context.size?.width ?? 0,
        ),
        onHorizontalDragEnd: (_) => _commitSeek(),
        onHorizontalDragCancel: _cancelInteraction,
        child: SizedBox(
          height: _touchTargetHeight,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: AnimatedOpacity(
                      key: playbackScrubberLineKey,
                      opacity: widget.lineAlwaysVisible || _revealed ? 1 : 0,
                      duration: _fadeDuration,
                      child: _Track(fraction: _displayFraction),
                    ),
                  ),
                  if (_revealed) ...[
                    Positioned(
                      left: width * _displayFraction,
                      top: _thumbTop,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, 0),
                        child: _Thumb(key: playbackScrubberThumbKey),
                      ),
                    ),
                    Positioned(
                      left: width * _displayFraction,
                      bottom: _labelBottomOffset,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, 0),
                        child: _TimeLabel(
                          key: playbackScrubberTimeLabelKey,
                          duration: _displayDuration,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Track extends StatelessWidget {
  final double fraction;

  const _Track({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(height: 1, color: AppColors.flowTrack),
            Container(
              height: 4,
              width: constraints.maxWidth * fraction,
              decoration: BoxDecoration(
                color: AppColors.willow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _PlaybackScrubberState._thumbDiameter,
      height: _PlaybackScrubberState._thumbDiameter,
      decoration: const BoxDecoration(
        color: AppColors.willow,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final Duration duration;

  const _TimeLabel({required this.duration, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatPlaybackDuration(duration),
      style: const TextStyle(fontSize: 10, color: AppColors.mist),
    );
  }
}
