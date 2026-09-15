import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/campus_data.dart';
import '../navigation.dart';
import '../state/app_state.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_layout.dart';
import '../theme/pm_text.dart';
import '../widgets/dashed_border.dart';
import '../widgets/pm_button.dart';
import '../widgets/pm_primitives.dart';
import 'report_screen.dart';
import 'room_screen.dart';

/// 18 — Arrivée. Confirmation, room occupation, feedback on the route.
class ArrivalScreen extends StatelessWidget {
  const ArrivalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    final state = context.watch<AppState>();
    const code = '204';
    final fav = state.isFavorite(code);

    return Scaffold(
      body: PmPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(22, pad.top + 28, 22, 28),
              color: pm.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('VOUS ÊTES ARRIVÉ', style: PmText.mono(10, color: pm.onBlue.withValues(alpha: .8), ls: 0.18)),
                  const SizedBox(height: 10),
                  Text('Salle $code', style: PmText.grotesk(32, weight: FontWeight.w700, color: pm.onBlue, ls: -0.02)),
                  const SizedBox(height: 4),
                  Text('Département Génie Informatique · 1er étage',
                      style: PmText.sans(14.5, color: pm.onBlue.withValues(alpha: .9))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: _Stat(label: 'Capacité', value: '40 places')),
                      const SizedBox(width: 10),
                      Expanded(child: _Stat(label: 'Maintenant', value: 'Occupée', color: pm.brown)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  PmCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const PmSectionLabel("Aujourd'hui", size: 9.5, ls: 0.14, bottom: 12),
                        for (var i = 0; i < CampusData.todaySchedule.length; i++) ...<Widget>[
                          if (i > 0) const SizedBox(height: 11),
                          OccupationRow(course: CampusData.todaySchedule[i], timeWidth: 82),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  DashedBorder(
                    color: pm.line,
                    radius: 14,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => PmNav.push<void>(context, const ReportScreen()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                          child: Row(
                            children: <Widget>[
                              Expanded(child: Text('Cet itinéraire était-il juste ?', style: PmText.sans(13, color: pm.ink2))),
                              Text('Donner un avis', style: PmText.sans(13, weight: FontWeight.w600, color: pm.blue)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(22, 0, 22, pad.bottom + 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: PmButton(
                      label: fav ? 'Retirer des favoris' : 'Ajouter aux favoris',
                      variant: PmButtonVariant.secondary,
                      radius: 15,
                      onTap: () => state.toggleFavorite(code),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PmButton(label: 'Terminer', radius: 15, onTap: () => PmNav.toHome(context)),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return PmCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PmSectionLabel(label, size: 9.5, ls: 0.14, bottom: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, maxLines: 1, style: PmText.grotesk(22, color: color ?? pm.ink)),
          ),
        ],
      ),
    );
  }
}
