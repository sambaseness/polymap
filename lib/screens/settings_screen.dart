import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation.dart';
import '../state/app_state.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_layout.dart';
import '../theme/pm_text.dart';
import '../widgets/pm_cards.dart';
import '../widgets/pm_primitives.dart';
import 'offline_screen.dart';

/// 22 — Réglages. Theme, language, accessibility and AR options.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    final state = context.watch<AppState>();

    final toggles = <(String, String, bool, ValueChanged<bool>)>[
      ('Éviter les escaliers', 'Privilégie rampes et ascenseurs', state.avoidStairs, (v) => state.setPref(() => state.avoidStairs = v)),
      ('Étiquettes AR sur les portes', 'Affiche le code des salles en réalité augmentée', state.arDoorLabels, (v) => state.setPref(() => state.arDoorLabels = v)),
      ('Guidage vocal', 'Annonce les virages à voix haute', state.voiceGuidance, (v) => state.setPref(() => state.voiceGuidance = v)),
      ('Contraste élevé', 'Renforce le tracé et les textes', state.highContrast, (v) => state.setPref(() => state.highContrast = v)),
    ];

    return Scaffold(
      body: PmPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: pad.top + 14),
            const PmScreenHeader(title: 'Réglages'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(22, 0, 22, pad.bottom + 16),
                children: <Widget>[
                  const PmSectionLabel('Apparence'),
                  PmCard(
                    padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Thème', style: PmText.label(color: pm.ink)),
                        const SizedBox(height: 10),
                        PmSegmented<ThemeMode>(
                          values: const <ThemeMode>[ThemeMode.light, ThemeMode.dark, ThemeMode.system],
                          selected: state.themeMode,
                          labelOf: (m) => switch (m) {
                            ThemeMode.light => 'Clair',
                            ThemeMode.dark => 'Sombre',
                            ThemeMode.system => 'Système',
                          },
                          onChanged: (m) => state.themeMode = m,
                          gap: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const PmSectionLabel('Langue'),
                  PmCard(
                    padding: EdgeInsets.zero,
                    clip: true,
                    child: Column(
                      children: <Widget>[
                        for (final l in const <String>['Français', 'English', 'Wolof (bientôt)'])
                          InkWell(
                            onTap: l.contains('bientôt') ? null : () => state.language = l,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: pm.line))),
                              child: Row(
                                children: <Widget>[
                                  Expanded(child: Text(l, style: PmText.sans(14, color: pm.ink))),
                                  PmRadioDot(selected: state.language == l),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const PmSectionLabel('Accessibilité & AR'),
                  PmCard(
                    padding: EdgeInsets.zero,
                    clip: true,
                    child: Column(
                      children: <Widget>[
                        for (final (label, hint, on, set) in toggles)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: pm.line))),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(label, style: PmText.sans(14, weight: FontWeight.w500, color: pm.ink)),
                                      const SizedBox(height: 2),
                                      Text(hint, style: PmText.sans(11.5, color: pm.ink2)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                PmToggle(value: on, onChanged: set),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PmTile(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                    onTap: () => PmNav.push<void>(context, const OfflineScreen()),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text('Carte hors-ligne', style: PmText.sans(14, weight: FontWeight.w500, color: pm.ink))),
                        Text('28 Mo · à jour', style: PmText.mono(11.5, color: pm.ink2)),
                      ],
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
