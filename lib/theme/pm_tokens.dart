import 'package:flutter/material.dart';

import 'pm_colors.dart';

/// Section 04 « Trame » — spacing, radii, elevation. Base grid of 4 px.
abstract final class PmSpace {
  /// Tight icon/text gap.
  static const double xs = 4;

  /// Between cards in a list.
  static const double sm = 8;

  /// Inside chips.
  static const double md = 12;

  /// Card padding.
  static const double lg = 16;

  /// Screen side margin.
  static const double screen = 22;

  /// Bottom safe zone (in addition to the system inset).
  static const double bottomSafe = 46;
}

abstract final class PmRadius {
  /// Mono chip.
  static const double chip = 8;

  /// Segment pill.
  static const double segment = 11;

  /// Place card.
  static const double card = 14;

  /// Button.
  static const double button = 16;

  /// Bottom sheet.
  static const double sheet = 24;

  /// Large panel (design-system cards, floor plan).
  static const double panel = 18;

  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

abstract final class PmShadow {
  /// « flottant » — floating controls over the map.
  static List<BoxShadow> floating(PmColors pm) => <BoxShadow>[
        BoxShadow(color: pm.shadow, offset: const Offset(0, 6), blurRadius: 18),
      ];

  /// « feuille » — bottom sheets.
  static List<BoxShadow> sheet(PmColors pm) => <BoxShadow>[
        BoxShadow(color: pm.shadow, offset: const Offset(0, -12), blurRadius: 34),
      ];

  /// « AR » — the floating arrow's blue glow (theme-independent).
  static const List<BoxShadow> ar = <BoxShadow>[
    BoxShadow(
      color: Color(0x731479C9), // rgba(20,121,201,.45)
      offset: Offset(0, 12),
      blurRadius: 40,
    ),
  ];
}

/// Minimum touch target — hard rule n° 2 of the design system.
const double kPmTouchTarget = 44;
