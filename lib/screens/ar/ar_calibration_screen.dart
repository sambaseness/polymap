import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../navigation.dart';
import '../../theme/pm_colors.dart';
import '../../theme/pm_text.dart';
import '../../widgets/camera_backdrop.dart';
import '../../widgets/pm_button.dart';
import 'ar_navigation_screen.dart';
import 'ar_widgets.dart';

/// 15 — AR : calibrage. Scan the scene before placing the arrow.
///
/// The progress here is simulated. With a real engine it would be driven by
/// tracking-quality / localisation confidence (see docs/AR_APPROACH.md).
class ArCalibrationScreen extends StatefulWidget {
  const ArCalibrationScreen({super.key});

  @override
  State<ArCalibrationScreen> createState() => _ArCalibrationScreenState();
}

class _ArCalibrationScreenState extends State<ArCalibrationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();
  Timer? _tick;
  double _progress = 0.62;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 350), (_) {
      if (_progress >= 1) return;
      setState(() => _progress = math.min(1, _progress + 0.03));
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _spin.dispose();
    super.dispose();
  }

  void _done() => PmNav.replace<void>(context, const ArNavigationScreen());

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final pct = (_progress * 100).round();
    final segments = (_progress * 3).ceil().clamp(0, 3);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: PmFixed.arBg,
        body: CameraBackdrop(
          veil: const <double>[0.7, 0.2, 0.2, 0.9],
          veilStops: const <double>[0, 0.4, 0.6, 1],
          child: Stack(
            children: <Widget>[
              Align(
                alignment: const Alignment(0, -0.25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: PmFixed.white.withValues(alpha: .14),
                                  width: 3),
                            ),
                          ),
                          RotationTransition(
                            turns: _spin,
                            child: CustomPaint(
                                size: const Size(120, 120),
                                painter: _ArcPainter()),
                          ),
                          Text('$pct%',
                              style: PmText.grotesk(26,
                                  weight: FontWeight.w700,
                                  color: PmFixed.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (var i = 0; i < 3; i++) ...<Widget>[
                          if (i > 0) const SizedBox(width: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 34,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: i < segments
                                  ? PmFixed.brandBlue
                                  : PmFixed.white.withValues(alpha: .2),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 20,
                top: pad.top + 22,
                child:
                    ArExitButton(onTap: () => Navigator.of(context).maybePop()),
              ),
              Positioned(
                left: wide ? (MediaQuery.sizeOf(context).width - 440) / 2 : 24,
                right: wide ? null : 24,
                width: wide ? 440 : null,
                bottom: pad.bottom + 22,
                child: Column(
                  children: <Widget>[
                    Text('Balayez lentement autour de vous',
                        textAlign: TextAlign.center,
                        style: PmText.grotesk(22, color: PmFixed.white)),
                    const SizedBox(height: 10),
                    Text(
                      'PolyMap reconnaît les repères du couloir pour poser la flèche au bon endroit. Gardez le téléphone à hauteur de poitrine.',
                      textAlign: TextAlign.center,
                      style: PmText.sans(13.5,
                          color: PmFixed.white.withValues(alpha: .66),
                          height: 1.55),
                    ),
                    const SizedBox(height: 22),
                    PmButton(
                        label: "C'est fait",
                        variant: PmButtonVariant.brand,
                        onTap: _done),
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

/// Quarter arc (top + right) of brand blue — the spinning part of the ring.
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      (Offset.zero & size).deflate(1.5),
      -math.pi / 2,
      math.pi / 2,
      false,
      Paint()
        ..color = PmFixed.brandBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => false;
}
