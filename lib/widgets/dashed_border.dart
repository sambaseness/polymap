import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Paints a dashed rounded-rectangle border — CSS `border: 1px dashed …`.
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.color,
    required this.radius,
    this.width = 1,
    this.dash = 4,
    this.gap = 3,
    this.child,
  });

  final Color color;
  final double radius;
  final double width;
  final double dash;
  final double gap;
  final Widget? child;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashedRRectPainter(color, radius, width, dash, gap),
        child: child,
      );
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter(this.color, this.radius, this.width, this.dash, this.gap);

  final Color color;
  final double radius;
  final double width;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(width / 2),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    canvas.drawPath(
      dashPath(path, dash: dash, gap: gap),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.width != width ||
      old.dash != dash ||
      old.gap != gap;
}

/// Turns any path into a dashed path. [phase] shifts the pattern (animate it
/// for the moving route dashes).
Path dashPath(Path source,
    {required double dash, required double gap, double phase = 0}) {
  final out = Path();
  for (final ui.PathMetric metric in source.computeMetrics()) {
    final period = dash + gap;
    var distance = -(phase % period);
    while (distance < metric.length) {
      final start = distance.clamp(0.0, metric.length);
      final end = (distance + dash).clamp(0.0, metric.length);
      if (end > start) out.addPath(metric.extractPath(start, end), Offset.zero);
      distance += period;
    }
  }
  return out;
}
