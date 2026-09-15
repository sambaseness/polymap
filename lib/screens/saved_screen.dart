import 'package:flutter/material.dart';

import '../data/campus_data.dart';
import '../navigation.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import '../widgets/glyphs.dart';
import '../widgets/pm_button.dart';
import '../widgets/pm_cards.dart';
import '../widgets/pm_primitives.dart';
import 'schedule_screen.dart';

/// 19 — Mes lieux. Favourites + today's courses with « Y aller ».
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(22, pad.top + 22, 22, 24),
      children: <Widget>[
        Text('Mes lieux', style: PmText.grotesk(28, weight: FontWeight.w700, color: pm.ink, ls: -0.02)),
        const SizedBox(height: 2),
        Text('Favoris et cours du jour', style: PmText.sans(13, color: pm.ink2)),
        const SizedBox(height: 18),
        for (var i = 0; i < CampusData.favorites.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 8),
          PmPlaceCard(
            code: CampusData.favorites[i].code,
            name: CampusData.favorites[i].name,
            place: CampusData.favorites[i].place,
            trailing: CampusData.favorites[i].dist,
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: DiamondGlyph(color: pm.ochre, size: 14),
            ),
            onTap: () => PmNav.openTarget(context, CampusData.favorites[i].target),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            const Expanded(child: PmSectionLabel('Emploi du temps · mardi', bottom: 0)),
            InkWell(
              onTap: () => PmNav.push<void>(context, const ScheduleScreen()),
              child: Text('Tout voir', style: PmText.sans(12.5, weight: FontWeight.w600, color: pm.blue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < CampusData.todaySchedule.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 8),
          PmTile(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 78,
                  child: Text(CampusData.todaySchedule[i].time, style: PmText.mono(12, color: pm.ink2)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(CampusData.todaySchedule[i].title,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: PmText.sans(13.5, weight: FontWeight.w600, color: pm.ink)),
                      Text(CampusData.todaySchedule[i].room,
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: PmText.sans(11.5, color: pm.ink2)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                PmButton(
                  label: 'Y aller',
                  expand: false,
                  height: 32,
                  radius: 9,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onTap: () => PmNav.openRoute(context, 0),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
