import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ophelia/features/playback_ui/playback_scrubber.dart';

void main() {
  Widget wrap(Widget child, {double width = 300}) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    );
  }

  testWidgets('the thumb and time label are hidden by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        PlaybackScrubber(
          position: const Duration(seconds: 10),
          duration: const Duration(seconds: 100),
          onSeek: (_) {},
        ),
      ),
    );

    expect(find.byKey(playbackScrubberThumbKey), findsNothing);
    expect(find.byKey(playbackScrubberTimeLabelKey), findsNothing);
    // The line itself is always visible by default (lineAlwaysVisible).
    expect(
      tester.widget<AnimatedOpacity>(find.byKey(playbackScrubberLineKey)).opacity,
      1,
    );
  });

  testWidgets('touching down near the line reveals the thumb and time '
      'label, at the current position', (tester) async {
    await tester.pumpWidget(
      wrap(
        PlaybackScrubber(
          position: const Duration(seconds: 50),
          duration: const Duration(seconds: 100),
          onSeek: (_) {},
        ),
      ),
    );

    final topLeft = tester.getTopLeft(find.byType(PlaybackScrubber));
    final gesture = await tester.startGesture(topLeft + const Offset(150, 8));
    // GestureDetector's onTapDown fires once the tap recognizer's
    // internal press-timeout deadline elapses (it also fires immediately
    // on release, which is why a plain tester.tap() doesn't need this,
    // but here the pointer is still held down).
    await tester.pump(kPressTimeout);

    expect(find.byKey(playbackScrubberThumbKey), findsOneWidget);
    expect(find.byKey(playbackScrubberTimeLabelKey), findsOneWidget);
    // Revealed at the actual current position (50%), not wherever the
    // touch happened to land, since no drag has occurred yet.
    expect(find.text('0:50'), findsOneWidget);

    await gesture.up();
  });

  testWidgets(
    'dragging moves the thumb and updates the label live, but does not '
    'call onSeek until release',
    (tester) async {
      Duration? seekedTo;
      await tester.pumpWidget(
        wrap(
          PlaybackScrubber(
            position: Duration.zero,
            duration: const Duration(seconds: 100),
            onSeek: (d) => seekedTo = d,
          ),
          width: 300,
        ),
      );

      final topLeft = tester.getTopLeft(find.byType(PlaybackScrubber));
      final gesture = await tester.startGesture(
        topLeft + const Offset(5, 8),
      );
      await tester.pump();

      await gesture.moveTo(topLeft + const Offset(150, 8));
      await tester.pump();

      // Halfway across a 300-wide, 100s track -> ~0:50 -- shown live,
      // but not yet seeked.
      expect(find.text('0:50'), findsOneWidget);
      expect(seekedTo, isNull);

      await gesture.up();
      await tester.pump();

      expect(seekedTo, isNotNull);
      expect(seekedTo!.inSeconds, closeTo(50, 1));
    },
  );

  testWidgets(
    'releasing calls onSeek exactly once, with the position corresponding '
    'to where the thumb was dropped',
    (tester) async {
      final seeks = <Duration>[];
      await tester.pumpWidget(
        wrap(
          PlaybackScrubber(
            position: Duration.zero,
            duration: const Duration(seconds: 100),
            onSeek: seeks.add,
          ),
          width: 200,
        ),
      );

      final topLeft = tester.getTopLeft(find.byType(PlaybackScrubber));
      final gesture = await tester.startGesture(
        topLeft + const Offset(5, 8),
      );
      await tester.pump();
      // Drag to the 3/4 point of a 200-wide, 100s track -> ~1:15.
      await gesture.moveTo(topLeft + const Offset(150, 8));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(seeks, hasLength(1));
      expect(seeks.single.inSeconds, closeTo(75, 1));
    },
  );

  testWidgets(
    'the thumb fades out automatically ~2.5s after the last interaction',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          PlaybackScrubber(
            position: Duration.zero,
            duration: const Duration(seconds: 100),
            onSeek: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(PlaybackScrubber));
      await tester.pump();
      expect(find.byKey(playbackScrubberThumbKey), findsOneWidget);

      // Just under the hide delay: still visible.
      await tester.pump(const Duration(milliseconds: 2000));
      expect(find.byKey(playbackScrubberThumbKey), findsOneWidget);

      // Past the hide delay: faded out.
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(playbackScrubberThumbKey), findsNothing);
    },
  );

  testWidgets('a new touch resets the auto-hide timer', (tester) async {
    await tester.pumpWidget(
      wrap(
        PlaybackScrubber(
          position: Duration.zero,
          duration: const Duration(seconds: 100),
          onSeek: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(PlaybackScrubber));
    await tester.pump();
    expect(find.byKey(playbackScrubberThumbKey), findsOneWidget);

    // Touch again just before the original timer would have fired.
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.tap(find.byType(PlaybackScrubber));
    await tester.pump();

    // If the first touch's timer weren't reset, the thumb would already
    // be gone by 500ms after this point (2000 + 500 = 2500ms since the
    // first touch).
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(playbackScrubberThumbKey), findsOneWidget);

    // But it does still hide, ~2.5s after this second touch.
    await tester.pump(const Duration(milliseconds: 2100));
    expect(find.byKey(playbackScrubberThumbKey), findsNothing);
  });

  group('lineAlwaysVisible: false (Immersive Play)', () {
    testWidgets(
      'the entire scrubber -- line included -- stays invisible until '
      'tapped',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            PlaybackScrubber(
              position: const Duration(seconds: 10),
              duration: const Duration(seconds: 100),
              onSeek: (_) {},
              lineAlwaysVisible: false,
            ),
          ),
        );

        expect(
          tester
              .widget<AnimatedOpacity>(find.byKey(playbackScrubberLineKey))
              .opacity,
          0,
        );
        expect(find.byKey(playbackScrubberThumbKey), findsNothing);

        await tester.tap(find.byType(PlaybackScrubber));
        await tester.pump();

        expect(
          tester
              .widget<AnimatedOpacity>(find.byKey(playbackScrubberLineKey))
              .opacity,
          1,
        );
        expect(find.byKey(playbackScrubberThumbKey), findsOneWidget);
      },
    );

    testWidgets(
      'the revealed line and thumb fade back out together after the hide '
      'delay',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            PlaybackScrubber(
              position: Duration.zero,
              duration: const Duration(seconds: 100),
              onSeek: (_) {},
              lineAlwaysVisible: false,
            ),
          ),
        );

        await tester.tap(find.byType(PlaybackScrubber));
        await tester.pump();
        expect(
          tester
              .widget<AnimatedOpacity>(find.byKey(playbackScrubberLineKey))
              .opacity,
          1,
        );

        await tester.pump(const Duration(milliseconds: 2600));

        expect(
          tester
              .widget<AnimatedOpacity>(find.byKey(playbackScrubberLineKey))
              .opacity,
          0,
        );
        expect(find.byKey(playbackScrubberThumbKey), findsNothing);
      },
    );
  });

  testWidgets(
    'a drag in progress is discarded if the duration changes underneath '
    'it (e.g. the track was skipped from elsewhere while still held), '
    'instead of later seeking to a position computed against the wrong '
    'track',
    (tester) async {
      var duration = const Duration(seconds: 100);
      late StateSetter setOuterState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setOuterState = setState;
                return Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 300,
                    child: PlaybackScrubber(
                      position: Duration.zero,
                      duration: duration,
                      onSeek: (_) {},
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      final topLeft = tester.getTopLeft(find.byType(PlaybackScrubber));
      final gesture = await tester.startGesture(
        topLeft + const Offset(5, 8),
      );
      await tester.pump();
      await gesture.moveTo(topLeft + const Offset(150, 8));
      await tester.pump();

      // Dragged to the halfway point of a 100s track -> ~0:50.
      expect(find.text('0:50'), findsOneWidget);

      // The track (and its duration) changes while the finger is still
      // down -- e.g. skipped via a notification/lock-screen control.
      setOuterState(() => duration = const Duration(seconds: 200));
      await tester.pump();

      // The stale drag is dropped; the label falls back to the actual
      // (unchanged) position, not the meaningless leftover fraction.
      expect(find.text('0:00'), findsOneWidget);

      await gesture.up();
      await tester.pump();
    },
  );

  testWidgets(
    'exposes a slider semantics node with the current position as its '
    'value, for screen readers',
    (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(
          PlaybackScrubber(
            position: const Duration(seconds: 42),
            duration: const Duration(seconds: 100),
            onSeek: (_) {},
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PlaybackScrubber));
      expect(semantics.flagsCollection.isSlider, isTrue);
      expect(semantics.value, '0:42');

      handle.dispose();
    },
  );
}
