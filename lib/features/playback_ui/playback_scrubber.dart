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
/// thumb fades back out [_hideDelay] after the last interaction; a new
/// touch resets that timer.
///
/// The touch target is taller (44px, an accessibility-minimum tap size)
/// than the ~2px visible line: rather than reserving that full height in
/// the layout (which would push surrounding content around), the
/// visible track keeps its original small footprint and the hit-testable
/// area extends invisibly above/below it via a `Positioned` inside a
/// `Stack` with `clipBehavior: Clip.none` — painting/hit-testing outside
/// the box's own layout bounds, into space that's already empty gap
/// between this and the neighboring elements.
///
/// [lineAlwaysVisible] controls whether the line itself is always shown
/// (Everyday Play — only the thumb/label appear and disappear) or hidden
/// until first touched, fading out again together with the thumb
/// (Immersive Play, reinforcing its minimal philosophy — see
/// immersive_play_screen.dart).
class PlaybackScrubber extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final bool lineAlwaysVisible;

  const PlaybackScrubber({
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
  static const _trackFootprint = 16.0;
  static const _thumbDiameter = 14.0;

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

  double get _actualFraction => widget.duration == Duration.zero
      ? 0.0
      : (widget.position.inMilliseconds / widget.duration.inMilliseconds)
          .clamp(0.0, 1.0);

  double get _displayFraction => _dragFraction ?? _actualFraction;

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
    final fraction = _displayFraction;
    _dragFraction = null;
    final targetMs = (widget.duration.inMilliseconds * fraction).round();
    widget.onSeek(Duration(milliseconds: targetMs));
    _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: _trackFootprint,
          child: Stack(
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
              Positioned(
                left: 0,
                right: 0,
                top: -(_touchTargetHeight - _trackFootprint) / 2,
                bottom: -(_touchTargetHeight - _trackFootprint) / 2,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => _reveal(),
                  onTapUp: (_) => _commitSeek(),
                  onHorizontalDragStart: (details) {
                    _reveal();
                    _updateDrag(details.localPosition.dx, width);
                  },
                  onHorizontalDragUpdate: (details) =>
                      _updateDrag(details.localPosition.dx, width),
                  onHorizontalDragEnd: (_) => _commitSeek(),
                  child: const SizedBox.expand(),
                ),
              ),
              if (_revealed) ...[
                Positioned(
                  left: width * _displayFraction,
                  top: (_trackFootprint - _thumbDiameter) / 2,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, 0),
                    child: _Thumb(key: playbackScrubberThumbKey),
                  ),
                ),
                Positioned(
                  left: width * _displayFraction,
                  top: -22,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, 0),
                    child: _TimeLabel(
                      key: playbackScrubberTimeLabelKey,
                      duration: Duration(
                        milliseconds: (widget.duration.inMilliseconds *
                                _displayFraction)
                            .round(),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
