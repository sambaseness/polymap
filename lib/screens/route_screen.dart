import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../navigation.dart';
import '../state/app_state.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import '../theme/pm_tokens.dart';
import '../widgets/campus_map.dart';
import '../widgets/glyphs.dart';
import '../widgets/pm_button.dart';
import '../widgets/pm_cards.dart';
import '../widgets/pm_primitives.dart';
import 'nav2d_screen.dart';

/// 13 — Aperçu itinéraire. Three variants: on foot, accessible, shortest.
class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    final state = context.watch<AppState>();
    final r = state.computedRoute;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CampusMap(roads: MapRoads.two, route: r),
          Positioned(
            top: pad.top + 8,
            left: 16,
            right: 16,
            child: PmCard(
              radius: 16,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              shadow: <BoxShadow>[BoxShadow(color: pm.shadow, offset: const Offset(0, 8), blurRadius: 24)],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      PmBackButton(size: 26, onTap: () => PmNav.toHome(context)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Départ · ${r.route.from}',
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: PmText.sans(11.5, color: pm.ink2)),
                            Text(r.route.to,
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: PmText.grotesk(17, color: pm.ink)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  PmSegmented<RouteMode>(
                    values: RouteMode.values,
                    selected: state.mode,
                    labelOf: (m) => m.label,
                    onChanged: (m) => state.mode = m,
                    radius: 10,
                    verticalPadding: 8,
                    fontSize: 12,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(18, 14, 18, pad.bottom + 12),
              decoration: BoxDecoration(
                color: pm.surf,
                border: Border(top: BorderSide(color: pm.line)),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: PmShadow.sheet(pm),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  PmRouteSummary(minutes: r.minutes, distM: r.distM, steps: r.steps.length),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.34),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        for (var i = 0; i < r.steps.length; i++) PmStepRow(r.steps[i]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PmButton(
                    label: 'Démarrer la navigation',
                    height: 54,
                    fontSize: 16,
                    leading: Chevron(color: pm.onBlue, size: 10, thickness: 2.5, direction: AxisDirection.up),
                    onTap: () => PmNav.push<void>(context, const Nav2dScreen()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
