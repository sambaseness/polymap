import 'package:flutter/material.dart';

import '../../theme/pm_colors.dart';
import '../../theme/pm_text.dart';

/// « Superpositions AR » — shared overlay pieces on top of the camera feed.
/// Text over camera always sits on an opaque veil (hard rule n° 3).

/// Dark glass panel: `rgba(10,16,22,.7)` + 1 px 14 % white hairline.
class ArGlass extends StatelessWidget {
  const ArGlass({
    super.key,
    required this.child,
    this.radius = 16,
    this.alpha = 0.7,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.onTap,
  });

  final Widget child;
  final double radius;
  final double alpha;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PmFixed.arVeil.withValues(alpha: alpha),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: PmFixed.white.withValues(alpha: 0.14)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// « Vue 2D » pill — the always-visible exit from the camera (hard rule n° 5).
class ArExitButton extends StatelessWidget {
  const ArExitButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Revenir à la vue 2D',
        child: ArGlass(
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          onTap: onTap,
          child: Text('Vue 2D', style: PmText.sans(12.5, weight: FontWeight.w600, color: PmFixed.white)),
        ),
      );

}

/// Door label: tinted pill with a small ochre dot — « C-104 · Bureau ».
class ArDoorLabel extends StatelessWidget {
  const ArDoorLabel({super.key, required this.text, required this.color, this.dot = PmFixed.brandOchre});
  final String text;
  final Color color;
  final Color dot;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(text, style: PmText.sans(12, weight: FontWeight.w600, color: PmFixed.white)),
          ],
        ),
      );
}

/// « Prochain virage » card: mono label, big figure + direction, ETA line.
class ArNextTurnCard extends StatelessWidget {
  const ArNextTurnCard({
    super.key,
    required this.distance,
    required this.direction,
    required this.eta,
  });

  final String distance;
  final String direction;
  final String eta;

  @override
  Widget build(BuildContext context) => ArGlass(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('PROCHAIN VIRAGE',
                style: PmText.mono(9.5, color: PmFixed.white.withValues(alpha: .55), ls: 0.16)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(distance, style: PmText.navFigure(color: PmFixed.white)),
                const SizedBox(width: 10),
                Text(direction, style: PmText.sans(13, color: PmFixed.white.withValues(alpha: .7))),
              ],
            ),
            const SizedBox(height: 6),
            Text(eta, style: PmText.sans(12.5, color: PmFixed.white.withValues(alpha: .75))),
          ],
        ),
      );
}
