import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import '../theme/pm_tokens.dart';
import 'glyphs.dart';
import 'pm_primitives.dart';

/// « Carte de lieu » — code box, name, location, distance on the right.
class PmPlaceCard extends StatelessWidget {
  const PmPlaceCard({
    super.key,
    required this.code,
    required this.name,
    required this.place,
    this.trailing,
    this.onTap,
    this.leading,
    this.chevron = false,
  });

  final String code;
  final String name;
  final String place;

  /// Right-hand mono text (« 335 m », « 5 min »).
  final String? trailing;
  final VoidCallback? onTap;

  /// Replaces the default [PmTagBox].
  final Widget? leading;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return PmCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: <Widget>[
          leading ?? PmTagBox(text: code),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      PmText.sans(14.5, weight: FontWeight.w600, color: pm.ink),
                ),
                if (place.isNotEmpty)
                  Text(
                    place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PmText.sans(12, color: pm.ink2),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 10),
            Text(trailing!, style: PmText.mono(11, color: pm.ink2)),
          ],
          if (chevron) ...<Widget>[
            const SizedBox(width: 12),
            Chevron(color: pm.ink2, size: 7),
          ],
        ],
      ),
    );
  }
}

/// « Étapes d'itinéraire » row: numbered chip, label, distance.
class PmStepRow extends StatelessWidget {
  const PmStepRow(this.step, {super.key, this.last = false});
  final RouteStep step;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: last ? Colors.transparent : pm.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PmTagBox(
              text: step.n, size: 24, radius: PmRadius.chip, fontSize: 10.5),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(step.label,
                  style: PmText.sans(13.5, color: pm.ink, height: 1.4)),
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(step.dist, style: PmText.mono(11, color: pm.ink2)),
          ),
        ],
      ),
    );
  }
}

/// « 5 min · 335 m · 5 étapes » summary line.
class PmRouteSummary extends StatelessWidget {
  const PmRouteSummary(
      {super.key,
      required this.minutes,
      required this.distM,
      required this.steps});
  final int minutes;
  final int distM;
  final int steps;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Row(
      children: <Widget>[
        Text('$minutes min',
            style: PmText.grotesk(27, weight: FontWeight.w700, color: pm.blue)),
        const SizedBox(width: 14),
        Text('$distM m · $steps étapes',
            style: PmText.mono(12, color: pm.ink2)),
      ],
    );
  }
}

/// Idle search field (« Salle, bâtiment, département… ») — tappable.
class PmSearchPlaceholder extends StatelessWidget {
  const PmSearchPlaceholder(
      {super.key, this.onTap, this.elevated = false, this.height = 48});
  final VoidCallback? onTap;
  final bool elevated;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Semantics(
      button: true,
      label: 'Rechercher un lieu',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PmRadius.card),
          boxShadow: elevated ? PmShadow.floating(pm) : null,
        ),
        child: Material(
          color: pm.surf,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PmRadius.card),
            side: BorderSide(color: pm.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  CircleGlyph(color: pm.ink2, size: 15),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Salle, bâtiment, département…',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PmText.sans(14.5, color: pm.ink2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom tab bar — Carte · Recherche · Favoris · Profil. 76 px + inset.
class PmBottomNav extends StatelessWidget {
  const PmBottomNav({super.key, required this.active, required this.onSelect});

  /// Index of the active tab (0 carte, 1 recherche, 2 favoris, 3 profil).
  final int active;
  final ValueChanged<int> onSelect;

  static const List<String> labels = <String>[
    'Carte',
    'Recherche',
    'Favoris',
    'Profil'
  ];

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final inset = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 76 + inset,
      padding: EdgeInsets.only(top: 12, bottom: inset),
      decoration: BoxDecoration(
        color: pm.surf,
        border: Border(top: BorderSide(color: pm.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (var i = 0; i < labels.length; i++)
            _Tab(i, active == i, onSelect),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(this.index, this.on, this.onSelect);
  final int index;
  final bool on;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final c = on ? pm.blue : pm.ink2;
    final glyph = switch (index) {
      0 => SquareGlyph(color: c, width: 18, height: 18, radius: 5, filled: on),
      1 || 3 => CircleGlyph(color: c, size: 18, filled: on),
      _ => DiamondGlyph(color: c, size: 16, radius: 3, filled: on),
    };
    return Semantics(
      button: true,
      selected: on,
      label: PmBottomNav.labels[index],
      child: InkWell(
        onTap: () => onSelect(index),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 64,
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 18, child: Center(child: glyph)),
              const SizedBox(height: 5),
              Text(
                PmBottomNav.labels[index],
                style: PmText.sans(10.5,
                    weight: on ? FontWeight.w600 : FontWeight.w400, color: c),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen header: back chevron + title (+ subtitle) — used by most stacked screens.
class PmScreenHeader extends StatelessWidget {
  const PmScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.titleSize = 24,
    this.padding = const EdgeInsets.fromLTRB(22, 4, 22, 18),
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final double titleSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          PmBackButton(onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PmText.grotesk(titleSize,
                      weight: FontWeight.w700, color: pm.ink, ls: -0.02),
                ),
                if (subtitle != null)
                  Text(subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PmText.sans(12.5, color: pm.ink2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
