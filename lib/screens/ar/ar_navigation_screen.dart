import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../navigation.dart';
import '../../theme/pm_colors.dart';
import '../../theme/pm_text.dart';
import '../../widgets/camera_backdrop.dart';
import '../../widgets/glyphs.dart';
import '../../widgets/pm_button.dart';
import '../arrival_screen.dart';
import 'ar_floor_screen.dart';
import 'ar_widgets.dart';

/// 16 — AR : navigation. Floating arrow, distance, door labels, minimap.
///
/// The arrow is screen-anchored (floats at a fixed spot) until an anchoring
/// engine is chosen; door labels are positioned by hand for the same reason.
class ArNavigationScreen extends StatefulWidget {
  const ArNavigationScreen({super.key});

  @override
  State<ArNavigationScreen> createState() => _ArNavigationScreenState();
}

class _ArNavigationScreenState extends State<ArNavigationScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  void _exit() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final h = MediaQuery.sizeOf(context).height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: PmFixed.arBg,
        body: CameraBackdrop(
          child: Stack(
            children: <Widget>[
              // Floating arrow — `pm-float` : translateY 0 → -14 px.
              Positioned(
                left: 0,
                right: 0,
                top: h * 0.34,
                child: AnimatedBuilder(
                  animation: _float,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, -14 * Curves.easeInOut.transform(_float.value)),
                    child: child,
                  ),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        width: 96,
                        height: 96,
                        child: Center(
                          child: NavArrow(color: PmFixed.brandBlue, size: 58, thickness: 16, radius: 6, glow: true),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 78,
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: RadialGradient(
                            colors: <Color>[PmFixed.brandBlue.withValues(alpha: .45), Colors.transparent],
                            stops: const <double>[0, 0.7],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: pad.top + 22,
                child: const ArNextTurnCard(
                  distance: '18 m',
                  direction: 'à droite',
                  eta: 'Arrivée dans 4 min · 210 m restants',
                ),
              ),
              Positioned(right: 20, top: pad.top + 22, child: ArExitButton(onTap: _exit)),
              Positioned(
                left: 26,
                top: h * 0.34 + 20,
                child: ArDoorLabel(text: 'C-104 · Bureau', color: PmFixed.brandBlue.withValues(alpha: .86)),
              ),
              Positioned(
                right: 34,
                top: h * 0.34 + 92,
                child: ArDoorLabel(
                  text: 'C-107 · TD',
                  color: PmFixed.brandBrown.withValues(alpha: .88),
                  dot: PmFixed.ochreLight,
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                top: h * 0.52,
                child: Semantics(
                  button: true,
                  child: Material(
                    color: PmFixed.brandOchre.withValues(alpha: .94),
                    borderRadius: BorderRadius.circular(15),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => PmNav.push<void>(context, const ArFloorScreen()),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
                        child: Row(
                          children: <Widget>[
                            const StairsGlyph(color: PmFixed.onOchre),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Montez au 1er étage',
                                      style: PmText.sans(14, weight: FontWeight.w700, color: PmFixed.onOchre)),
                                  Text('Escalier B, à 18 m — puis 2e porte à gauche',
                                      style: PmText.sans(12.5, color: PmFixed.onOchre.withValues(alpha: .8))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(right: 20, bottom: pad.bottom + 98, child: const _Minimap()),
              Positioned(
                left: 20,
                right: 20,
                bottom: pad.bottom + 12,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: PmButton(
                        label: 'Je suis arrivé',
                        variant: PmButtonVariant.brand,
                        onTap: () => PmNav.push<void>(context, const ArrivalScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 52,
                      child: PmButton(
                        label: '×',
                        variant: PmButtonVariant.glass,
                        height: 52,
                        fontSize: 17,
                        padding: EdgeInsets.zero,
                        onTap: _exit,
                      ),
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

/// 108 px minimap — dark, current floor, remaining path.
class _Minimap extends StatelessWidget {
  const _Minimap();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: PmFixed.arMinimapBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PmFixed.white.withValues(alpha: .18)),
        boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x80000000), offset: Offset(0, 10), blurRadius: 30)],
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: _MinimapPainter())),
          Positioned(
            left: 8,
            bottom: 6,
            child: Text('RDC', style: PmText.mono(8, color: PmFixed.white.withValues(alpha: .5), ls: 0.1)),
          ),
        ],
      ),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    Offset p(double x, double y) => Offset(x / 100 * s.width, y / 100 * s.height);
    canvas.drawRect(Rect.fromLTWH(0, s.height * .4, s.width, 12), Paint()..color = PmFixed.white.withValues(alpha: .07));
    final b = Paint()..color = PmFixed.arMinimapBldg;
    for (final r in const <Rect>[Rect.fromLTWH(14, 18, 26, 22), Rect.fromLTWH(56, 20, 30, 18), Rect.fromLTWH(20, 62, 34, 24)]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromPoints(p(r.left, r.top), p(r.right, r.bottom)), const Radius.circular(3)),
        b,
      );
    }
    final path = Path()..moveTo(p(30, 86).dx, p(30, 86).dy);
    for (final o in const <Offset>[Offset(34, 58), Offset(62, 46), Offset(68, 22)]) {
      path.lineTo(p(o.dx, o.dy).dx, p(o.dx, o.dy).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = PmFixed.arMinimapBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
    final here = p(26, 80) + const Offset(4.5, 4.5);
    canvas.drawCircle(here, 4.5, Paint()..color = PmFixed.arMinimapBlue);
    canvas.drawCircle(here, 3.5, Paint()..color = PmFixed.arMinimapBg..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_MinimapPainter oldDelegate) => false;
}
