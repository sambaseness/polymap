import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/pm_colors.dart';

/// Section 01 « Marque » — the brown pencil crossing the blue silhouette,
/// ochre tip. Drawn with shapes, scaled from the 44 px reference.
///
/// The logo keeps a breathing margin equal to the tip's height; the pencil
/// intentionally overflows the blob on the right, so callers should leave room.
class PmLogo extends StatelessWidget {
  const PmLogo({
    super.key,
    this.size = 44,
    this.body,
    this.pencil,
    this.tip,
  });

  final double size;

  /// Override colours (splash uses the fixed brand colours, « monochrome »
  /// uses a single ink). Defaults to the theme's tokens.
  final Color? body;
  final Color? pencil;
  final Color? tip;

  /// Monochrome variant: one ink for the three parts.
  factory PmLogo.mono({Key? key, double size = 44, required Color ink}) =>
      PmLogo(key: key, size: size, body: ink, pencil: ink, tip: ink);

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final s = size / 44;
    final bodyColor = body ?? pm.blue;
    final pencilColor = pencil ?? pm.brown;
    final tipColor = tip ?? pm.ochre;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Blob: border-radius 50% 50% 46% 54% / 54% 46% 50% 50%
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bodyColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(size * .50, size * .54),
                  topRight: Radius.elliptical(size * .50, size * .46),
                  bottomRight: Radius.elliptical(size * .46, size * .50),
                  bottomLeft: Radius.elliptical(size * .54, size * .50),
                ),
              ),
            ),
          ),
          // Pencil: top 5, right -3, 9×39, radius 4, rotate 38°
          Positioned(
            top: 5 * s,
            right: -3 * s,
            child: Transform.rotate(
              angle: 38 * math.pi / 180,
              child: Container(
                width: 9 * s,
                height: 39 * s,
                decoration: BoxDecoration(
                  color: pencilColor,
                  borderRadius: BorderRadius.circular(4 * s),
                ),
              ),
            ),
          ),
          // Tip: bottom 3, left 16, 9×9, radius 2, rotate 38°
          Positioned(
            bottom: 3 * s,
            left: 16 * s,
            child: Transform.rotate(
              angle: 38 * math.pi / 180,
              child: Container(
                width: 9 * s,
                height: 9 * s,
                decoration: BoxDecoration(
                  color: tipColor,
                  borderRadius: BorderRadius.circular(2 * s),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
