
import 'package:flutter/material.dart';

/// Section 03 « Typographie » — three families, three roles.
///
/// * Space Grotesk — titles and navigation figures.
/// * IBM Plex Sans — everything else.
/// * IBM Plex Mono — room codes, distances, technical labels.
///
/// The three builders take CSS-like arguments so screens can be transcribed
/// from the design source almost verbatim: `size` in logical px, `ls` as
/// letter-spacing in *em*, `height` as unitless line-height.
abstract final class PmFonts {
  static const String grotesk = 'Space Grotesk';
  static const String sans = 'IBM Plex Sans';
  static const String mono = 'IBM Plex Mono';
}

abstract final class PmText {
  static TextStyle grotesk(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color? color,
    double ls = 0,
    double? height,
  }) =>
      _style(PmFonts.grotesk, size, weight, color, ls, height);

  static TextStyle sans(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double ls = 0,
    double? height,
  }) =>
      _style(PmFonts.sans, size, weight, color, ls, height);

  static TextStyle mono(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double ls = 0,
    double? height,
  }) =>
      _style(PmFonts.mono, size, weight, color, ls, height);

  // ---- Named presets from the type-scale table --------------------------

  /// `display` — Space Grotesk 700 · 34/1.1 · -0.025em
  static TextStyle display({Color? color}) =>
      grotesk(34, weight: FontWeight.w700, color: color, ls: -0.025, height: 1.1);

  /// `nav-figure` — Space Grotesk 700 · 30
  static TextStyle navFigure({Color? color}) =>
      grotesk(30, weight: FontWeight.w700, color: color, height: 1);

  /// `title` — Space Grotesk 600 · 21
  static TextStyle title({Color? color}) => grotesk(21, color: color);

  /// `body` — IBM Plex Sans 400 · 14.5/1.55
  static TextStyle body({Color? color}) => sans(14.5, color: color, height: 1.55);

  /// `label` — IBM Plex Sans 600 · 14
  static TextStyle label({Color? color}) =>
      sans(14, weight: FontWeight.w600, color: color);

  /// `caption` — IBM Plex Sans 400 · 12.5
  static TextStyle caption({Color? color}) => sans(12.5, color: color);

  /// `mono-meta` — IBM Plex Mono 500 · 10 · .16em caps.
  /// Callers pass the string already upper-cased (see [PmSectionLabel]).
  static TextStyle monoMeta({Color? color, double size = 10, double ls = 0.16}) =>
      mono(size, weight: FontWeight.w500, color: color, ls: ls);

  /// `mono-data` — IBM Plex Mono 400 · 11.5
  static TextStyle monoData({Color? color, double size = 11.5}) =>
      mono(size, color: color);

  static TextStyle _style(
    String family,
    double size,
    FontWeight weight,
    Color? color,
    double ls,
    double? height,
  ) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      // Variable fonts need the axis set explicitly; static fonts ignore it.
      fontVariations: <FontVariation>[
        FontVariation('wght', _weightValue(weight)),
      ],
      color: color,
      letterSpacing: ls == 0 ? null : ls * size,
      height: height,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  static double _weightValue(FontWeight w) => switch (w) {
        FontWeight.w100 => 100,
        FontWeight.w200 => 200,
        FontWeight.w300 => 300,
        FontWeight.w400 => 400,
        FontWeight.w500 => 500,
        FontWeight.w600 => 600,
        FontWeight.w700 => 700,
        FontWeight.w800 => 800,
        FontWeight.w900 => 900,
        _ => 400,
      };
}
