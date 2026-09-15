import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../navigation.dart';
import '../../theme/pm_colors.dart';
import '../../theme/pm_text.dart';
import '../../widgets/camera_backdrop.dart';
import '../../widgets/glyphs.dart';
import '../../widgets/pm_button.dart';
import '../arrival_screen.dart';
import 'ar_widgets.dart';

/// 17 — AR : changement d'étage. Stairs, step count, level selector.
class ArFloorScreen extends StatelessWidget {
  const ArFloorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final h = MediaQuery.sizeOf(context).height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: PmFixed.arBg,
        body: CameraBackdrop(
          stripeAngleDeg: 88,
          stripeWidth: 30,
          veil: const <double>[0.78, 0.1, 0.1, 0.92],
          veilStops: const <double>[0, 0.38, 0.6, 1],
          child: Stack(
            children: <Widget>[
              // Three fading « up » arrows.
              Positioned(
                left: 0,
                right: 0,
                top: h * 0.36,
                child: Column(
                  children: <Widget>[
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: i == 0 ? 10 : 2),
                        child: SizedBox(
                          width: 46.0 - i * 10,
                          height: 46.0 - i * 10,
                          child: NavArrow(
                            color: PmFixed.brandBlue.withValues(alpha: 0.95 - i * 0.28),
                            size: 46.0 - i * 10,
                            thickness: 13.0 - i * 3,
                            radius: 4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                top: pad.top + 22,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  decoration: BoxDecoration(
                    color: PmFixed.brandOchre.withValues(alpha: .96),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("CHANGEMENT D'ÉTAGE",
                          style: PmText.mono(9.5, color: PmFixed.onOchre.withValues(alpha: .7), ls: 0.16)),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const StairsGlyph(color: PmFixed.onOchre, widths: <double>[26, 20, 14], thickness: 4, gap: 3),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Escalier B',
                                  style: PmText.grotesk(25, weight: FontWeight.w700, color: PmFixed.onOchre, height: 1.05)),
                              const SizedBox(height: 2),
                              Text('RDC → 1er étage · 22 marches',
                                  style: PmText.sans(13.5, color: PmFixed.onOchre.withValues(alpha: .82))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: pad.bottom + 176,
                child: Center(
                  child: ArGlass(
                    radius: 999,
                    alpha: .78,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('RDC', style: PmText.mono(11, color: PmFixed.white.withValues(alpha: .5))),
                        _Tick(alpha: .3),
                        Text('R+1', style: PmText.mono(13, weight: FontWeight.w500, color: PmFixed.brandOchre)),
                        _Tick(alpha: .14),
                        Text('R+2', style: PmText.mono(11, color: PmFixed.white.withValues(alpha: .3))),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: pad.bottom + 82,
                child: ArGlass(
                  radius: 15,
                  alpha: .72,
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Ensuite : 2e porte à gauche',
                          style: PmText.sans(13.5, weight: FontWeight.w600, color: PmFixed.white)),
                      const SizedBox(height: 3),
                      Text("Salle C-107 · à 34 m après l'escalier",
                          style: PmText.sans(12.5, color: PmFixed.white.withValues(alpha: .62))),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: pad.bottom + 12,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: PmButton(
                        label: 'Retour au couloir',
                        variant: PmButtonVariant.glass,
                        height: 52,
                        fontSize: 15,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PmButton(
                        label: 'Étage atteint',
                        variant: PmButtonVariant.brand,
                        onTap: () => PmNav.push<void>(context, const ArrivalScreen()),
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

class _Tick extends StatelessWidget {
  const _Tick({required this.alpha});
  final double alpha;

  @override
  Widget build(BuildContext context) => Container(
        width: 26,
        height: 1.5,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: PmFixed.white.withValues(alpha: alpha),
      );
}
