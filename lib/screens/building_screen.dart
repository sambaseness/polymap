import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/campus_data.dart';
import '../data/models.dart';
import '../navigation.dart';
import '../state/app_state.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_text.dart';
import '../widgets/dashed_border.dart';
import '../widgets/pm_button.dart';
import '../widgets/pm_cards.dart';
import '../widgets/pm_primitives.dart';
import 'room_screen.dart';

/// 11 — Bâtiment et étages. Simplified floor schematic: corridor + room dots.
class BuildingScreen extends StatelessWidget {
  const BuildingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final pad = MediaQuery.paddingOf(context);
    final floor = context.select<AppState, int>((s) => s.floor);
    final rooms = CampusData.pavillonCFloors[floor];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: pad.top + 8),
          const PmScreenHeader(
            title: 'Pavillon C',
            subtitle: 'Résidence · 3 niveaux · 48 chambres',
            titleSize: 21,
            padding: EdgeInsets.fromLTRB(18, 8, 18, 12),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
            child: Row(
              children: <Widget>[
                for (var i = 0; i < CampusData.floorLabels.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: 6),
                  _FloorPill(
                    label: CampusData.floorLabels[i],
                    selected: floor == i,
                    onTap: () => context.read<AppState>().floor = i,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _FloorPlan(rooms: rooms),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 6,
              children: <Widget>[
                _Legend(color: pm.blue, label: 'Salle de cours'),
                _Legend(color: pm.brown, label: 'Bureau'),
                _Legend(color: pm.ochre, label: 'Service'),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, pad.bottom + 12),
            child: PmButton(
              label: 'Itinéraire depuis ici',
              radius: 15,
              onTap: () => PmNav.openRoute(context, 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorPill extends StatelessWidget {
  const _FloorPill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Material(
      color: selected ? pm.blue : pm.surf,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: selected ? pm.blue : pm.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: PmText.sans(12.5, weight: FontWeight.w600, color: selected ? pm.onBlue : pm.ink2),
          ),
        ),
      ),
    );
  }
}

class _FloorPlan extends StatelessWidget {
  const _FloorPlan({required this.rooms});
  final List<RoomDot> rooms;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    return Container(
      height: 268,
      decoration: BoxDecoration(
        color: pm.map,
        border: Border.all(color: pm.line),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth, h = c.maxHeight;
          return Stack(
            children: <Widget>[
              // Main corridor.
              Positioned(
                left: w * .12,
                right: w * .12,
                top: h * .46,
                height: 34,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: pm.surf2,
                    border: Border.symmetric(horizontal: BorderSide(color: pm.line)),
                  ),
                ),
              ),
              Positioned(
                left: w * .12,
                right: w * .12,
                top: h * .515,
                height: 1,
                child: Opacity(
                  opacity: .6,
                  child: CustomPaint(painter: _DashedLinePainter(pm.blue)),
                ),
              ),
              for (final rm in rooms)
                Positioned(
                  left: w * rm.x / 100 - 22,
                  top: h * rm.y / 100 - 14,
                  width: 44,
                  height: 44,
                  child: Semantics(
                    button: true,
                    label: 'Salle ${rm.code}',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => PmNav.push<void>(context, const RoomScreen()),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tintColor(pm, rm.kind),
                              border: Border.all(color: pm.map, width: 2),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(rm.code, style: PmText.mono(9, color: pm.bldgInk)),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 14,
                bottom: 12,
                child: Text(
                  'SCHÉMA SIMPLIFIÉ · COULOIR PRINCIPAL',
                  style: PmText.mono(9, color: pm.ink2, ls: 0.1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0.5)
      ..lineTo(size.width, 0.5);
    canvas.drawPath(
      dashPath(path, dash: 3, gap: 3),
      Paint()
        ..color = color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: PmText.sans(11.5, color: context.pm.ink2)),
        ],
      );
}
