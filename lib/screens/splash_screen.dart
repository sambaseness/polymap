import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../navigation.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import '../widgets/pm_logo.dart';
import 'onboarding_screen.dart';

/// 01 — Écran de lancement. Brand on deep blue, AR landmarks loading.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), _next);
  }

  void _next() {
    _timer?.cancel();
    if (!mounted) return;
    PmNav.replace<void>(context, const OnboardingScreen());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: PmFixed.brandBlueDeep,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _next,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const PmLogo(size: 112, color: PmFixed.white),
                  const SizedBox(height: 26),
                  Text(
                    'PolyMap',
                    style: PmText.grotesk(42,
                        weight: FontWeight.w700,
                        color: PmFixed.white,
                        ls: -0.03),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ESP · DAKAR',
                    style: PmText.mono(10.5,
                        color: PmFixed.white.withValues(alpha: 0.62), ls: 0.24),
                  ),
                ],
              ),
              Positioned(
                bottom: 64 + MediaQuery.paddingOf(context).bottom,
                child: RotationTransition(
                  turns: _spin,
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CustomPaint(painter: _SpinnerPainter()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2.5 px ring, 22 % white, with an ochre top arc.
class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.25);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = PmFixed.white.withValues(alpha: 0.22);
    canvas.drawOval(rect, base);
    canvas.drawArc(
        rect, -2.356, 1.571, false, base..color = PmFixed.brandOchre);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) => false;
}
