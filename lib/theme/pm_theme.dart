import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pm_colors.dart';
import 'pm_text.dart';

/// Builds the two Material themes from the PolyMap tokens.
///
/// Material widgets are kept to a minimum in the UI (the design has its own
/// component set), but Scaffold, TextField, InkWell etc. still read from here.
abstract final class PmTheme {
  static ThemeData light() => _build(PmColors.light, Brightness.light);
  static ThemeData dark() => _build(PmColors.dark, Brightness.dark);

  static ThemeData _build(PmColors pm, Brightness brightness) {
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: pm.blue,
        onPrimary: pm.onBlue,
        secondary: pm.brown,
        onSecondary: PmFixed.white,
        tertiary: pm.ochre,
        onTertiary: PmFixed.onOchre,
        error: pm.brown,
        onError: PmFixed.white,
        surface: pm.surf,
        onSurface: pm.ink,
        outline: pm.line,
      ),
      scaffoldBackgroundColor: pm.bg,
      fontFamily: PmFonts.sans,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[pm],
    );

    final body = PmText.body(color: pm.ink);
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: PmFonts.sans,
        bodyColor: pm.ink,
        displayColor: pm.ink,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: pm.blue,
        selectionColor: pm.blue.withValues(alpha: 0.25),
        selectionHandleColor: pm.blue,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        hintStyle: body.copyWith(color: pm.ink2),
      ),
      dividerColor: pm.line,
      appBarTheme: AppBarTheme(
        backgroundColor: pm.bg,
        foregroundColor: pm.ink,
        elevation: 0,
        systemOverlayStyle:
            pm.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
