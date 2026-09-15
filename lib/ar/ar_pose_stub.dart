import 'ar_pose.dart';

/// Platforms without sensors (tests, unsupported targets): never emits, so
/// the controller falls back to drag-to-look.
ArPoseSource createPoseSource() => _NoSensors();

class _NoSensors extends ArPoseSource {
  @override
  Stream<ArPose> get poses => const Stream<ArPose>.empty();
}
