import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation.dart';
import '../state/app_state.dart';
import '../theme/pm_colors.dart';
import '../widgets/pm_cards.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';
import 'search_screen.dart';

/// Tab shell: Carte · Recherche · Favoris · Profil.
///
/// « Recherche » is a pushed screen in the design (it has a back chevron and
/// no tab bar), so tapping it pushes rather than switching tabs.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const List<int> _tabToPage = <int>[0, -1, 1, 2];
  static const List<int> _pageToTab = <int>[0, 2, 3];

  @override
  Widget build(BuildContext context) {
    final page = context.select<AppState, int>((s) => s.tab);
    return Scaffold(
      backgroundColor: context.pm.bg,
      body: Column(
        children: <Widget>[
          Expanded(
            child: IndexedStack(
              index: page,
              children: const <Widget>[HomeScreen(), SavedScreen(), ProfileScreen()],
            ),
          ),
          PmBottomNav(
            active: _pageToTab[page],
            onSelect: (tab) {
              final p = _tabToPage[tab];
              if (p < 0) {
                PmNav.push<void>(context, const SearchScreen());
              } else {
                context.read<AppState>().tab = p;
              }
            },
          ),
        ],
      ),
    );
  }
}
