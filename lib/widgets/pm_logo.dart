import 'package:flutter/material.dart';

import '../theme/pm_colors.dart';

/// Section 01 « Marque » — the PolyMap mark: Africa split in two.
///
/// The asset is a single-colour silhouette on a transparent background, so it
/// is tinted at runtime: brand blue by default, white on deep-blue surfaces,
/// a single ink for the monochrome variant.
///
/// [size] is the box the mark fits into (it is slightly taller than wide).
class PmLogo extends StatelessWidget {
  const PmLogo({super.key, this.size = 44, this.color});

  /// Side of the square box the logo is fitted into.
  final double size;

  /// Tint; defaults to the theme's `--pm-blue`.
  final Color? color;

  /// Monochrome variant: one ink (engraving, stamp, busy photo backgrounds).
  factory PmLogo.mono({Key? key, double size = 44, required Color ink}) =>
      PmLogo(key: key, size: size, color: ink);

  static const String asset = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.pm.blue;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          color: tint,
          colorBlendMode: BlendMode.srcIn,
          filterQuality: FilterQuality.medium,
          semanticLabel: 'PolyMap',
        ),
      ),
    );
  }
}
