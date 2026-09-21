import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../navigation.dart';
import '../state/app_state.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_layout.dart';
import '../theme/pm_text.dart';
import '../widgets/glyphs.dart';
import '../widgets/pm_primitives.dart';
import 'offline_screen.dart';
import 'report_screen.dart';
import 'schedule_screen.dart';
import 'settings_screen.dart';

/// 21 — Profil. ESP identity, usage stats, access to settings.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    final state = context.watch<AppState>();
    final name = state.isGuest ? 'Visiteur' : _nameFromEmail(state.userEmail);
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .take(2)
        .join();

    final menu = <(String, String, PmTint, VoidCallback)>[
      (
        'Réglages',
        '',
        PmTint.blue,
        () => PmNav.push<void>(context, const SettingsScreen())
      ),
      (
        'Emploi du temps',
        'DUT1 TR',
        PmTint.brown,
        () => PmNav.push<void>(context, const ScheduleScreen())
      ),
      (
        'Carte hors-ligne',
        '28 Mo',
        PmTint.ochre,
        () => PmNav.push<void>(context, const OfflineScreen())
      ),
      (
        'Signaler un problème',
        '',
        PmTint.brown,
        () => PmNav.push<void>(context, const ReportScreen())
      ),
      ('Aide et contact ESP', '', PmTint.blue, () => PmNav.toHome(context)),
    ];

    return PmPage(
      child: ListView(
        padding: EdgeInsets.fromLTRB(22, pad.top + 24, 22, 24),
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: pm.brown, borderRadius: BorderRadius.circular(22)),
                child: Text(initials,
                    style: PmText.grotesk(22, color: PmFixed.white)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PmText.grotesk(22, color: pm.ink)),
                    Text(
                      state.isGuest
                          ? 'Mode visiteur · carte et itinéraires'
                          : 'DUT1 Télécoms & Réseaux · 2025-2026',
                      style: PmText.sans(13, color: pm.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              for (final (i, (v, k)) in const <(String, String)>[
                ('38', 'Trajets ce mois'),
                ('12', 'Lieux favoris'),
                ('4', 'Signalements')
              ].indexed) ...<Widget>[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: PmTile(
                    padding: const EdgeInsets.all(13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(v,
                            style: PmText.grotesk(20,
                                weight: FontWeight.w700, color: pm.blue)),
                        const SizedBox(height: 3),
                        Text(k, style: PmText.sans(11, color: pm.ink2)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          for (final (label, value, tint, go) in menu)
            InkWell(
              onTap: go,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: pm.line))),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: tintColor(pm, tint),
                          borderRadius: BorderRadius.circular(9)),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                        child: Text(label,
                            style: PmText.sans(14.5,
                                weight: FontWeight.w500, color: pm.ink))),
                    if (value.isNotEmpty) ...<Widget>[
                      Text(value, style: PmText.mono(11.5, color: pm.ink2)),
                      const SizedBox(width: 13),
                    ],
                    Chevron(color: pm.ink2, size: 7),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _nameFromEmail(String email) {
    final local = email.split('@').first;
    final parts = local.split(RegExp('[._-]')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return email;
    return parts.map((p) => p[0].toUpperCase() + p.substring(1)).join(' ');
  }
}
