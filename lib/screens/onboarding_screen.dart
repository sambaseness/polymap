import 'package:flutter/material.dart';

import '../navigation.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_layout.dart';
import '../theme/pm_text.dart';
import '../widgets/glyphs.dart';
import '../widgets/pm_button.dart';
import '../widgets/pm_logo.dart';
import '../widgets/pm_primitives.dart';
import 'auth_screen.dart';

/// 02 — Permissions. Position, camera, compass — each justified by its use.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[pm.surf2, pm.bg],
            stops: const <double>[0, 0.46],
          ),
        ),
        child: PmPage(
          maxWidth: PmLayout.launchMaxWidth,
          child: Padding(
            padding: EdgeInsets.fromLTRB(26, pad.top + 44, 26, pad.bottom + 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: PmLogo(size: 66),
                ),
                const SizedBox(height: 26),
                Text(
                  'Trouvez votre salle,\npas votre chemin.',
                  style: PmText.grotesk(32,
                      weight: FontWeight.w700,
                      color: pm.ink,
                      ls: -0.025,
                      height: 1.1),
                ),
                const SizedBox(height: 12),
                Text(
                  "Tous les bâtiments, pavillons et salles de l'École Supérieure Polytechnique de Dakar — avec guidage en réalité augmentée.",
                  style: PmText.body(color: pm.ink2),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      _PermissionCard(
                        title: 'Position',
                        body: 'Pour vous localiser sur le campus',
                        tint: pm.blue,
                        glyph: CircleGlyph(
                            color: pm.onBlue, size: 11, filled: true),
                      ),
                      const SizedBox(height: 10),
                      _PermissionCard(
                        title: 'Caméra',
                        body: 'Nécessaire au mode réalité augmentée',
                        tint: pm.brown,
                        glyph: const SquareGlyph(
                            color: PmFixed.white,
                            width: 14,
                            height: 11,
                            radius: 3),
                      ),
                      const SizedBox(height: 10),
                      _PermissionCard(
                        title: 'Boussole',
                        body: "Pour orienter la flèche à l'écran",
                        tint: pm.ochre,
                        glyph: const DiamondGlyph(
                            color: Color(0xFF1B1206), size: 12, radius: 2),
                      ),
                    ],
                  ),
                ),
                PmButton(
                  label: 'Autoriser et continuer',
                  height: 54,
                  fontSize: 16,
                  onTap: () => PmNav.replace<void>(context, const AuthScreen()),
                ),
                const SizedBox(height: 4),
                PmButton(
                  label: 'Plus tard',
                  variant: PmButtonVariant.text,
                  onTap: () => PmNav.enterHome(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.title,
    required this.body,
    required this.tint,
    required this.glyph,
  });

  final String title;
  final String body;
  final Color tint;
  final Widget glyph;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return PmCard(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: tint, borderRadius: BorderRadius.circular(10)),
            child: glyph,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: PmText.label(color: pm.ink)),
                const SizedBox(height: 2),
                Text(body,
                    style: PmText.sans(12.5, color: pm.ink2, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
