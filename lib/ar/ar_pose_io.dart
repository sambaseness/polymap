import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'ar_pose.dart';

/// Android / iOS: tilt-compensated compass from accelerometer + magnetometer.
///
/// Device frame (sensors_plus normalises iOS to Android's convention):
/// x → right edge, y → top edge, z → out of the screen. The rear camera
/// looks along −z. Given gravity `g` and the magnetic vector `m`,
/// east = m × g and north = g × east; the camera heading is the bearing of
/// −z projected on the horizontal plane.
ArPoseSource createPoseSource() => _SensorPoseSource();

class _SensorPoseSource extends ArPoseSource {
  _SensorPoseSource() {
    _accSub = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (e) => _onAccel(e.x, e.y, e.z),
      onError: (Object e) => debugPrint('AR: accelerometer unavailable ($e)'),
    );
    _magSub = magnetometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (e) => _onMag(e.x, e.y, e.z),
      onError: (Object e) => debugPrint('AR: magnetometer unavailable ($e)'),
    );
  }

  final StreamController<ArPose> _out = StreamController<ArPose>.broadcast();
  StreamSubscription<AccelerometerEvent>? _accSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  // Low-pass filtered vectors.
  double _gx = 0, _gy = 9.8, _gz = 0;
  double _mx = 0, _my = 1, _mz = 0;
  bool _hasMag = false;

  @override
  Stream<ArPose> get poses => _out.stream;

  void _onAccel(double x, double y, double z) {
    const a = 0.15;
    _gx += a * (x - _gx);
    _gy += a * (y - _gy);
    _gz += a * (z - _gz);
    _emit();
  }

  void _onMag(double x, double y, double z) {
    const a = 0.15;
    _mx += a * (x - _mx);
    _my += a * (y - _my);
    _mz += a * (z - _mz);
    _hasMag = true;
  }

  void _emit() {
    final gLen = math.sqrt(_gx * _gx + _gy * _gy + _gz * _gz);
    if (gLen < 1e-3) return;
    final gx = _gx / gLen, gy = _gy / gLen, gz = _gz / gLen;

    // Camera forward in device frame.
    const fx = 0.0, fy = 0.0, fz = -1.0;
    final up = fx * gx + fy * gy + fz * gz; // component along "up"

    double east = 0, north = 1;
    if (_hasMag) {
      // E = m × g ; N = g × E
      var ex = _my * gz - _mz * gy, ey = _mz * gx - _mx * gz, ez = _mx * gy - _my * gx;
      final eLen = math.sqrt(ex * ex + ey * ey + ez * ez);
      if (eLen > 1e-6) {
        ex /= eLen;
        ey /= eLen;
        ez /= eLen;
        final nx = gy * ez - gz * ey, ny = gz * ex - gx * ez, nz = gx * ey - gy * ex;
        east = fx * ex + fy * ey + fz * ez;
        north = fx * nx + fy * ny + fz * nz;
      }
    } else {
      // No magnetometer yet: keep heading at 0 but still report pitch.
      final h = math.sqrt(math.max(0, 1 - up * up));
      east = 0;
      north = h;
    }

    // Roll: angle of the device x axis against the horizon.
    final roll = math.atan2(-gx, gy) * 180 / math.pi;
    _out.add(poseFromForward(east, north, up, roll: roll));
  }

  @override
  void dispose() {
    _accSub?.cancel();
    _magSub?.cancel();
    _out.close();
  }
}
