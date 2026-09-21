import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../navigation.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import '../widgets/camera_backdrop.dart';
import '../widgets/pm_button.dart';
import '../widgets/pm_primitives.dart';
import 'building_screen.dart';

/// 04 — Localisation par QR. Indoor re-localisation where GPS fails.
///
/// Decoding is not wired yet (it belongs with the AR/indoor positioning
/// decision) — the manual-entry path is the working one.
class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 720;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: PmFixed.arBg,
        body: CameraBackdrop(
          stripeAngleDeg: 96,
          stripeWidth: 26,
          veil: const <double>[0.8, 0.15, 0.15, 0.9],
          veilStops: const <double>[0, 0.3, 0.66, 1],
          child: Stack(
            children: <Widget>[
              Align(
                alignment: const Alignment(0, -0.2),
                child: SizedBox(
                    width: 214,
                    height: 214,
                    child: CustomPaint(painter: _ViewfinderPainter())),
              ),
              Positioned(
                left: 24,
                top: pad.top + 20,
                child: Row(
                  children: <Widget>[
                    PmBackButton(
                      size: 36,
                      color: PmFixed.white,
                      background: PmFixed.white.withValues(alpha: 0.12),
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Text('Me localiser',
                        style: PmText.grotesk(18, color: PmFixed.white)),
                  ],
                ),
              ),
              Positioned(
                left: wide ? (width - 440) / 2 : 24,
                right: wide ? null : 24,
                width: wide ? 440 : null,
                bottom: pad.bottom + 20,
                child: Column(
                  children: <Widget>[
                    Text('Scannez le QR code de la porte',
                        style: PmText.sans(15,
                            weight: FontWeight.w600, color: PmFixed.white)),
                    const SizedBox(height: 8),
                    Text(
                      "Chaque entrée de bâtiment porte un code. Utile à l'intérieur, là où le GPS est imprécis.",
                      textAlign: TextAlign.center,
                      style: PmText.sans(13,
                          color: PmFixed.white.withValues(alpha: 0.66),
                          height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    PmButton(
                      label: 'Saisir le code manuellement',
                      variant: PmButtonVariant.glass,
                      onTap: () =>
                          PmNav.pushInShell(context, const BuildingScreen()),
                    ),
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

/// Four blue corner brackets + a glowing ochre scan line.
class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const len = 44.0, r = 14.0;
    final p = Paint()
      ..color = PmFixed.brandBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final w = size.width, h = size.height;
    void corner(Path path) => canvas.drawPath(path, p);
    corner(Path()
      ..moveTo(0, len)
      ..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..lineTo(len, 0));
    corner(Path()
      ..moveTo(w - len, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
      ..lineTo(w, len));
    corner(Path()
      ..moveTo(w, h - len)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: const Radius.circular(r))
      ..lineTo(w - len, h));
    corner(Path()
      ..moveTo(len, h)
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: const Radius.circular(r))
      ..lineTo(0, h - len));

    final line = Rect.fromLTWH(w * .1, h / 2 - 1, w * .8, 2);
    canvas.drawRect(
        line,
        Paint()
          ..color = PmFixed.brandOchre
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
    canvas.drawRect(line, Paint()..color = PmFixed.brandOchre);
  }

  @override
  bool shouldRepaint(_ViewfinderPainter oldDelegate) => false;
}
