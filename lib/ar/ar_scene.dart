import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/models.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import 'ar_path.dart';
import 'ar_pose.dart';

/// The AR overlay: a chain of 3D arrows lying on the ground along the route,
/// drawn in perspective from the phone's point of view, plus billboard labels.
///
/// World frame: x = east, y = up, z = north, metres, origin at the walker's
/// feet. The camera sits at [eyeHeight] and looks along the pose heading.
/// Drag to look around (always on); sensors drive the pose when available.
class ArScene extends StatefulWidget {
  const ArScene({
    super.key,
    required this.path,
    required this.pose,
    this.labels = const <ArLabel>[],
    this.arrowCount = 7,
    this.arrowSpacing = 2.6,
    this.firstArrow = 3.5,
    this.eyeHeight = 1.5,
    this.verticalFov = 62,
  });

  final ArPath path;
  final ArPoseController pose;
  final List<ArLabel> labels;
  final int arrowCount;
  final double arrowSpacing;

  /// Distance (m) of the nearest arrow — keeps it hand-sized on screen.
  final double firstArrow;
  final double eyeHeight;

  /// Vertical field of view in degrees (rear phone camera ≈ 60–65°).
  final double verticalFov;

  @override
  State<ArScene> createState() => _ArSceneState();
}

class _ArSceneState extends State<ArScene> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<double> _time = ValueNotifier<double>(0);
  late List<ArArrowPlacement> _arrows;

  @override
  void initState() {
    super.initState();
    _arrows = widget.path.arrows(first: widget.firstArrow, spacing: widget.arrowSpacing, count: widget.arrowCount);
    _ticker = createTicker((elapsed) => _time.value = elapsed.inMicroseconds / 1e6)..start();
  }

  @override
  void didUpdateWidget(ArScene old) {
    super.didUpdateWidget(old);
    if (old.path != widget.path ||
        old.arrowCount != widget.arrowCount ||
        old.arrowSpacing != widget.arrowSpacing ||
        old.firstArrow != widget.firstArrow) {
      _arrows = widget.path.arrows(first: widget.firstArrow, spacing: widget.arrowSpacing, count: widget.arrowCount);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (d) => widget.pose.drag(d.delta.dx, d.delta.dy),
      onDoubleTap: widget.pose.resetDrag,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[widget.pose, _time]),
        builder: (context, _) => CustomPaint(
          painter: _ScenePainter(
            pose: widget.pose.pose,
            time: _time.value,
            path: widget.path,
            arrows: _arrows,
            labels: widget.labels,
            pm: pm,
            eyeHeight: widget.eyeHeight,
            vfovDeg: widget.verticalFov,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// A 3D point in camera space (x right, y up, z forward) plus its screen position.
class _Projected {
  const _Projected(this.screen, this.depth);
  final Offset screen;
  final double depth;
}

class _Camera {
  _Camera({required this.pose, required this.size, required this.eyeHeight, required double vfovDeg}) {
    final yaw = pose.heading * math.pi / 180;
    final pitch = pose.pitch * math.pi / 180;
    final roll = pose.roll * math.pi / 180;
    _cy = math.cos(yaw);
    _sy = math.sin(yaw);
    _cp = math.cos(pitch);
    _sp = math.sin(pitch);
    _cr = math.cos(roll);
    _sr = math.sin(roll);
    focal = (size.height / 2) / math.tan(vfovDeg * math.pi / 360);
    centre = size.center(Offset.zero);
  }

  final ArPose pose;
  final Size size;
  final double eyeHeight;
  late final double focal;
  late final Offset centre;
  late final double _cy, _sy, _cp, _sp, _cr, _sr;

  static const double near = 0.25;

  /// World (east, up, north) → camera space.
  (double, double, double) toCamera(double e, double y, double n) {
    // Yaw: camera forward = (sin yaw, cos yaw) in (east, north).
    final xc = e * _cy - n * _sy;
    final zc = e * _sy + n * _cy;
    final yc = y - eyeHeight;
    // Pitch about the camera x axis (looking up = positive).
    final y2 = yc * _cp - zc * _sp;
    final z2 = yc * _sp + zc * _cp;
    // Roll about the view axis.
    final x3 = xc * _cr + y2 * _sr;
    final y3 = -xc * _sr + y2 * _cr;
    return (x3, y3, z2);
  }

  _Projected? project(double e, double y, double n) {
    final (x, yy, z) = toCamera(e, y, n);
    if (z < near) return null;
    return _Projected(Offset(centre.dx + focal * x / z, centre.dy - focal * yy / z), z);
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.pose,
    required this.time,
    required this.path,
    required this.arrows,
    required this.labels,
    required this.pm,
    required this.eyeHeight,
    required this.vfovDeg,
  });

  final ArPose pose;
  final double time;
  final ArPath path;
  final List<ArArrowPlacement> arrows;
  final List<ArLabel> labels;
  final PmColors pm;
  final double eyeHeight;
  final double vfovDeg;

  // Arrow outline (top view, x right, z forward), metres. A thick chevron.
  static const List<Offset> _chevron = <Offset>[
    Offset(-0.50, -0.40),
    Offset(0.00, 0.55),
    Offset(0.50, -0.40),
    Offset(0.274, -0.40),
    Offset(0.00, 0.121),
    Offset(-0.274, -0.40),
  ];
  static const double _arrowScale = 0.8;
  static const double _thickness = 0.14;
  static const double _hover = 0.06;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = _Camera(pose: pose, size: size, eyeHeight: eyeHeight, vfovDeg: vfovDeg);
    _paintTrail(canvas, cam);

    final maxDist = arrows.isEmpty ? 1.0 : arrows.last.distance + 2;
    // Far to near so nearer arrows overdraw farther ones.
    final ordered = List<ArArrowPlacement>.of(arrows)..sort((a, b) => b.distance.compareTo(a.distance));
    for (final a in ordered) {
      final alpha = (1.15 - a.distance / maxDist).clamp(0.18, 1.0);
      final bob = a.index == 0 ? 0.10 * (0.5 + 0.5 * math.sin(time * 2.4)) : 0.0;
      _paintArrow(canvas, cam, a, alpha, bob);
    }
    for (final l in labels) {
      _paintLabel(canvas, cam, l);
    }
    _paintOffscreenHint(canvas, cam, size);
  }

  /// Faint dashed line on the ground under the arrows.
  void _paintTrail(Canvas canvas, _Camera cam) {
    // Start under the first arrow rather than under the camera (which is
    // behind the near plane whenever the phone is level).
    final world = <Offset>[
      if (arrows.isNotEmpty) arrows.first.pos else path.points.first,
      ...path.points.skip(1),
    ];
    final pts = <Offset>[];
    for (final p in world) {
      final pr = cam.project(p.dx, 0.01, p.dy);
      if (pr != null) pts.add(pr.screen);
    }
    if (pts.length < 2) return;
    final trail = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      trail.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      trail,
      Paint()
        ..color = PmFixed.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintArrow(Canvas canvas, _Camera cam, ArArrowPlacement a, double alpha, double bob) {
    final b = a.bearing * math.pi / 180;
    final cb = math.cos(b), sb = math.sin(b);
    final base = _hover + bob;

    // Local (x, z) → world (east, north).
    Offset world(Offset l) => Offset(
          a.pos.dx + (l.dx * cb + l.dy * sb) * _arrowScale,
          a.pos.dy + (-l.dx * sb + l.dy * cb) * _arrowScale,
        );

    // Ground glow (soft ellipse) — the design's radial halo under the arrow.
    final centre = cam.project(a.pos.dx, 0.0, a.pos.dy);
    if (centre == null) return;
    final glowR = (cam.focal * 0.55 * _arrowScale / centre.depth).clamp(4.0, 90.0);
    canvas.drawOval(
      Rect.fromCenter(center: centre.screen, width: glowR * 2.2, height: glowR * 0.9),
      Paint()
        ..color = PmFixed.brandBlue.withValues(alpha: 0.28 * alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowR * 0.5),
    );

    // Project top and bottom rings.
    final top = <_Projected?>[];
    final bottom = <_Projected?>[];
    final worldPts = <Offset>[];
    for (final l in _chevron) {
      final w = world(l);
      worldPts.add(w);
      top.add(cam.project(w.dx, base + _thickness, w.dy));
      bottom.add(cam.project(w.dx, base, w.dy));
    }
    if (top.any((p) => p == null) || bottom.any((p) => p == null)) return;

    // Side faces, visible ones only (normal facing the camera), far first.
    final faces = <(double, Path, double)>[];
    const light = Offset(0.55, 0.83); // world (east, north) light direction
    for (var i = 0; i < _chevron.length; i++) {
      final j = (i + 1) % _chevron.length;
      final d = worldPts[j] - worldPts[i];
      // Outline is clockwise in top view → outward normal is (-dz, dx).
      var n = Offset(-d.dy, d.dx);
      final len = n.distance;
      if (len < 1e-6) continue;
      n = n / len;
      final mid = (worldPts[i] + worldPts[j]) / 2;
      // Visible if the camera (at the origin, on the ground plane) is on the
      // outward side of the face.
      final toCam = Offset(-mid.dx, -mid.dy);
      if (toCam.dx * n.dx + toCam.dy * n.dy <= 0) continue;
      final shade = 0.50 + 0.30 * math.max(0, n.dx * light.dx + n.dy * light.dy);
      final quad = Path()
        ..moveTo(bottom[i]!.screen.dx, bottom[i]!.screen.dy)
        ..lineTo(bottom[j]!.screen.dx, bottom[j]!.screen.dy)
        ..lineTo(top[j]!.screen.dx, top[j]!.screen.dy)
        ..lineTo(top[i]!.screen.dx, top[i]!.screen.dy)
        ..close();
      faces.add(((bottom[i]!.depth + bottom[j]!.depth) / 2, quad, shade));
    }
    faces.sort((x, y) => y.$1.compareTo(x.$1));
    for (final (_, quad, shade) in faces) {
      canvas.drawPath(quad, Paint()..color = _shade(PmFixed.brandBlue, shade).withValues(alpha: alpha));
    }

    // Top face.
    final topPath = Path()..moveTo(top[0]!.screen.dx, top[0]!.screen.dy);
    for (final p in top.skip(1)) {
      topPath.lineTo(p!.screen.dx, p.screen.dy);
    }
    topPath.close();
    canvas.drawPath(topPath, Paint()..color = _lighten(PmFixed.brandBlue, 0.10).withValues(alpha: alpha));
    canvas.drawPath(
      topPath,
      Paint()
        ..color = PmFixed.white.withValues(alpha: 0.35 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintLabel(Canvas canvas, _Camera cam, ArLabel l) {
    final anchor = cam.project(l.pos.dx, l.height, l.pos.dy);
    if (anchor == null) return;
    final scale = (cam.focal / anchor.depth / 60).clamp(0.55, 1.15);
    final tp = TextPainter(
      text: TextSpan(text: l.text, style: PmText.sans(12 * scale, weight: FontWeight.w600, color: PmFixed.white)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final dot = 7.0 * scale, padX = 11.0 * scale, padY = 7.0 * scale, gap = 8.0 * scale;
    final w = padX * 2 + dot + gap + tp.width, h = padY * 2 + tp.height;
    final rect = Rect.fromCenter(center: anchor.screen, width: w, height: h);
    final fill = switch (l.tint) {
      PmTint.brown => PmFixed.brandBrown.withValues(alpha: .88),
      PmTint.ochre => PmFixed.brandOchre.withValues(alpha: .94),
      _ => PmFixed.brandBlue.withValues(alpha: .86),
    };
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(10 * scale)), Paint()..color = fill);
    canvas.drawCircle(
      Offset(rect.left + padX + dot / 2, rect.center.dy),
      dot / 2,
      Paint()..color = l.tint == PmTint.brown ? PmFixed.ochreLight : PmFixed.brandOchre,
    );
    tp.paint(canvas, Offset(rect.left + padX + dot + gap, rect.top + padY));
    // Stem down to the anchor's ground point.
    final ground = cam.project(l.pos.dx, 0, l.pos.dy);
    if (ground != null) {
      canvas.drawLine(
        Offset(anchor.screen.dx, rect.bottom),
        ground.screen,
        Paint()
          ..color = PmFixed.white.withValues(alpha: .35)
          ..strokeWidth = 1,
      );
    }
  }

  /// When the next arrow is outside the view, show which way to turn.
  void _paintOffscreenHint(Canvas canvas, _Camera cam, Size size) {
    if (arrows.isEmpty) return;
    final a = arrows.first;
    final rel = _shortest(_bearingOf(a.pos) - pose.heading);
    final hfov = 2 * math.atan((size.width / 2) / cam.focal) * 180 / math.pi;
    if (rel.abs() < hfov / 2 + 4) return;
    final right = rel > 0;
    final x = right ? size.width - 34 : 34;
    final y = size.height * 0.5;
    final path = Path();
    final dir = right ? 1.0 : -1.0;
    path.moveTo(x - 14 * dir, y - 18);
    path.lineTo(x + 10 * dir, y);
    path.lineTo(x - 14 * dir, y + 18);
    canvas.drawPath(
      path,
      Paint()
        ..color = PmFixed.brandOchre
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  static double _bearingOf(Offset p) => (math.atan2(p.dx, p.dy) * 180 / math.pi + 360) % 360;
  static double _shortest(double deg) => ((deg + 540) % 360) - 180;

  static Color _shade(Color c, double k) => Color.fromARGB(
        255,
        (c.r * 255 * k).round().clamp(0, 255),
        (c.g * 255 * k).round().clamp(0, 255),
        (c.b * 255 * k).round().clamp(0, 255),
      );

  static Color _lighten(Color c, double k) => Color.lerp(c, PmFixed.white, k)!;

  @override
  bool shouldRepaint(_ScenePainter old) => true;
}
