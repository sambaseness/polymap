import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation.dart';
import '../state/app_state.dart';
import '../theme/pm_colors.dart';
import '../theme/pm_layout.dart';
import '../theme/pm_text.dart';
import '../widgets/glyphs.dart';
import '../widgets/pm_cards.dart';
import '../widgets/pm_logo.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';
import 'search_screen.dart';

/// Tab shell: Carte · Recherche · Favoris · Profil.
///
/// Content lives in a nested [Navigator] ([navKey]) so that on wide screens
/// the left rail stays while pages are pushed next to it. On phones the tab
/// bar is part of the nested root page, so pushed screens cover it — exactly
/// like the design (pushed screens have a back chevron, no tab bar).
///
/// « Recherche » is a pushed screen in the design, so its tab pushes.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final wide = context.isWide;
    final nested = NavigatorPopHandler(
      onPopWithResult: (_) => navKey.currentState?.maybePop(),
      child: Navigator(
        key: navKey,
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          settings: const RouteSettings(name: PmNav.shellRootName),
          builder: (_) => const _ShellRoot(),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: context.pm.bg,
      body: wide
          ? Row(
              children: <Widget>[
                const _Rail(),
                Expanded(child: ClipRect(child: nested)),
              ],
            )
          : nested,
    );
  }

  /// Handle a tab tap from either the bar or the rail.
  static void selectTab(BuildContext context, int tab) {
    if (tab == 1) {
      PmNav.push<void>(context, const SearchScreen());
      return;
    }
    navKey.currentState?.popUntil((r) => r.isFirst);
    context.read<AppState>().tab = tab == 0 ? 0 : tab - 1;
  }

  static int tabForPage(int page) => page == 0 ? 0 : page + 1;
}

/// Root page of the nested navigator: the three tab pages (+ bottom bar on phones).
class _ShellRoot extends StatelessWidget {
  const _ShellRoot();

  @override
  Widget build(BuildContext context) {
    final page = context.select<AppState, int>((s) => s.tab);
    final stack = IndexedStack(
      index: page,
      children: const <Widget>[HomeScreen(), SavedScreen(), ProfileScreen()],
    );
    if (context.isWide) return stack;
    return Column(
      children: <Widget>[
        Expanded(child: stack),
        PmBottomNav(
          active: HomeShell.tabForPage(page),
          onSelect: (tab) => HomeShell.selectTab(context, tab),
        ),
      ],
    );
  }
}

/// Left navigation rail for tablets and desktop.
class _Rail extends StatelessWidget {
  const _Rail();

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final page = context.select<AppState, int>((s) => s.tab);
    final active = HomeShell.tabForPage(page);
    return Container(
      width: PmLayout.railWidth,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 18, bottom: 18),
      decoration: BoxDecoration(
        color: pm.surf,
        border: Border(right: BorderSide(color: pm.line)),
      ),
      child: Column(
        children: <Widget>[
          const PmLogo(size: 36),
          const SizedBox(height: 26),
          for (var i = 0; i < PmBottomNav.labels.length; i++) ...<Widget>[
            _RailItem(index: i, on: active == i, onTap: () => HomeShell.selectTab(context, i)),
            const SizedBox(height: 6),
          ],
          const Spacer(),
          Text('ESP', style: PmText.mono(10, color: pm.ink2, ls: 0.14)),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({required this.index, required this.on, required this.onTap});
  final int index;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pm = context.pm;
    final c = on ? pm.blue : pm.ink2;
    final glyph = switch (index) {
      0 => SquareGlyph(color: c, width: 18, height: 18, radius: 5, filled: on),
      1 || 3 => CircleGlyph(color: c, size: 18, filled: on),
      _ => DiamondGlyph(color: c, size: 16, radius: 3, filled: on),
    };
    return Semantics(
      button: true,
      selected: on,
      label: PmBottomNav.labels[index],
      child: Material(
        color: on ? pm.surf2 : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 68,
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 18, child: Center(child: glyph)),
                const SizedBox(height: 6),
                Text(
                  PmBottomNav.labels[index],
                  style: PmText.sans(10.5, weight: on ? FontWeight.w600 : FontWeight.w400, color: c),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
