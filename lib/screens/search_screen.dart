import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/campus_data.dart';
import '../data/models.dart';
import '../navigation.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_layout.dart';
import '../theme/pm_text.dart';
import '../widgets/glyphs.dart';
import '../widgets/pm_button.dart';
import '../widgets/pm_cards.dart';
import '../widgets/pm_primitives.dart';
import 'directory_screen.dart';
import 'report_screen.dart';

/// 07/08/09 — Recherche : récents · résultats · aucun résultat.
/// One screen, three states driven by the query.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});
  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialQuery);
  late List<Place> _recents = List<Place>.of(CampusData.recents);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    final query = _ctrl.text.trim();
    final results = query.isEmpty
        ? const <Place>[]
        : CampusData.places.where((p) => p.matches(query)).toList();
    final none = query.isNotEmpty && results.isEmpty;

    return Scaffold(
      body: PmPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16, pad.top + 8, 16, 14),
              child: Row(
                children: <Widget>[
                  PmBackButton(size: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: pm.surf,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                            color: none ? pm.brown : pm.blue, width: 1.5),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onChanged: (_) => setState(() {}),
                        style: PmText.sans(14.5, color: pm.ink),
                        decoration: InputDecoration(
                          hintText: 'Salle, bâtiment, département…',
                          hintStyle: PmText.sans(14.5, color: pm.ink2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch ((query.isEmpty, none)) {
                (true, _) => _Recents(
                    recents: _recents,
                    onRemove: (p) => setState(() =>
                        _recents = _recents.where((r) => r != p).toList()),
                  ),
                (false, false) => _Results(results: results),
                (false, true) => _NoResults(query: query),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.results});
  final List<Place> results;

  @override
  Widget build(BuildContext context) {
    final n = results.length;
    return ListView(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, MediaQuery.paddingOf(context).bottom + 16),
      children: <Widget>[
        PmSectionLabel('$n résultat${n > 1 ? 's' : ''}', ls: 0.14),
        for (var i = 0; i < results.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 8),
          PmPlaceCard(
            code: results[i].code,
            name: results[i].name,
            place: results[i].place,
            trailing: results[i].dist,
            onTap: () => PmNav.openTarget(context, results[i].target),
          ),
        ],
      ],
    );
  }
}

class _Recents extends StatelessWidget {
  const _Recents({required this.recents, required this.onRemove});
  final List<Place> recents;
  final ValueChanged<Place> onRemove;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return ListView(
      padding: EdgeInsets.fromLTRB(
          18, 4, 18, MediaQuery.paddingOf(context).bottom + 16),
      children: <Widget>[
        if (recents.isNotEmpty)
          const PmSectionLabel('Recherches récentes', ls: 0.14),
        for (final r in recents)
          InkWell(
            onTap: () => PmNav.openTarget(context, r.target),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: pm.line))),
              child: Row(
                children: <Widget>[
                  CircleGlyph(color: pm.ink2, size: 16, stroke: 1.5),
                  const SizedBox(width: 13),
                  Expanded(
                      child:
                          Text(r.name, style: PmText.sans(14, color: pm.ink))),
                  Semantics(
                    button: true,
                    label: 'Retirer',
                    child: InkWell(
                      onTap: () => onRemove(r),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: CrossGlyph(color: pm.ink2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 26),
        const PmSectionLabel('Catégories', ls: 0.14, bottom: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final c in CampusData.searchCategories)
              PmChip(
                label: c,
                fontSize: 13,
                weight: FontWeight.w500,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                onTap: () => PmNav.push<void>(context, const DirectoryScreen()),
              ),
          ],
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return ListView(
      padding: EdgeInsets.fromLTRB(
          18, 28, 18, MediaQuery.paddingOf(context).bottom + 16),
      children: <Widget>[
        Center(
          child: Container(
            width: 74,
            height: 74,
            margin: const EdgeInsets.only(bottom: 22),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: pm.surf2,
              border: Border.all(color: pm.line),
              borderRadius: BorderRadius.circular(24),
            ),
            child: SizedBox(
                width: 26,
                height: 26,
                child: CustomPaint(painter: _NotFoundPainter(pm.ink2))),
          ),
        ),
        Text('Aucun lieu trouvé',
            textAlign: TextAlign.center,
            style: PmText.grotesk(20, color: pm.ink)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Aucune salle ni bâtiment ne correspond à « $query » sur le campus ESP.',
            textAlign: TextAlign.center,
            style: PmText.sans(13.5, color: pm.ink2, height: 1.55),
          ),
        ),
        const SizedBox(height: 26),
        const PmSectionLabel('Peut-être cherchiez-vous', ls: 0.14),
        PmPlaceCard(
          code: 'AW',
          name: 'Amphithéâtre Abdoul Aziz Wane',
          place: 'Nord du campus · 204 places',
          onTap: () => PmNav.openRoute(context, 1),
        ),
        const SizedBox(height: 14),
        PmButton(
          label: 'Signaler un lieu manquant',
          variant: PmButtonVariant.ghost,
          onTap: () => PmNav.push<void>(context, const ReportScreen()),
        ),
      ],
    );
  }
}

/// A circle crossed by a diagonal bar.
class _NotFoundPainter extends CustomPainter {
  _NotFoundPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.butt;
    canvas.drawOval((Offset.zero & size).deflate(1.25), p);
    final c = size.center(Offset.zero);
    const half = 11.0;
    final d =
        Offset(half * math.cos(math.pi / 4), half * math.sin(math.pi / 4));
    canvas.drawLine(c - d, c + d, p);
  }

  @override
  bool shouldRepaint(_NotFoundPainter old) => old.color != color;
}
