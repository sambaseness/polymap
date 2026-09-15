import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The design draws its icons with plain CSS shapes (rotated bordered boxes,
/// circles, diamonds). Reproduced here so the app has no icon-font dependency
/// and matches the prototype exactly.

/// A « › » / « ‹ » / « ˄ » chevron made of two borders on a rotated square.
class Chevron extends StatelessWidget {
  const Chevron({
    super.key,
    required this.color,
    this.size = 10,
    this.thickness = 2,
    this.direction = AxisDirection.right,
  });

  final Color color;
  final double size;
  final double thickness;
  final AxisDirection direction;

  @override
  Widget build(BuildContext context) {
    // Base shape: right+top borders rotated 45° points to the right.
    final angle = switch (direction) {
      AxisDirection.right => math.pi / 4,
      AxisDirection.down => 3 * math.pi / 4,
      AxisDirection.left => 5 * math.pi / 4,
      AxisDirection.up => -math.pi / 4,
    };
    final side = BorderSide(color: color, width: thickness);
    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border(right: side, top: side)),
        ),
      ),
    );
  }
}

/// Filled or outlined circle.
class CircleGlyph extends StatelessWidget {
  const CircleGlyph({
    super.key,
    required this.color,
    this.size = 16,
    this.filled = false,
    this.stroke = 2,
  });

  final Color color;
  final double size;
  final bool filled;
  final double stroke;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : null,
            border: filled ? null : Border.all(color: color, width: stroke),
          ),
        ),
      );
}

/// Rounded square (map tab, QR glyph, camera body…).
class SquareGlyph extends StatelessWidget {
  const SquareGlyph({
    super.key,
    required this.color,
    this.width = 16,
    this.height = 16,
    this.radius = 4,
    this.filled = false,
    this.stroke = 2,
  });

  final Color color;
  final double width;
  final double height;
  final double radius;
  final bool filled;
  final double stroke;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: filled ? color : null,
            border: filled ? null : Border.all(color: color, width: stroke),
          ),
        ),
      );
}

/// Diamond (favourites): a small rounded square rotated 45°.
class DiamondGlyph extends StatelessWidget {
  const DiamondGlyph({
    super.key,
    required this.color,
    this.size = 14,
    this.radius = 3,
    this.filled = true,
    this.stroke = 2,
  });

  final Color color;
  final double size;
  final double radius;
  final bool filled;
  final double stroke;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: math.pi / 4,
        child: SquareGlyph(
          color: color,
          width: size,
          height: size,
          radius: radius,
          filled: filled,
          stroke: stroke,
        ),
      );
}

/// Three shrinking bars — the « stairs » glyph on ochre banners.
class StairsGlyph extends StatelessWidget {
  const StairsGlyph({
    super.key,
    required this.color,
    this.widths = const <double>[20, 15, 10],
    this.thickness = 3,
    this.gap = 2.5,
  });

  final Color color;
  final List<double> widths;
  final double thickness;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (var i = 0; i < widths.length; i++) ...<Widget>[
            if (i > 0) SizedBox(height: gap),
            Container(
              width: widths[i],
              height: thickness,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      );
}

/// The big navigation arrow: a thick right+top border rotated -45° (points up).
class NavArrow extends StatelessWidget {
  const NavArrow({
    super.key,
    required this.color,
    this.size = 26,
    this.thickness = 7,
    this.radius = 3,
    this.glow = false,
  });

  final Color color;
  final double size;
  final double thickness;
  final double radius;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: color, width: thickness);
    return Transform.rotate(
      angle: -math.pi / 4,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(right: side, top: side),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: glow
              ? <BoxShadow>[
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    offset: const Offset(0, 12),
                    blurRadius: 40,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

/// « × » close glyph as text, sized to the design.
class CrossGlyph extends StatelessWidget {
  const CrossGlyph({super.key, required this.color, this.size = 16});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
        '×',
        style: TextStyle(color: color, fontSize: size, height: 1),
      );
}
