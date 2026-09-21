import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import '../theme/pm_tokens.dart';
import 'glyphs.dart';

/// Resolve a [PmTint] role to the current theme's colour.
Color tintColor(PmColors pm, PmTint tint) => switch (tint) {
      PmTint.blue => pm.blue,
      PmTint.brown => pm.brown,
      PmTint.ochre => pm.ochre,
      PmTint.line => pm.line,
    };

/// Ink to use on top of a [PmTint] fill.
Color onTintColor(PmColors pm, PmTint tint) => switch (tint) {
      PmTint.blue => pm.onBlue,
      PmTint.brown => PmFixed.white,
      PmTint.ochre => PmFixed.onOchre,
      PmTint.line => pm.ink,
    };

/// A surface card: `background: surf; border: 1px solid line; radius 14/18`.
class PmCard extends StatelessWidget {
  const PmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(PmSpace.lg),
    this.radius = PmRadius.card,
    this.color,
    this.borderColor,
    this.onTap,
    this.shadow,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadow;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor ?? pm.line),
    );
    Widget body = Padding(padding: padding, child: child);
    if (onTap != null) {
      body = InkWell(onTap: onTap, child: body);
    }
    return Container(
      decoration: shadow == null
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: shadow,
            ),
      child: Material(
        color: color ?? pm.surf,
        shape: shape,
        clipBehavior: (onTap != null || clip) ? Clip.antiAlias : Clip.none,
        child: body,
      ),
    );
  }
}

/// Flat tinted tile (`surf2` background, no border) used for quick routes,
/// equipment chips and profile stats.
class PmTile extends StatelessWidget {
  const PmTile({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.radius = PmRadius.card,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Material(
      color: color ?? pm.surf2,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// `mono-meta` — 10 px IBM Plex Mono, .16em tracking, upper-case, ink2.
class PmSectionLabel extends StatelessWidget {
  const PmSectionLabel(
    this.text, {
    super.key,
    this.color,
    this.size = 10,
    this.ls = 0.16,
    this.bottom = 10,
  });

  final String text;
  final Color? color;
  final double size;
  final double ls;
  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Text(
          text.toUpperCase(),
          style: PmText.monoMeta(
              color: color ?? context.pm.ink2, size: size, ls: ls),
        ),
      );
}

/// Pill chip — filters and issue types. `radius 999; 8px 13px; 12px 600`.
class PmChip extends StatelessWidget {
  const PmChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    this.fontSize = 12,
    this.weight = FontWeight.w600,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Material(
      color: selected ? pm.blue : pm.surf,
      shape: RoundedRectangleBorder(
        borderRadius: PmRadius.pill,
        side: BorderSide(color: selected ? pm.blue : pm.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Text(
            label,
            maxLines: 1,
            style: PmText.sans(
              fontSize,
              weight: weight,
              color: selected ? pm.onBlue : pm.ink2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented pills sharing a row (« À pied · Accessible · Court »).
class PmSegmented<T> extends StatelessWidget {
  const PmSegmented({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.radius = PmRadius.segment,
    this.verticalPadding = 9,
    this.fontSize = 12.5,
    this.tint,
    this.outlined = true,
    this.gap = 8,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final double radius;
  final double verticalPadding;
  final double fontSize;
  final Color? tint;

  /// Outlined idle pills (route tabs) vs. filled `surf2` pills (week days).
  final bool outlined;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final on = tint ?? pm.blue;
    return Row(
      children: <Widget>[
        for (var i = 0; i < values.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: _Pill(
              label: labelOf(values[i]),
              selected: values[i] == selected,
              onTap: () => onChanged(values[i]),
              radius: radius,
              verticalPadding: verticalPadding,
              fontSize: fontSize,
              tint: on,
              outlined: outlined,
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.radius,
    required this.verticalPadding,
    required this.fontSize,
    required this.tint,
    required this.outlined,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double radius;
  final double verticalPadding;
  final double fontSize;
  final Color tint;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Material(
      color: selected ? tint : (outlined ? Colors.transparent : pm.surf2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: outlined
            ? BorderSide(color: selected ? tint : pm.line)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Padding(
            padding:
                EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 6),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PmText.sans(
                  fontSize,
                  weight: FontWeight.w600,
                  color: selected ? pm.onBlue : pm.ink2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 44×26 toggle, 20 px knob.
class PmToggle extends StatelessWidget {
  const PmToggle({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 26,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? pm.blue : pm.line,
            borderRadius: PmRadius.pill,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: pm.surf, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}

/// Radio dot for the language list.
class PmRadioDot extends StatelessWidget {
  const PmRadioDot({super.key, required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? pm.blue : pm.line, width: 2),
      ),
      child: selected
          ? Padding(
              padding: const EdgeInsets.all(3),
              child: DecoratedBox(
                decoration:
                    BoxDecoration(color: pm.blue, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}

/// Back chevron in a 30–36 px hit area (always ≥ 44 px effective target).
class PmBackButton extends StatelessWidget {
  const PmBackButton({
    super.key,
    this.onTap,
    this.color,
    this.size = 30,
    this.background,
    this.radius = 12,
  });

  final VoidCallback? onTap;
  final Color? color;
  final double size;
  final Color? background;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Semantics(
      button: true,
      label: 'Retour',
      child: Material(
        color: background ?? Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Chevron(
                color: color ?? pm.ink,
                size: 10,
                direction: AxisDirection.left,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The square mono-code box at the start of place rows (`36×36, r10`).
class PmTagBox extends StatelessWidget {
  const PmTagBox({
    super.key,
    required this.text,
    this.size = 36,
    this.radius = 10,
    this.background,
    this.foreground,
    this.fontSize = 11,
  });

  final String text;
  final double size;
  final double radius;
  final Color? background;
  final Color? foreground;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? pm.surf2,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: PmText.mono(fontSize,
            weight: FontWeight.w500, color: foreground ?? pm.brown),
      ),
    );
  }
}

/// « Libre » / « Occupée » / « Accès fermé » status pill.
enum PmStatus { free, busy, closed }

class PmStatusBadge extends StatelessWidget {
  const PmStatusBadge(this.status, {super.key});
  final PmStatus status;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final (label, bg, fg) = switch (status) {
      PmStatus.free => (
          'Libre',
          pm.green,
          pm.isDark ? pm.ink : PmFixed.onGreen
        ),
      PmStatus.busy => ('Occupée', pm.brown, PmFixed.white),
      PmStatus.closed => ('Accès fermé', pm.ochre, PmFixed.onOchre),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: PmRadius.pill),
      child: Text(label,
          style: PmText.sans(12, weight: FontWeight.w600, color: fg)),
    );
  }
}

/// Horizontal hairline.
class PmDivider extends StatelessWidget {
  const PmDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: context.pm.line);
}
