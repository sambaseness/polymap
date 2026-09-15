import 'package:flutter/material.dart';

import '../data/campus_data.dart';
import '../navigation.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_layout.dart';
import '../theme/pm_text.dart';
import '../widgets/dashed_border.dart';
import '../widgets/glyphs.dart';
import '../widgets/pm_button.dart';
import '../widgets/pm_cards.dart';
import '../widgets/pm_primitives.dart';

/// 24 — Signaler un problème. Type, detected place, details, photo.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _issue = 2;
  final _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  void _send() {
    // No backend yet: acknowledge and return home.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Merci — signalement enregistré.')),
    );
    PmNav.toHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: PmPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: pad.top + 14),
            const PmScreenHeader(title: 'Signaler', subtitle: 'Aidez-nous à corriger la carte du campus', titleSize: 23),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                children: <Widget>[
                  const PmSectionLabel('Type de problème'),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: <Widget>[
                      for (var i = 0; i < CampusData.issueTypes.length; i++)
                        PmChip(
                          label: CampusData.issueTypes[i],
                          selected: _issue == i,
                          onTap: () => setState(() => _issue = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const PmSectionLabel('Lieu concerné'),
                  PmCard(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                    child: Row(
                      children: <Widget>[
                        PmTagBox(text: 'C', size: 30, radius: 9, fontSize: 10.5, background: pm.brown, foreground: PmFixed.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Pavillon C · 1er étage', style: PmText.label(color: pm.ink)),
                              Text('Détecté automatiquement', style: PmText.sans(11.5, color: pm.ink2)),
                            ],
                          ),
                        ),
                        Text('Changer', style: PmText.sans(12.5, weight: FontWeight.w600, color: pm.blue)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const PmSectionLabel('Détails'),
                  Container(
                    constraints: const BoxConstraints(minHeight: 104),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                    decoration: BoxDecoration(
                      color: pm.surf,
                      border: Border.all(color: pm.line),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _details,
                      maxLines: null,
                      minLines: 3,
                      style: PmText.sans(13.5, color: pm.ink, height: 1.5),
                      decoration: InputDecoration(
                        hintText: "La flèche AR pointe vers l'escalier A alors que l'accès se fait par l'escalier B…",
                        hintStyle: PmText.sans(13.5, color: pm.ink2, height: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  DashedBorder(
                    color: pm.line,
                    radius: 14,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                      child: Row(
                        children: <Widget>[
                          SquareGlyph(color: pm.ink2, width: 30, height: 26, radius: 5),
                          const SizedBox(width: 10),
                          Text('Joindre une photo (optionnel)', style: PmText.sans(13, color: pm.ink2)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(22, 0, 22, pad.bottom + 12),
              child: PmButton(label: 'Envoyer le signalement', radius: 15, onTap: _send),
            ),
          ],
        ),
      ),
    );
  }
}
