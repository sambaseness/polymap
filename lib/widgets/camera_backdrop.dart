import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/pm_colors.dart';

/// Full-bleed rear-camera feed for the QR and AR screens.
///
/// Falls back to the design's striped « flux caméra » stand-in when no camera
/// is available (simulator, permission refused, web without HTTPS…), so every
/// AR screen still renders. Spatial anchoring is *not* done here — see
/// docs/AR_APPROACH.md.
class CameraBackdrop extends StatefulWidget {
  const CameraBackdrop({
    super.key,
    this.stripeAngleDeg = 102,
    this.stripeWidth = 22,
    this.veil = const <double>[0.72, 0.12, 0.2, 0.88],
    this.veilStops = const <double>[0, 0.34, 0.62, 1],
    this.child,
  });

  /// Stand-in stripes (CSS `repeating-linear-gradient(<angle>, …)`).
  final double stripeAngleDeg;
  final double stripeWidth;

  /// Vertical black veil alphas + stops laid over the feed for legibility.
  final List<double> veil;
  final List<double> veilStops;
  final Widget? child;

  @override
  State<CameraBackdrop> createState() => _CameraBackdropState();
}

class _CameraBackdropState extends State<CameraBackdrop>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw StateError('no camera');
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (e) {
      debugPrint('CameraBackdrop: falling back to stand-in ($e)');
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      c.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _init();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final Widget feed;
    if (c != null && c.value.isInitialized) {
      final size = c.value.previewSize ?? const Size(3, 4);
      // previewSize is landscape on mobile; swap for a portrait cover fit.
      final ratio =
          kIsWeb ? size.width / size.height : size.height / size.width;
      feed = FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: 100 * ratio,
          height: 100,
          child: CameraPreview(c),
        ),
      );
    } else {
      feed = CustomPaint(
        painter: _StripesPainter(widget.stripeAngleDeg, widget.stripeWidth),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const ColoredBox(color: PmFixed.arBg),
        feed,
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                for (final a in widget.veil)
                  const Color(0xFF080C10).withValues(alpha: a),
              ],
              stops: widget.veilStops,
            ),
          ),
        ),
        if (!_failed && c == null)
          const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white24),
            ),
          ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

/// `repeating-linear-gradient(angle, #1B2128 0 w, #161B21 w 2w)`.
class _StripesPainter extends CustomPainter {
  _StripesPainter(this.angleDeg, this.width);
  final double angleDeg;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF161B21));
    final diag = math.sqrt(size.width * size.width + size.height * size.height);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    // CSS: 0deg points up, clockwise. Stripes run perpendicular to the gradient line.
    canvas.rotate((angleDeg - 90) * math.pi / 180);
    final paint = Paint()..color = const Color(0xFF1B2128);
    for (double x = -diag; x < diag; x += width * 2) {
      canvas.drawRect(Rect.fromLTWH(x, -diag, width, diag * 2), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StripesPainter old) =>
      old.angleDeg != angleDeg || old.width != width;
}
