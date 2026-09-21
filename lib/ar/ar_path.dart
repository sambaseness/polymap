import 'dart:math' as math;
import 'dart:ui' show Offset;

import '../data/models.dart';

/// The route ahead of the walker, in metres, in an east/north frame centred
/// on the walker (0,0). The schematic map's « up » is taken as north.
class ArPath {
  const ArPath(this.points);

  /// Vertices (east, north) in metres; `points.first` is the walker.
  final List<Offset> points;

  /// Builds the remaining path from the map-percentage polyline. The map
  /// scale is chosen so the full polyline measures the route's advertised
  /// distance, which keeps « 18 m » consistent with « 335 m ».
  factory ArPath.fromRoute(ComputedRoute r) {
    final all = r.points;
    var pctLength = 0.0;
    for (var i = 1; i < all.length; i++) {
      pctLength += (all[i] - all[i - 1]).distance;
    }
    final scale = pctLength < 1e-6 ? 4.0 : r.distM / pctLength;
    final here = r.here;
    final pts = <Offset>[
      for (var i = r.hereIndex; i < all.length; i++)
        Offset((all[i].dx - here.dx) * scale, -(all[i].dy - here.dy) * scale),
    ];
    if (pts.length < 2) pts.add(pts.first + const Offset(0, 20));
    return ArPath(pts);
  }

  double get length {
    var d = 0.0;
    for (var i = 1; i < points.length; i++) {
      d += (points[i] - points[i - 1]).distance;
    }
    return d;
  }

  /// Compass bearing (0 = north, clockwise) of segment [i] → [i+1].
  double bearingAt(int i) {
    final d = points[math.min(i + 1, points.length - 1)] -
        points[math.min(i, points.length - 2)];
    return _bearing(d);
  }

  double get initialBearing => bearingAt(0);

  /// Arrows laid on the ground along the path: the first [first] metres
  /// ahead, then every [spacing] metres, up to [count] arrows.
  List<ArArrowPlacement> arrows(
      {double first = 1.8, double spacing = 2.4, int count = 7}) {
    final out = <ArArrowPlacement>[];
    var seg = 0;
    var segStart = 0.0;
    var segLen = (points[1] - points[0]).distance;
    for (var k = 0; k < count; k++) {
      final target = first + k * spacing;
      while (target > segStart + segLen) {
        if (seg + 2 >= points.length) return out;
        segStart += segLen;
        seg++;
        segLen = (points[seg + 1] - points[seg]).distance;
      }
      final t = segLen < 1e-6 ? 0.0 : (target - segStart) / segLen;
      final pos = Offset.lerp(points[seg], points[seg + 1], t)!;
      out.add(ArArrowPlacement(
          pos: pos, bearing: bearingAt(seg), distance: target, index: k));
    }
    return out;
  }

  /// « Prochain virage » — distance to the next vertex and which way it turns.
  ArGuidance guidance() {
    final toNext = (points[1] - points[0]).distance;
    if (points.length < 3) {
      return ArGuidance(
          distance: toNext, turn: ArTurn.arrive, bearing: bearingAt(0));
    }
    final delta = _shortest(bearingAt(1) - bearingAt(0));
    final turn = delta.abs() < 20
        ? ArTurn.straight
        : delta > 0
            ? ArTurn.right
            : ArTurn.left;
    return ArGuidance(distance: toNext, turn: turn, bearing: bearingAt(0));
  }

  static double _bearing(Offset d) =>
      (math.atan2(d.dx, d.dy) * 180 / math.pi + 360) % 360;
  static double _shortest(double deg) => ((deg + 540) % 360) - 180;
}

class ArArrowPlacement {
  const ArArrowPlacement(
      {required this.pos,
      required this.bearing,
      required this.distance,
      required this.index});
  final Offset pos;
  final double bearing;

  /// Metres along the path from the walker.
  final double distance;
  final int index;
}

enum ArTurn {
  left('à gauche'),
  right('à droite'),
  straight('tout droit'),
  arrive('destination');

  const ArTurn(this.label);
  final String label;
}

class ArGuidance {
  const ArGuidance(
      {required this.distance, required this.turn, required this.bearing});
  final double distance;
  final ArTurn turn;

  /// Bearing of the segment the walker is on.
  final double bearing;

  String get distanceLabel => '${distance.round()} m';
}

/// A billboard label anchored in the world (door codes, landmarks).
class ArLabel {
  const ArLabel(
      {required this.text,
      required this.tint,
      required this.pos,
      this.height = 1.7});
  final String text;
  final PmTint tint;

  /// (east, north) metres from the walker.
  final Offset pos;
  final double height;

  /// Convert a route's label spec (along/side metres) into a world position.
  static List<ArLabel> along(ArPath path, List<RouteLabel> specs) {
    final out = <ArLabel>[];
    for (final s in specs) {
      final placements = path.arrows(first: s.along, spacing: 1, count: 1);
      if (placements.isEmpty) continue;
      final p = placements.first;
      final b = p.bearing * math.pi / 180;
      // Perpendicular to the path: +side = right-hand side.
      final right = Offset(math.cos(b), -math.sin(b));
      out.add(ArLabel(text: s.text, tint: s.tint, pos: p.pos + right * s.side));
    }
    return out;
  }
}
