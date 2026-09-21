import 'package:flutter/material.dart';

import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import '../theme/pm_tokens.dart';
import 'dashed_border.dart';

enum PmButtonVariant {
  /// Blue — the single main action of a screen, at the bottom, thumb-reachable.
  primary,

  /// Surface with a hairline — secondary action.
  secondary,

  /// Brown — « Mode AR » / camera view.
  ar,

  /// Dashed outline — discreet actions (« Signaler un problème »).
  ghost,

  /// Greyed-out — unavailable route.
  disabled,

  /// No chrome — « Plus tard ».
  text,

  /// Translucent white on camera feeds.
  glass,

  /// Fixed brand blue on camera feeds (ignores theme).
  brand,
}

/// Section 05 — « Boutons ». Full-width by default; height and radius follow
/// the variant unless overridden.
class PmButton extends StatelessWidget {
  const PmButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = PmButtonVariant.primary,
    this.height,
    this.fontSize,
    this.radius,
    this.leading,
    this.expand = true,
    this.padding,
  });

  final String label;
  final VoidCallback? onTap;
  final PmButtonVariant variant;
  final double? height;
  final double? fontSize;
  final double? radius;
  final Widget? leading;
  final bool expand;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final v = variant;

    final double h = height ??
        switch (v) {
          PmButtonVariant.ghost || PmButtonVariant.disabled => 48,
          PmButtonVariant.text => 42,
          PmButtonVariant.glass => 50,
          _ => 52,
        };
    final double r = radius ??
        switch (v) {
          PmButtonVariant.ghost || PmButtonVariant.disabled => 14,
          PmButtonVariant.glass || PmButtonVariant.brand => 15,
          _ => PmRadius.button,
        };
    final double fs = fontSize ??
        switch (v) {
          PmButtonVariant.primary => 15.5,
          PmButtonVariant.ghost || PmButtonVariant.text => 13.5,
          PmButtonVariant.disabled => 14,
          PmButtonVariant.glass => 14.5,
          _ => 15,
        };

    final Color bg = switch (v) {
      PmButtonVariant.primary => pm.blue,
      PmButtonVariant.secondary => pm.surf,
      PmButtonVariant.ar => pm.brown,
      PmButtonVariant.disabled => pm.surf2,
      PmButtonVariant.glass => PmFixed.white.withValues(alpha: 0.1),
      PmButtonVariant.brand => PmFixed.brandBlue,
      _ => Colors.transparent,
    };
    final Color fg = switch (v) {
      PmButtonVariant.primary => pm.onBlue,
      PmButtonVariant.secondary => pm.ink,
      PmButtonVariant.ar ||
      PmButtonVariant.glass ||
      PmButtonVariant.brand =>
        PmFixed.white,
      PmButtonVariant.ghost || PmButtonVariant.text => pm.ink2,
      PmButtonVariant.disabled => PmFixed.disabledInk,
    };
    final BorderSide? border = switch (v) {
      PmButtonVariant.secondary => BorderSide(color: pm.line),
      PmButtonVariant.glass =>
        BorderSide(color: PmFixed.white.withValues(alpha: 0.22)),
      _ => null,
    };
    final weight = v == PmButtonVariant.ghost || v == PmButtonVariant.text
        ? FontWeight.w400
        : FontWeight.w600;

    Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (leading != null) ...<Widget>[
          IconTheme(data: IconThemeData(color: fg), child: leading!),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PmText.sans(fs, weight: weight, color: fg),
          ),
        ),
      ],
    );

    content = Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Center(child: content),
    );

    final enabled = onTap != null && v != PmButtonVariant.disabled;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(r),
      side: border ?? BorderSide.none,
    );

    Widget button = Material(
      color: bg,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        mouseCursor:
            enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: SizedBox(
            height: h, width: expand ? double.infinity : null, child: content),
      ),
    );

    if (v == PmButtonVariant.ghost) {
      button = DashedBorder(color: pm.line, radius: r, child: button);
    }
    return button;
  }
}
