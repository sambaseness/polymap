import 'package:flutter/material.dart';

import '../data/campus_data.dart';
import '../navigation.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import '../widgets/pm_button.dart';
import '../widgets/pm_cards.dart';
import '../widgets/pm_primitives.dart';

/// 23 — Mode hors-ligne. Downloaded packs, warning banner.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(18, pad.top + 14, 18, 18),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(color: pm.ochre, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: <Widget>[
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: PmFixed.onOchre, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Hors connexion', style: PmText.sans(13.5, weight: FontWeight.w700, color: PmFixed.onOchre)),
                      Text('Itinéraires disponibles, horaires non actualisés',
                          style: PmText.sans(12, color: PmFixed.onOchre.withValues(alpha: .82))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const PmScreenHeader(
            title: 'Carte hors-ligne',
            subtitle: 'Campus ESP · dernière mise à jour hier',
            titleSize: 23,
            padding: EdgeInsets.fromLTRB(22, 0, 22, 16),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              children: <Widget>[
                for (var i = 0; i < CampusData.offlinePacks.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: 10),
                  PmCard(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(CampusData.offlinePacks[i].name,
                                  style: PmText.sans(14.5, weight: FontWeight.w600, color: pm.ink)),
                            ),
                            Text(CampusData.offlinePacks[i].size, style: PmText.mono(11.5, color: pm.ink2)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SizedBox(
                            height: 5,
                            child: LinearProgressIndicator(
                              value: CampusData.offlinePacks[i].progress,
                              backgroundColor: pm.surf2,
                              color: CampusData.offlinePacks[i].progress >= 1 ? pm.blue : pm.ochre,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(CampusData.offlinePacks[i].state, style: PmText.sans(12, color: pm.ink2)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(22, 12, 22, pad.bottom + 12),
            child: PmButton(label: 'Utiliser la carte hors-ligne', radius: 15, onTap: () => PmNav.toHome(context)),
          ),
        ],
      ),
    );
  }
}
