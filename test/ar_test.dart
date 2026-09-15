import 'package:flutter_test/flutter_test.dart';
import 'package:polymap/ar/ar_path.dart';
import 'package:polymap/ar/ar_pose.dart';
import 'package:polymap/data/campus_data.dart';
import 'package:polymap/data/models.dart';

void main() {
  group('ArPath', () {
    final route = CampusData.routes[0].compute(RouteMode.walk);
    final path = ArPath.fromRoute(route);

    test('starts at the walker and is scaled to the remaining distance', () {
      expect(path.points.first, Offset.zero);
      // The full polyline measures distM; the remaining part is shorter.
      expect(path.length, lessThan(route.distM.toDouble()));
      expect(path.length, greaterThan(route.distM * 0.3));
    });

    test('north is up on the map', () {
      // Route 0 walks up the map (decreasing y) → positive north.
      expect(path.points.last.dy, greaterThan(0));
      expect(path.initialBearing, inInclusiveRange(270, 360));
    });

    test('arrows are laid along the path at increasing distances', () {
      final arrows = path.arrows(first: 2, spacing: 3, count: 6);
      expect(arrows.length, 6);
      for (var i = 0; i < arrows.length; i++) {
        expect(arrows[i].distance, 2 + 3 * i);
        expect(arrows[i].index, i);
      }
      // The first arrow lies on the first segment, in its direction.
      expect(arrows.first.bearing, closeTo(path.bearingAt(0), 1e-6));
      expect(arrows.first.pos.distance, closeTo(2, 1e-6));
    });

    test('stops placing arrows past the end of the path', () {
      const short = ArPath(<Offset>[Offset.zero, Offset(0, 5)]);
      expect(short.arrows(first: 1, spacing: 2, count: 10).length, 3); // 1, 3, 5
    });

    test('guidance reports the next turn', () {
      const rightTurn = ArPath(<Offset>[Offset.zero, Offset(0, 18), Offset(20, 18)]);
      final g = rightTurn.guidance();
      expect(g.distance, 18);
      expect(g.turn, ArTurn.right);
      expect(g.distanceLabel, '18 m');

      const leftTurn = ArPath(<Offset>[Offset.zero, Offset(0, 10), Offset(-20, 12)]);
      expect(leftTurn.guidance().turn, ArTurn.left);

      const straight = ArPath(<Offset>[Offset.zero, Offset(0, 10), Offset(1, 30)]);
      expect(straight.guidance().turn, ArTurn.straight);

      const last = ArPath(<Offset>[Offset.zero, Offset(0, 7)]);
      expect(last.guidance().turn, ArTurn.arrive);
    });

    test('labels sit beside the path', () {
      const northPath = ArPath(<Offset>[Offset.zero, Offset(0, 30)]);
      final labels = ArLabel.along(northPath, const <RouteLabel>[
        RouteLabel('Porte', PmTint.blue, along: 5, side: 2),
        RouteLabel('Gauche', PmTint.brown, along: 8, side: -2),
      ]);
      expect(labels.length, 2);
      expect(labels[0].pos.dx, closeTo(2, 1e-6)); // right of a northbound path = east
      expect(labels[0].pos.dy, closeTo(5, 1e-6));
      expect(labels[1].pos.dx, closeTo(-2, 1e-6));
    });
  });

  group('ArPose', () {
    test('forward vector → heading and pitch', () {
      expect(poseFromForward(0, 1, 0).heading, closeTo(0, 1e-9));
      expect(poseFromForward(1, 0, 0).heading, closeTo(90, 1e-9));
      expect(poseFromForward(0, -1, 0).heading, closeTo(180, 1e-9));
      expect(poseFromForward(-1, 0, 0).heading, closeTo(270, 1e-9));
      expect(poseFromForward(0, 1, 1).pitch, closeTo(45, 1e-9));
      expect(poseFromForward(0, 1, -1).pitch, closeTo(-45, 1e-9));
    });

    test('controller applies drag offsets and wraps the heading', () {
      final c = ArPoseController(initial: const ArPose(heading: 350, pitch: 0), source: _Silent());
      c.drag(-80, 0, degreesPerPixel: 0.25); // drag left → turn right by 20°
      expect(c.pose.heading, closeTo(10, 1e-9));
      c.drag(0, 400); // pitch clamps
      expect(c.pose.pitch, 60);
      c.resetDrag();
      expect(c.pose.heading, closeTo(350, 1e-9));
      expect(c.sensorsActive, isFalse);
      c.dispose();
    });
  });
}

class _Silent extends ArPoseSource {
  @override
  Stream<ArPose> get poses => const Stream<ArPose>.empty();
}
