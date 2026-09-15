import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/campus_data.dart';
import '../data/models.dart';
import '../navigation.dart';
import '../state/app_state.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import '../widgets/glyphs.dart';
import '../widgets/pm_button.dart';
import '../widgets/pm_primitives.dart';

/// 12 — Fiche salle. Availability, equipment, next occupations.
class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key, this.code = 'C-107'});
  final String code;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    final fav = context.select<AppState, bool>((s) => s.isFavorite(code));

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(22, pad.top + 20, 22, 22),
            decoration: BoxDecoration(
              color: pm.surf2,
              border: Border(bottom: BorderSide(color: pm.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(padding: EdgeInsets.only(bottom: 14), child: PmBackButton(size: 32)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const PmSectionLabel('Pavillon C · 1er étage', bottom: 6),
                          Text('Salle $code',
                              style: PmText.grotesk(30, weight: FontWeight.w700, color: pm.ink, ls: -0.02)),
                          const SizedBox(height: 2),
                          Text('Salle de travaux dirigés', style: PmText.sans(14, color: pm.ink2)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    const PmStatusBadge(PmStatus.free),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    for (final (i, (k, v)) in const <(String, String)>[('Capacité', '32 places'), ('Étage', 'R+1'), ('Libre', '1h20')].indexed) ...<Widget>[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: PmCard(
                          padding: const EdgeInsets.all(13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              PmSectionLabel(k, size: 9, ls: 0.14, bottom: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(v, maxLines: 1, style: PmText.grotesk(19, color: pm.ink)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                const PmSectionLabel('Équipement', size: 9.5, ls: 0.14, bottom: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: <Widget>[
                    for (final e in CampusData.roomEquipment)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: pm.surf2, borderRadius: BorderRadius.circular(999)),
                        child: Text(e, style: PmText.sans(12.5, weight: FontWeight.w500, color: pm.ink)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                PmCard(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const PmSectionLabel('Prochaines occupations', size: 9.5, ls: 0.14, bottom: 12),
                      for (var i = 0; i < CampusData.todaySchedule.length; i++) ...<Widget>[
                        if (i > 0) const SizedBox(height: 11),
                        OccupationRow(course: CampusData.todaySchedule[i]),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 22, pad.bottom + 12),
            child: Row(
              children: <Widget>[
                Semantics(
                  button: true,
                  label: fav ? 'Retirer des favoris' : 'Ajouter aux favoris',
                  child: Material(
                    color: pm.surf,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: pm.line),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.read<AppState>().toggleFavorite(code),
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: Center(child: DiamondGlyph(color: pm.ochre, size: 14, filled: fav)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PmButton(
                    label: "M'y conduire",
                    radius: 15,
                    onTap: () => PmNav.openRoute(context, 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// « 08h — 10h │ Titre / Qui » row with a tinted 3 px bar.
class OccupationRow extends StatelessWidget {
  const OccupationRow({super.key, required this.course, this.timeWidth = 80});
  final Course course;
  final double timeWidth;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return IntrinsicHeight(
      child: Row(
        children: <Widget>[
          SizedBox(width: timeWidth, child: Text(course.time, style: PmText.mono(12, color: pm.ink2))),
          const SizedBox(width: 13),
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: tintColor(pm, course.tint),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(course.title, style: PmText.sans(13.5, weight: FontWeight.w600, color: pm.ink)),
                Text(course.who, style: PmText.sans(11.5, color: pm.ink2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
