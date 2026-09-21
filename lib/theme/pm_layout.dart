import 'package:flutter/material.dart';

/// Responsive breakpoints.
///
/// * compact  — phones (< 720 dp): the design as drawn, bottom tab bar.
/// * medium   — tablets / small windows: left navigation rail, pages centred.
/// * expanded — desktop (≥ 1100 dp): rail + side panels next to the map.
enum PmBreakpoint {
  compact,
  medium,
  expanded;

  bool get isWide => this != PmBreakpoint.compact;
  bool get isExpanded => this == PmBreakpoint.expanded;

  static PmBreakpoint of(double width) => width < 720
      ? PmBreakpoint.compact
      : width < 1100
          ? PmBreakpoint.medium
          : PmBreakpoint.expanded;
}

extension PmLayoutContext on BuildContext {
  PmBreakpoint get breakpoint => PmBreakpoint.of(MediaQuery.sizeOf(this).width);
  bool get isWide => breakpoint.isWide;
}

/// Widths used by the wide layouts.
abstract final class PmLayout {
  /// Reading column for list-type pages (settings, directory, room…).
  static const double pageMaxWidth = 640;

  /// Narrow column for the launch flow (onboarding, auth).
  static const double launchMaxWidth = 460;

  /// Side panel next to a map (home sheet, route steps, navigation card).
  static const double panelWidth = 400;

  /// Left navigation rail.
  static const double railWidth = 92;
}

/// Constrains a page to a reading column on wide screens; no-op on phones.
///
/// Wrap a Scaffold body with it: `body: PmPage(child: Column(...))`.
class PmPage extends StatelessWidget {
  const PmPage(
      {super.key, required this.child, this.maxWidth = PmLayout.pageMaxWidth});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!context.isWide) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Map screens: full-bleed map on phones; on wide screens a fixed-width panel
/// on the left and the map filling the rest.
class PmMapLayout extends StatelessWidget {
  const PmMapLayout({
    super.key,
    required this.map,
    required this.compact,
    required this.panel,
    this.mapOverlay,
  });

  /// The map widget (shared by both layouts).
  final Widget map;

  /// Phone layout builder — receives the map and stacks its own overlays.
  final Widget Function(Widget map) compact;

  /// Panel content for wide screens.
  final Widget panel;

  /// Extra widgets stacked over the map on wide screens (floating buttons).
  final List<Widget>? mapOverlay;

  @override
  Widget build(BuildContext context) {
    if (!context.isWide) return compact(map);
    return Row(
      children: <Widget>[
        SizedBox(width: PmLayout.panelWidth, child: panel),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[map, ...?mapOverlay],
          ),
        ),
      ],
    );
  }
}
