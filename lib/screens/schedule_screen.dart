import 'package:flutter/material.dart';

import '../data/campus_data.dart';
import '../navigation.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_layout.dart';
import '../theme/pm_text.dart';
import '../widgets/pm_cards.dart';
import '../widgets/pm_primitives.dart';

/// 20 — Emploi du temps. DUT1 week with walking time per course.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _day = 1;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      body: PmPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: pad.top + 14),
            const PmScreenHeader(title: 'Emploi du temps', subtitle: 'DUT1 Télécoms & Réseaux · S3',
                padding: EdgeInsets.fromLTRB(22, 4, 22, 16)),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
              child: PmSegmented<int>(
                values: List<int>.generate(CampusData.weekDays.length, (i) => i),
                selected: _day,
                labelOf: (i) => CampusData.weekDays[i],
                onChanged: (i) => setState(() => _day = i),
                outlined: false,
                gap: 6,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(22, 0, 22, pad.bottom + 16),
                children: <Widget>[
                  for (final c in CampusData.week)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(
                              width: 52,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(c.hour, style: PmText.mono(13, weight: FontWeight.w500, color: pm.ink)),
                                  Text(c.duration, style: PmText.mono(10.5, color: pm.ink2)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              width: 4,
                              decoration: BoxDecoration(color: tintColor(pm, c.tint), borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: PmCard(
                                padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                                onTap: () => PmNav.openRoute(context, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(c.title, style: PmText.label(color: pm.ink)),
                                    const SizedBox(height: 2),
                                    Text(c.room, style: PmText.sans(12, color: pm.ink2)),
                                    const SizedBox(height: 9),
                                    Row(
                                      children: <Widget>[
                                        Container(width: 7, height: 7, decoration: BoxDecoration(color: pm.blue, shape: BoxShape.circle)),
                                        const SizedBox(width: 7),
                                        Text(c.walk, style: PmText.mono(11, color: pm.blue)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
