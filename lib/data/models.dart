import 'package:flutter/painting.dart' show Offset;

/// A building footprint on the schematic campus map.
/// Coordinates are percentages of the map area (0–100), like the design source.
class Building {
  const Building({
    required this.name,
    required this.short,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.isGreen = false,
  });

  final String name;

  /// Label drawn inside the footprint (may contain `\n`).
  final String short;
  final double x, y, w, h;

  /// Sports field / green space — uses the green token instead of `bldg`.
  final bool isGreen;
}

/// Tint role — maps onto the three brand colours.
enum PmTint { blue, brown, ochre, line }

class RouteStep {
  const RouteStep(this.n, this.label, this.dist);

  /// Step number, or a glyph such as « ↗ » for an inserted detour.
  final String n;
  final String label;
  final String dist;
}

/// « À pied », « Accessible », « Le plus court ».
enum RouteMode {
  walk('À pied', 0, 0),
  accessible('Accessible', 2, 70),
  shortest('Le plus court', -1, -45);

  const RouteMode(this.label, this.minDelta, this.distDelta);

  final String label;
  final int minDelta;
  final int distDelta;
}

/// A door / landmark label shown in AR, placed [along] metres down the path
/// and [side] metres to the right of it (negative = left).
class RouteLabel {
  const RouteLabel(this.text, this.tint, {required this.along, required this.side});
  final String text;
  final PmTint tint;
  final double along;
  final double side;
}

/// A level change on the route (stairs / ramp), shown as the ochre banner.
class FloorChange {
  const FloorChange({
    required this.title,
    required this.detail,
    required this.stairs,
    required this.fromTo,
    required this.steps,
    required this.then,
    required this.thenDetail,
  });

  /// « Montez au 1er étage »
  final String title;

  /// « Escalier B, à 18 m — puis 2e porte à gauche »
  final String detail;

  /// « Escalier B »
  final String stairs;

  /// « RDC → 1er étage »
  final String fromTo;
  final int steps;

  /// « Ensuite : 2e porte à gauche »
  final String then;

  /// « Salle C-107 · à 34 m après l'escalier »
  final String thenDetail;
}

class CampusRoute {
  const CampusRoute({
    required this.from,
    required this.to,
    required this.destShort,
    required this.minutes,
    required this.distM,
    required this.pts,
    required this.alt,
    required this.short,
    required this.steps,
    this.arLabels = const <RouteLabel>[],
    this.floorChange,
  });

  final String from;
  final String to;
  final String destShort;
  final int minutes;
  final int distM;

  /// Labels rendered in the AR view along the remaining path.
  final List<RouteLabel> arLabels;

  /// Level change ahead, if any.
  final FloorChange? floorChange;

  /// Polyline in map percentages for each mode.
  final List<Offset> pts;
  final List<Offset> alt;
  final List<Offset> short;
  final List<RouteStep> steps;

  /// The route as it will be displayed for a given [mode]: the prototype
  /// adds a ramp detour for « Accessible » and drops a step for « Le plus court ».
  ComputedRoute compute(RouteMode mode) {
    final points = switch (mode) {
      RouteMode.walk => pts,
      RouteMode.accessible => alt,
      RouteMode.shortest => short,
    };
    final list = List<RouteStep>.of(steps);
    if (mode == RouteMode.accessible) {
      list.insert(
        list.length - 1,
        const RouteStep('↗', "Rampe d'accès — contournement de l'escalier", '70 m'),
      );
    } else if (mode == RouteMode.shortest && list.length > 1) {
      list.removeAt(1);
    }
    return ComputedRoute(
      route: this,
      mode: mode,
      points: points,
      steps: list,
      minutes: minutes + mode.minDelta,
      distM: distM + mode.distDelta,
    );
  }
}

class ComputedRoute {
  const ComputedRoute({
    required this.route,
    required this.mode,
    required this.points,
    required this.steps,
    required this.minutes,
    required this.distM,
  });

  final CampusRoute route;
  final RouteMode mode;
  final List<Offset> points;
  final List<RouteStep> steps;
  final int minutes;
  final int distM;

  Offset get start => points.first;
  Offset get end => points.last;

  /// Index of the point the walker is currently at (half-way, like the demo).
  int get hereIndex => (points.length / 2).ceil().clamp(2, points.length) - 1;
  Offset get here => points[hereIndex];
  List<Offset> get donePoints => points.sublist(0, hereIndex + 1);
}

/// A room marker on a floor plan.
class RoomDot {
  const RoomDot(this.code, this.x, this.y, this.kind);
  final String code;
  final double x, y;

  /// blue = classroom, brown = office, ochre = service.
  final PmTint kind;
}

/// One block in a timetable or a room's occupation list.
class Course {
  const Course({
    required this.time,
    required this.title,
    required this.who,
    required this.room,
    required this.tint,
    this.hour = '',
    this.duration = '',
    this.walk = '',
  });

  final String time;
  final String title;
  final String who;
  final String room;
  final PmTint tint;

  // Weekly view only.
  final String hour;
  final String duration;
  final String walk;
}

/// Where a search result / favourite leads when tapped.
sealed class PlaceTarget {
  const PlaceTarget();
}

class RouteTarget extends PlaceTarget {
  const RouteTarget(this.routeIndex);
  final int routeIndex;
}

class RoomTarget extends PlaceTarget {
  const RoomTarget();
}

class DirectoryTarget extends PlaceTarget {
  const DirectoryTarget();
}

class Place {
  const Place({
    required this.code,
    required this.name,
    required this.place,
    required this.dist,
    required this.target,
    this.keywords = const <String>[],
  });

  final String code;
  final String name;
  final String place;
  final String dist;
  final PlaceTarget target;

  /// Extra terms the search should match on (e.g. « salle 204 », « amphi »).
  final List<String> keywords;

  bool matches(String query) {
    final q = _norm(query);
    if (q.isEmpty) return false;
    final hay = <String>[name, place, code, ...keywords].map(_norm);
    return hay.any((h) => h.contains(q)) ||
        q.split(' ').every((w) => hay.any((h) => h.contains(w)));
  }

  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[àâä]'), 'a')
      .replaceAll(RegExp('[îï]'), 'i')
      .replaceAll(RegExp('[ôö]'), 'o')
      .replaceAll(RegExp('[ùûü]'), 'u')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class DirectoryItem {
  const DirectoryItem(this.tag, this.name, this.meta, this.tint);
  final String tag;
  final String name;
  final String meta;
  final PmTint tint;
}

class DirectoryGroup {
  const DirectoryGroup(this.title, this.items);
  final String title;
  final List<DirectoryItem> items;
}

class OfflinePack {
  const OfflinePack(this.name, this.size, this.state, this.progress);
  final String name;
  final String size;
  final String state;

  /// 0–1.
  final double progress;
}
