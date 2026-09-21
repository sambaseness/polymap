import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'ar_pose_stub.dart'
    if (dart.library.io) 'ar_pose_io.dart'
    if (dart.library.js_interop) 'ar_pose_web.dart' as platform;

/// Where the rear camera is looking, in the world frame.
///
/// * [heading] — compass bearing of the camera axis in degrees, 0 = north,
///   90 = east (clockwise).
/// * [pitch]   — camera tilt in degrees, positive when looking up.
/// * [roll]    — device roll in degrees, positive when the right edge dips.
@immutable
class ArPose {
  const ArPose({required this.heading, required this.pitch, this.roll = 0});

  final double heading;
  final double pitch;
  final double roll;

  static const ArPose initial = ArPose(heading: 0, pitch: -8);

  ArPose copyWith({double? heading, double? pitch, double? roll}) => ArPose(
      heading: heading ?? this.heading,
      pitch: pitch ?? this.pitch,
      roll: roll ?? this.roll);

  @override
  String toString() =>
      'ArPose(h ${heading.toStringAsFixed(0)}°, p ${pitch.toStringAsFixed(0)}°)';
}

/// Platform source of raw poses (sensors on mobile, DeviceOrientation on web).
abstract class ArPoseSource {
  Stream<ArPose> get poses;

  /// Some browsers (iOS Safari) need an explicit, user-triggered permission
  /// before delivering orientation events.
  bool get needsPermission => false;
  Future<bool> requestPermission() async => true;

  void dispose() {}
}

/// Fuses the platform pose with the user's drag offsets and smooths it.
///
/// Drag-to-look is always available, so the AR view works on a laptop, in a
/// simulator, or when the compass is unreliable. When sensors deliver, the
/// drag offset simply adds to the sensed heading.
class ArPoseController extends ChangeNotifier {
  ArPoseController({ArPose initial = ArPose.initial, ArPoseSource? source})
      : _sensed = initial,
        _source = source ?? platform.createPoseSource() {
    _sub = _source.poses.listen(_onPose);
    _watchdog = Timer.periodic(const Duration(seconds: 1), (_) {
      final alive = _lastEvent != null &&
          DateTime.now().difference(_lastEvent!).inSeconds < 3;
      if (alive != _sensorsActive) {
        _sensorsActive = alive;
        notifyListeners();
      }
    });
  }

  final ArPoseSource _source;
  StreamSubscription<ArPose>? _sub;
  Timer? _watchdog;
  DateTime? _lastEvent;

  ArPose _sensed;
  double _dragYaw = 0;
  double _dragPitch = 0;
  bool _sensorsActive = false;

  /// True while the platform is delivering orientation events.
  bool get sensorsActive => _sensorsActive;
  bool _permissionAsked = false;
  bool get needsPermission =>
      _source.needsPermission && !_sensorsActive && !_permissionAsked;

  /// The pose to render: sensed (smoothed) + drag offsets, pitch clamped.
  ArPose get pose => ArPose(
        heading: _norm(_sensed.heading + _dragYaw),
        pitch: (_sensed.pitch + _dragPitch).clamp(-60.0, 60.0),
        roll: _sensed.roll,
      );

  Future<void> requestPermission() async {
    _permissionAsked = true;
    notifyListeners();
    await _source.requestPermission();
  }

  /// Drag by screen pixels: horizontal → yaw, vertical → pitch.
  void drag(double dx, double dy, {double degreesPerPixel = 0.25}) {
    _dragYaw = _norm(_dragYaw - dx * degreesPerPixel);
    _dragPitch = (_dragPitch + dy * degreesPerPixel).clamp(-70.0, 70.0);
    notifyListeners();
  }

  /// Forget drag offsets (« recentrer »).
  void resetDrag() {
    _dragYaw = 0;
    _dragPitch = 0;
    notifyListeners();
  }

  /// Without sensors, start looking along [heading] so the path is ahead.
  void seedHeading(double heading) {
    if (_sensorsActive) return;
    _sensed = _sensed.copyWith(heading: heading);
    notifyListeners();
  }

  void _onPose(ArPose p) {
    _lastEvent = DateTime.now();
    // Exponential smoothing; heading through its shortest arc.
    const a = 0.22;
    final dh = _shortest(p.heading - _sensed.heading);
    _sensed = ArPose(
      heading: _norm(_sensed.heading + a * dh),
      pitch: _sensed.pitch + a * (p.pitch - _sensed.pitch),
      roll: _sensed.roll + a * (p.roll - _sensed.roll),
    );
    if (!_sensorsActive) _sensorsActive = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _watchdog?.cancel();
    _source.dispose();
    super.dispose();
  }

  static double _norm(double deg) => ((deg % 360) + 360) % 360;
  static double _shortest(double deg) => ((deg + 540) % 360) - 180;
}

/// Camera-forward vector expressed in a world basis (east, north, up) → pose.
ArPose poseFromForward(double east, double north, double up,
    {double roll = 0}) {
  final heading = math.atan2(east, north) * 180 / math.pi;
  final pitch =
      math.atan2(up, math.sqrt(east * east + north * north)) * 180 / math.pi;
  return ArPose(
      heading: ((heading % 360) + 360) % 360, pitch: pitch, roll: roll);
}
