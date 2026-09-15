import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/campus_data.dart';
import '../data/models.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import 'dashed_border.dart';

/// Pale pedestrian alleys drawn under the buildings, in map percentages.
abstract final class MapRoads {
  static const Rect _v1 = Rect.fromLTWH(30, 0, 4, 100);
  static const Rect _h1 = Rect.fromLTWH(0, 24, 100, 3.4);
  static const Rect _v2 = Rect.fromLTWH(66, 0, 3.4, 100);

  /// Home map: two alleys + the eastern one.
  static const List<Rect> full = <Rect>[_v1, _h1, _v2];

  /// Route / navigation maps.
  static const List<Rect> two = <Rect>[_v1, _h1];
}

/// The schematic ESP campus map used on Home, Route and 2D navigation.
///
/// Everything is positioned in percentages of the widget so the same data
/// renders identically at any size, like the design prototype.
class CampusMap extends StatefulWidget {
  const CampusMap({
    super.key,
    this.buildings = CampusData.buildings,
    this.roads = MapRoads.full,
    this.route,
    this.navigating = false,
    this.userPosition,
    this.showLabels = true,
    this.roadOpacity = 0.7,
  });

  final List<Building> buildings;
  final List<Rect> roads;

  /// Route to draw. Preview style (blue + moving white dashes) unless
  /// [navigating], which draws the remaining path in `line` and the walked
  /// part in blue with a pulsing « here » marker.
  final ComputedRoute? route;
  final bool navigating;

  /// Pulsing user dot (Home).
  final Offset? userPosition;
  final bool showLabels;
  final double roadOpacity;

  @override
  State<CampusMap> createState() => _CampusMapState();
}

class _CampusMapState extends State<CampusMap> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(
            child: CustomPaint(
              painter: _BasePainter(
                pm: pm,
                buildings: widget.buildings,
                roads: widget.roads,
                roadOpacity: widget.roadOpacity,
                showLabels: widget.showLabels,
                labelStyle: PmText.sans(8.5, weight: FontWeight.w500, color: pm.bldgInk, height: 1.15),
              ),
            ),
          ),
          if (widget.route != null || widget.userPosition != null)
            AnimatedBuilder(
              animation: _t,
              builder: (_, __) => CustomPaint(
                painter: _OverlayPainter(
                  pm: pm,
                  t: _t.value,
                  route: widget.route,
                  navigating: widget.navigating,
                  userPosition: widget.userPosition,
                  labelStyle: PmText.sans(10, weight: FontWeight.w600, color: pm.onBlue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Offset _pct(Offset p, Size s) => Offset(p.dx / 100 * s.width, p.dy / 100 * s.height);

class _BasePainter extends CustomPainter {
  _BasePainter({
    required this.pm,
    required this.buildings,
    required this.roads,
    required this.roadOpacity,
    required this.showLabels,
    required this.labelStyle,
  });

  final PmColors pm;
  final List<Building> buildings;
  final List<Rect> roads;
  final double roadOpacity;
  final bool showLabels;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = pm.map);

    final roadPaint = Paint()..color = pm.bg.withValues(alpha: roadOpacity);
    for (final r in roads) {
      canvas.drawRect(
        Rect.fromLTWH(r.left / 100 * size.width, r.top / 100 * size.height,
            r.width / 100 * size.width, r.height / 100 * size.height),
        roadPaint,
      );
    }

    final fill = Paint();
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final b in buildings) {
      final rect = Rect.fromLTWH(b.x / 100 * size.width, b.y / 100 * size.height,
          b.w / 100 * size.width, b.h / 100 * size.height);
      final rr = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      fill.color = b.isGreen ? pm.green : pm.bldg;
      stroke.color = b.isGreen ? pm.green : pm.line;
      canvas.drawRRect(rr, fill);
      canvas.drawRRect(rr, stroke);

      if (!showLabels) continue;
      final tp = TextPainter(
        text: TextSpan(text: b.short, style: labelStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: math.max(0, rect.width - 4));
      if (tp.height > rect.height - 2) continue; // too small to fit, like `overflow: hidden`
      tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_BasePainter old) =>
      old.pm != pm ||
      old.buildings != buildings ||
      old.roads != roads ||
      old.roadOpacity != roadOpacity ||
      old.showLabels != showLabels;
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({
    required this.pm,
    required this.t,
    required this.route,
    required this.navigating,
    required this.userPosition,
    required this.labelStyle,
  });

  final PmColors pm;

  /// 0–1 loop, 2.4 s.
  final double t;
  final ComputedRoute? route;
  final bool navigating;
  final Offset? userPosition;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final r = route;
    if (r != null) {
      final path = _polyline(r.points, size);
      if (navigating) {
        canvas.drawPath(path, _line(pm.line, 7));
        canvas.drawPath(_polyline(r.donePoints, size), _line(pm.blue, 7));
        _pulseDot(canvas, _pct(r.here, size), outer: 20, inset: 5, ring: 2.5);
      } else {
        canvas.drawPath(path, _line(pm.blue, 5));
        // Moving white dashes: 6 on / 8 off, one period (14 px) per 1.6 s.
        final phase = (t * 2.4 / 1.6) * 28;
        canvas.drawPath(dashPath(path, dash: 6, gap: 8, phase: -phase), _line(pm.onBlue, 2));
        // Start: 14 px, surface fill, 3 px brown ring.
        final start = _pct(r.start, size);
        canvas.drawCircle(start, 7, Paint()..color = pm.surf);
        canvas.drawCircle(start, 5.5, Paint()..color = pm.brown..style = PaintingStyle.stroke..strokeWidth = 3);
        _destinationLabel(canvas, _pct(r.end, size), r.route.destShort);
      }
    }
    final u = userPosition;
    if (u != null) _pulseDot(canvas, _pct(u, size), outer: 16, inset: 4, ring: 2);
  }

  Paint _line(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Path _polyline(List<Offset> pts, Size size) {
    final p = Path();
    for (var i = 0; i < pts.length; i++) {
      final o = _pct(pts[i], size);
      i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
    }
    return p;
  }

  /// `pm-pulse`: scale 1 → 1.6, opacity .85 → .15, ease-in-out, 2.4 s.
  void _pulseDot(Canvas canvas, Offset c, {required double outer, required double inset, required double ring}) {
    final k = 0.5 - 0.5 * math.cos(t * 2 * math.pi); // 0→1→0
    final scale = 1 + 0.6 * k;
    final alpha = 0.85 - 0.7 * k;
    canvas.drawCircle(c, outer / 2 * scale, Paint()..color = pm.blue.withValues(alpha: alpha));
    final inner = outer / 2 - inset;
    canvas.drawCircle(c, inner, Paint()..color = pm.blue);
    canvas.drawCircle(c, inner - ring / 2, Paint()..color = pm.surf..style = PaintingStyle.stroke..strokeWidth = ring);
  }

  /// Blue pill with the destination name + a 2×10 stick, anchored at [p].
  void _destinationLabel(Canvas canvas, Offset p, String text) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    const stick = 10.0;
    final w = tp.width + 16, h = tp.height + 8;
    final rect = Rect.fromLTWH(p.dx - w / 2, p.dy - stick - h, w, h);
    canvas.drawRect(Rect.fromLTWH(p.dx - 1, p.dy - stick, 2, stick), Paint()..color = pm.blue);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(7)), Paint()..color = pm.blue);
    tp.paint(canvas, rect.topLeft + const Offset(8, 4));
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => true;
}
