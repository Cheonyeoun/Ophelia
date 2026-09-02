import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Reports [child]'s actual rendered size after every layout pass in
/// which it changes. Used by the navigation shell to measure the
/// mini-player's real height instead of assuming a fixed constant (see
/// lib/app/router.dart) — content-driven sizes (font metrics, text
/// scale, padding) can drift from any hardcoded guess.
class MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const MeasureSize({required this.onChange, required Widget super.child, super.key});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderObject(onChange);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _MeasureSizeRenderObject).onChange = onChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  ValueChanged<Size> onChange;
  Size? _lastReportedSize;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    final newSize = size;
    if (_lastReportedSize == newSize) return;
    _lastReportedSize = newSize;
    // Deferred to after this frame: reporting synchronously here would
    // mean notifying listeners (and potentially rebuilding widgets)
    // while a layout is still in progress.
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}
