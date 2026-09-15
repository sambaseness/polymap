import 'package:flutter/material.dart';

/// Colour tokens — section 02 « Couleur » of the PolyMap Design System.
///
/// Two themes share the same token names (`--pm-*` in the design source).
/// Rule from the design: blue is never a building, brown is never a path.
@immutable
class PmColors extends ThemeExtension<PmColors> {
  const PmColors({
    required this.blue,
    required this.blueDeep,
    required this.brown,
    required this.ochre,
    required this.bg,
    required this.surf,
    required this.surf2,
    required this.ink,
    required this.ink2,
    required this.line,
    required this.map,
    required this.bldg,
    required this.bldgInk,
    required this.green,
    required this.onBlue,
    required this.shadow,
    required this.isDark,
  });

  /// `--pm-blue` — the path, the position, the primary action.
  final Color blue;

  /// `--pm-blue-d` — splash background, header band.
  final Color blueDeep;

  /// `--pm-brown` — places: buildings, pavilions, start point, AR mode.
  final Color brown;

  /// `--pm-ochre` — anything asking for a decision: stairs, offline, favourites.
  final Color ochre;

  final Color bg;
  final Color surf;
  final Color surf2;
  final Color ink;
  final Color ink2;
  final Color line;
  final Color map;
  final Color bldg;
  final Color bldgInk;
  final Color green;

  /// Text/icon colour on top of [blue].
  final Color onBlue;

  /// Base colour for elevation shadows (already carries its alpha).
  final Color shadow;

  final bool isDark;

  static const PmColors light = PmColors(
    blue: Color(0xFF1479C9),
    blueDeep: Color(0xFF0B4C82),
    brown: Color(0xFF7A4A1E),
    ochre: Color(0xFFD9A03C),
    bg: Color(0xFFF5F1EA),
    surf: Color(0xFFFFFFFF),
    surf2: Color(0xFFEDE7DD),
    ink: Color(0xFF15202B),
    ink2: Color(0xFF5F6B77),
    line: Color(0xFFDED5C6),
    map: Color(0xFFEDE8DE),
    bldg: Color(0xFFD9CEBC),
    bldgInk: Color(0xFF4A3B29),
    green: Color(0xFFA9C9A1),
    onBlue: Color(0xFFFFFFFF),
    shadow: Color(0x290A1E32), // rgba(10,30,50,.16)
    isDark: false,
  );

  static const PmColors dark = PmColors(
    blue: Color(0xFF4FA8E8),
    blueDeep: Color(0xFF8CC8F2),
    brown: Color(0xFFB0754A),
    ochre: Color(0xFFE5B65C),
    bg: Color(0xFF0E141A),
    surf: Color(0xFF18222C),
    surf2: Color(0xFF202C37),
    ink: Color(0xFFE9F0F6),
    ink2: Color(0xFF93A3B2),
    line: Color(0xFF2A3742),
    map: Color(0xFF131C24),
    bldg: Color(0xFF2B3945),
    bldgInk: Color(0xFFC4D1DC),
    green: Color(0xFF2E4A3B),
    onBlue: Color(0xFF08131D),
    shadow: Color(0x80000000), // rgba(0,0,0,.5)
    isDark: true,
  );

  @override
  PmColors copyWith({
    Color? blue,
    Color? blueDeep,
    Color? brown,
    Color? ochre,
    Color? bg,
    Color? surf,
    Color? surf2,
    Color? ink,
    Color? ink2,
    Color? line,
    Color? map,
    Color? bldg,
    Color? bldgInk,
    Color? green,
    Color? onBlue,
    Color? shadow,
    bool? isDark,
  }) {
    return PmColors(
      blue: blue ?? this.blue,
      blueDeep: blueDeep ?? this.blueDeep,
      brown: brown ?? this.brown,
      ochre: ochre ?? this.ochre,
      bg: bg ?? this.bg,
      surf: surf ?? this.surf,
      surf2: surf2 ?? this.surf2,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      line: line ?? this.line,
      map: map ?? this.map,
      bldg: bldg ?? this.bldg,
      bldgInk: bldgInk ?? this.bldgInk,
      green: green ?? this.green,
      onBlue: onBlue ?? this.onBlue,
      shadow: shadow ?? this.shadow,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  PmColors lerp(ThemeExtension<PmColors>? other, double t) {
    if (other is! PmColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return PmColors(
      blue: l(blue, other.blue),
      blueDeep: l(blueDeep, other.blueDeep),
      brown: l(brown, other.brown),
      ochre: l(ochre, other.ochre),
      bg: l(bg, other.bg),
      surf: l(surf, other.surf),
      surf2: l(surf2, other.surf2),
      ink: l(ink, other.ink),
      ink2: l(ink2, other.ink2),
      line: l(line, other.line),
      map: l(map, other.map),
      bldg: l(bldg, other.bldg),
      bldgInk: l(bldgInk, other.bldgInk),
      green: l(green, other.green),
      onBlue: l(onBlue, other.onBlue),
      shadow: l(shadow, other.shadow),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// Colours that do not change with the theme: brand ink on ochre/green,
/// and the AR/camera surfaces which always sit on a dark video feed.
abstract final class PmFixed {
  static const Color brandBlue = Color(0xFF1479C9);
  static const Color brandBlueDeep = Color(0xFF0B4C82);
  static const Color brandBrown = Color(0xFF7A4A1E);
  static const Color brandOchre = Color(0xFFD9A03C);
  static const Color ochreLight = Color(0xFFE5B65C);

  /// Ink on ochre surfaces (#241704).
  static const Color onOchre = Color(0xFF241704);

  /// Ink on the green « Libre » badge (#17301F).
  static const Color onGreen = Color(0xFF17301F);

  /// Disabled button text (#A79A87).
  static const Color disabledInk = Color(0xFFA79A87);

  static const Color white = Color(0xFFFFFFFF);

  // AR / camera screens
  static const Color arBg = Color(0xFF0A0D10);
  static const Color arVeil = Color(0xFF0A1016); // rgba(10,16,22,·) base
  static const Color arMinimapBg = Color(0xFF10171E);
  static const Color arMinimapBldg = Color(0xFF26333E);
  static const Color arMinimapBlue = Color(0xFF4FA8E8);
}

extension PmColorsContext on BuildContext {
  /// Shortcut: `context.pm.blue`.
  PmColors get pm => Theme.of(this).extension<PmColors>()!;
}
