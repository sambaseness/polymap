import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;

import 'package:web/web.dart' as web;

import 'ar_pose.dart';

/// Browser: `deviceorientationabsolute` (Android Chrome, compass-referenced),
/// falling back to `deviceorientation` (+ `webkitCompassHeading` on iOS).
///
/// Uses the W3C device-orientation rotation matrix (Z·X'·Y'') to express the
/// rear camera axis (device −z) in the earth frame (east, north, up).
ArPoseSource createPoseSource() => _WebPoseSource();

@JS('DeviceOrientationEvent.requestPermission')
external JSPromise<JSString> _requestOrientationPermission();

class _WebPoseSource extends ArPoseSource {
  _WebPoseSource() {
    _absListener = ((web.Event e) => _onEvent(e, absolute: true)).toJS;
    _relListener = ((web.Event e) => _onEvent(e, absolute: false)).toJS;
    web.window.addEventListener('deviceorientationabsolute', _absListener);
    web.window.addEventListener('deviceorientation', _relListener);
  }

  final StreamController<ArPose> _out = StreamController<ArPose>.broadcast();
  late final JSFunction _absListener;
  late final JSFunction _relListener;
  DateTime? _lastAbsolute;

  @override
  Stream<ArPose> get poses => _out.stream;

  /// Only touch devices carry orientation sensors; desktop Chromium exposes
  /// `requestPermission` too but would never deliver events.
  @override
  bool get needsPermission {
    if (web.window.navigator.maxTouchPoints == 0) return false;
    final ctor = web.window.getProperty<JSObject?>('DeviceOrientationEvent'.toJS);
    return ctor != null && ctor.has('requestPermission');
  }

  @override
  Future<bool> requestPermission() async {
    if (!needsPermission) return true;
    try {
      final r = await _requestOrientationPermission().toDart;
      return r.toDart == 'granted';
    } catch (_) {
      return false;
    }
  }

  void _onEvent(web.Event e, {required bool absolute}) {
    final ev = e as web.DeviceOrientationEvent;
    final now = DateTime.now();
    if (absolute) {
      _lastAbsolute = now;
    } else if (_lastAbsolute != null && now.difference(_lastAbsolute!).inSeconds < 2) {
      return; // absolute events are flowing — ignore the relative ones
    }

    var alpha = ev.alpha;
    final beta = ev.beta ?? 0;
    final gamma = ev.gamma ?? 0;

    // iOS Safari: alpha is arbitrary, but the compass heading is exposed.
    final compass = (e as JSObject).getProperty<JSNumber?>('webkitCompassHeading'.toJS)?.toDartDouble;
    if (compass != null && !compass.isNaN) alpha = 360 - compass;
    if (alpha == null) return;

    final a = alpha * math.pi / 180, b = beta * math.pi / 180, g = gamma * math.pi / 180;
    final cA = math.cos(a), sA = math.sin(a);
    final cB = math.cos(b), sB = math.sin(b);
    final cG = math.cos(g), sG = math.sin(g);

    // Third column of the device→earth matrix = earth coords of device +z.
    final zx = cA * sG + cG * sA * sB;
    final zy = sA * sG - cA * cG * sB;
    final zz = cB * cG;

    // Roll: how far the device x axis dips below the horizon (its earth "up"
    // component is −cB·sG); positive when the right edge is down.
    final roll = math.asin((cB * sG).clamp(-1.0, 1.0)) * 180 / math.pi;

    // Rear camera looks along device −z.
    _out.add(poseFromForward(-zx, -zy, -zz, roll: roll));
  }

  @override
  void dispose() {
    web.window.removeEventListener('deviceorientationabsolute', _absListener);
    web.window.removeEventListener('deviceorientation', _relListener);
    _out.close();
  }
}
