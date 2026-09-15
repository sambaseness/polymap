import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/models.dart';
import 'screens/building_screen.dart';
import 'screens/directory_screen.dart';
import 'screens/home_shell.dart';
import 'screens/room_screen.dart';
import 'screens/route_screen.dart';
import 'state/app_state.dart';

/// Navigation helpers.
///
/// Two navigators:
/// * the **root** one holds the launch flow (Splash → Onboarding → Auth), then
///   [HomeShell] under [homeRouteName], and full-window screens (QR, AR);
/// * the **nested** one inside [HomeShell] holds everything else, so the
///   navigation rail stays visible on wide screens.
///
/// [push] goes to the nearest navigator — nested when called from shell
/// content, root when called from the launch flow or an AR screen.
abstract final class PmNav {
  static const String homeRouteName = '/home';
  static const String shellRootName = '/shell';

  static Future<T?> push<T>(BuildContext context, Widget page) =>
      Navigator.of(context).push<T>(_route<T>(page));

  static Future<T?> replace<T>(BuildContext context, Widget page) =>
      Navigator.of(context).pushReplacement<T, void>(_route<T>(page));

  /// Full-window push (camera / AR screens), above the shell and its rail.
  static Future<T?> pushFullscreen<T>(BuildContext context, Widget page) =>
      Navigator.of(context, rootNavigator: true).push<T>(_route<T>(page));

  /// Push a page into the shell's content area from anywhere (e.g. from a
  /// full-window AR screen), dropping any full-window screens above the shell.
  static void pushInShell(BuildContext context, Widget page) {
    final root = Navigator.of(context, rootNavigator: true);
    root.popUntil((r) => r.settings.name == homeRouteName || r.isFirst);
    HomeShell.navKey.currentState?.push<void>(_route<void>(page));
  }

  /// Enter the tab shell and drop the launch screens.
  static void enterHome(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil<void>(
      _route<void>(const HomeShell(), name: homeRouteName),
      (_) => false,
    );
  }

  /// Unwind everything to the shell root (creating the shell if we are still
  /// in the launch flow) and select a tab (0 carte, 1 favoris, 2 profil).
  static void toHome(BuildContext context, {int tab = 0}) {
    context.read<AppState>().tab = tab;
    final root = Navigator.of(context, rootNavigator: true);
    var found = false;
    root.popUntil((r) {
      if (r.settings.name == homeRouteName) found = true;
      return found || r.isFirst;
    });
    if (!found) {
      enterHome(context);
      return;
    }
    HomeShell.navKey.currentState?.popUntil((r) => r.isFirst);
  }

  static void openRoute(BuildContext context, int index) {
    context.read<AppState>().openRoute(index);
    push<void>(context, const RouteScreen());
  }

  static void openTarget(BuildContext context, PlaceTarget target) {
    switch (target) {
      case RouteTarget(:final routeIndex):
        openRoute(context, routeIndex);
      case RoomTarget():
        push<void>(context, const RoomScreen());
      case DirectoryTarget():
        push<void>(context, const DirectoryScreen());
    }
  }

  static void openBuilding(BuildContext context) =>
      push<void>(context, const BuildingScreen());

  static MaterialPageRoute<T> _route<T>(Widget page, {String? name}) =>
      MaterialPageRoute<T>(builder: (_) => page, settings: RouteSettings(name: name));
}
