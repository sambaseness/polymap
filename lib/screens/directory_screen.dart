import 'package:flutter/material.dart';

import '../data/campus_data.dart';
import '../navigation.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_layout.dart';
import '../widgets/pm_cards.dart';
import '../widgets/pm_primitives.dart';

/// 10 — Annuaire des bâtiments. Grouped by use: teaching, residences, services.
class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  int _chip = 0;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      body: PmPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: pad.top + 12),
            const PmScreenHeader(
              title: 'Annuaire',
              subtitle: '21 bâtiments · 340 salles référencées',
              padding: EdgeInsets.fromLTRB(18, 4, 18, 14),
            ),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: CampusData.categoryChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 7),
                itemBuilder: (_, i) => PmChip(
                  label: CampusData.categoryChips[i],
                  selected: _chip == i,
                  onTap: () => setState(() => _chip = i),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(18, 0, 18, pad.bottom + 16),
                children: <Widget>[
                  for (final g in CampusData.directory) ...<Widget>[
                    PmSectionLabel(g.title, bottom: 9),
                    for (var i = 0; i < g.items.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(height: 7),
                      PmPlaceCard(
                        code: g.items[i].tag,
                        name: g.items[i].name,
                        place: g.items[i].meta,
                        chevron: true,
                        leading: PmTagBox(
                          text: g.items[i].tag,
                          size: 30,
                          radius: 9,
                          fontSize: 10.5,
                          background: tintColor(pm, g.items[i].tint),
                          foreground: onTintColor(pm, g.items[i].tint),
                        ),
                        onTap: () => PmNav.openBuilding(context),
                      ),
                    ],
                    const SizedBox(height: 18),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
