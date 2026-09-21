import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../ar/ar_path.dart';
import '../../ar/ar_pose.dart';
import '../../ar/ar_scene.dart';
import '../../data/models.dart';
import '../../data/node_graph.dart';
import '../../navigation.dart';
import '../../state/app_state.dart';
import '../../theme/pm_colors.dart';
import '../../theme/pm_text.dart';
import '../../widgets/camera_backdrop.dart';
import '../../widgets/glyphs.dart';
import '../../widgets/pm_button.dart';
import '../arrival_screen.dart';
import 'ar_floor_screen.dart';
import 'ar_widgets.dart';

/// 16 — AR : navigation.
///
/// The route ahead is laid on the ground as a chain of 3D arrows drawn in
/// perspective from the phone's point of view ([ArScene]); the compass and
/// tilt sensors orient the view, drag works everywhere. Door labels are
/// anchored in the same metric frame.
///
/// Position is determined by QR code scans (AppState.currentNodeId →
/// NodeGraph.findNode()), or falls back to the demo position when no
/// QR has been scanned yet.
class ArNavigationScreen extends StatefulWidget {
  const ArNavigationScreen({super.key});

  @override
  State<ArNavigationScreen> createState() => _ArNavigationScreenState();
}

/// Scale factor: 1 LatLng degree ≈ 111km at equator.
/// Campus is small enough that we can use a simple linear approximation.
const double _kLatLngToOffsetScale = 100000.0;

/// Convert a LatLng position to an Offset in metres relative to the
/// campus center (approximate). Used as the AR scene origin.
Offset latLngToOffset(LatLng latLng) {
  return Offset(
    (latLng.longitude - (-17.4467)) * _kLatLngToOffsetScale,
    (latLng.latitude - 14.6904) * _kLatLngToOffsetScale,
  );
}

class _ArNavigationScreenState extends State<ArNavigationScreen> {
  late final ArPoseController _pose;
  late ArPath _path;
  late List<ArLabel> _labels;
  late ComputedRoute _route;
  late Offset _arOrigin = Offset.zero;

  @override
  void initState() {
    super.initState();
    _route = context.read<AppState>().computedRoute;
    _path = ArPath.fromRoute(_route);
    _labels = ArLabel.along(_path, _route.route.arLabels);
    // Without sensors, start looking down the path.
    _pose = ArPoseController(initial: ArPose(heading: _path.initialBearing, pitch: -12));
    // Resolve AR origin from QR scan position, or use demo position.
    _arOrigin = _resolveArOrigin();
  }

  /// Resolve the AR origin from the current node position.
  /// If a QR code has been scanned (currentNodeId is set), use the
  /// node's position. Otherwise, fall back to the demo position.
  Offset _resolveArOrigin() {
    final appState = context.read<AppState>();
    final nodeId = appState.currentNodeId;
    if (nodeId != null) {
      final node = NodeGraph.findNode(nodeId);
      if (node != null) {
        return latLngToOffset(node.position);
      }
    }
    // Fallback: demo position (Pavillon C user position).
    return Offset(32.5, 90);
  }

  @override
  void dispose() {
    _pose.dispose();
    super.dispose();
  }

  void _exit() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 720;
    final guidance = _path.guidance();
    final floor = _route.route.floorChange;
    final remaining = math.max(1, _route.minutes - 1);
    final metersLeft = (_route.distM * 0.75 / 5).round() * 5;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: PmFixed.arBg,
        body: CameraBackdrop(
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: ArScene(path: _path, pose: _pose, labels: _labels, origin: _arOrigin)),
              Positioned(
                left: 20,
                top: pad.top + 22,
                child: ArNextTurnCard(
                  distance: guidance.distanceLabel,
                  direction: guidance.turn.label,
                  eta: 'Arrivée dans $remaining min · $metersLeft m restants',
                ),
              ),
              Positioned(right: 20, top: pad.top + 22, child: ArExitButton(onTap: _exit)),
              Positioned(left: 20, bottom: pad.bottom + 98, child: _SensorChip(pose: _pose)),
              if (floor != null)
                Positioned(
                  left: 20,
                  right: wide ? null : 20,
                  width: wide ? 400 : null,
                  top: pad.top + 122,
                  child: _FloorBanner(
                    floor: floor,
                    onTap: () => PmNav.push<void>(context, ArFloorScreen(floor: floor)),
                  ),
                ),
              Positioned(right: 20, bottom: pad.bottom + 98, child: _Minimap(path: _path)),
              Positioned(
                left: 20,
                right: wide ? null : 20,
                width: wide ? 400 : null,
                bottom: pad.bottom + 12,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: PmButton(
                        label: 'Je suis arrivé',
                        variant: PmButtonVariant.brand,
                        onTap: () => PmNav.pushInShell(context, const ArrivalScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 52,
                      child: PmButton(
                        label: '×',
                        variant: PmButtonVariant.glass,
                        height: 52,
                        fontSize: 17,
                        padding: EdgeInsets.zero,
                        onTap: _exit,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows whether the compass drives the view; offers permission on iOS web,
/// and a « recentrer » reset after dragging.
class _SensorChip extends StatelessWidget {
  const _SensorChip({required this.pose});
  final ArPoseController pose;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pose,
      builder: (context, _) {
        final String text;
        final VoidCallback? onTap;
        if (pose.needsPermission) {
          text = 'Activer la boussole';
          onTap = pose.requestPermission;
        } else if (pose.sensorsActive) {
          text = 'Boussole · ${pose.pose.heading.round()}°';
          onTap = pose.resetDrag;
        } else {
          text = 'Glissez pour regarder';
          onTap = pose.resetDrag;
        }
        return ArGlass(
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pose.sensorsActive ? const Color(0xFFA9C9A1) : PmFixed.brandOchre,
                ),
              ),
              const SizedBox(width: 8),
              Text(text, style: PmText.mono(10.5, color: PmFixed.white.withValues(alpha: .85), ls: 0.04)),
            ],
          ),
        );
      },
    );
  }
}

class _FloorBanner extends StatelessWidget {
  const _FloorBanner({required this.floor, required this.onTap});
  final FloorChange floor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        child: Material(
          color: PmFixed.brandOchre.withValues(alpha: .94),
          borderRadius: BorderRadius.circular(15),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
              child: Row(
                children: <Widget>[
                  const StairsGlyph(color: PmFixed.onOchre),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(floor.title, style: PmText.sans(14, weight: FontWeight.w700, color: PmFixed.onOchre)),
                        Text(floor.detail, style: PmText.sans(12.5, color: PmFixed.onOchre.withValues(alpha: .8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

/// 108 px minimap — dark, current floor, the remaining path from above.
class _Minimap extends StatelessWidget {
  const _Minimap({required this.path});
  final ArPath path;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: PmFixed.arMinimapBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PmFixed.white.withValues(alpha: .18)),
        boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x80000000), offset: Offset(0, 10), blurRadius: 30)],
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _MinimapPainter(path))),
          Positioned(
            left: 8,
            bottom: 6,
            child: Text('RDC', style: PmText.mono(8, color: PmFixed.white.withValues(alpha: .5), ls: 0.1)),
          ),
        ],
      ),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  _MinimapPainter(this.path);
  final ArPath path;

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Rect.fromLTWH(0, s.height * .4, s.width, 12), Paint()..color = PmFixed.white.withValues(alpha: .07));
    final b = Paint()..color = PmFixed.arMinimapBldg;
    for (final r in const <Rect>[Rect.fromLTWH(14, 18, 26, 22), Rect.fromLTWH(56, 20, 30, 18), Rect.fromLTWH(20, 62, 34, 24)]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(r.left / 100 * s.width, r.top / 100 * s.height, r.width / 100 * s.width, r.height / 100 * s.height),
          const Radius.circular(3),
        ),
        b,
      );
    }
    // Remaining path, north up, walker near the bottom, ~1.4 px per metre.
    final origin = Offset(s.width * .3, s.height * .84);
    const k = 1.4;
    final p = Path()..moveTo(origin.dx, origin.dy);
    for (final w in path.points.skip(1)) {
      p.lineTo(origin.dx + w.dx * k, origin.dy - w.dy * k);
    }
    canvas.save();
    canvas.clipRect(Offset.zero & s);
    canvas.drawPath(
      p,
      Paint()
        ..color = PmFixed.arMinimapBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
    canvas.drawCircle(origin, 4.5, Paint()..color = PmFixed.arMinimapBlue);
    canvas.drawCircle(origin, 3.5, Paint()..color = PmFixed.arMinimapBg..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_MinimapPainter old) => old.path != path;
}
