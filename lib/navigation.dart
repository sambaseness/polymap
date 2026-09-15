import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/models.dart';
import 'screens/building_screen.dart';
import 'screens/directory_screen.dart';
import 'screens/home_shell.dart';
import 'screens/room_screen.dart';
import 'screens/route_screen.dart';
import 'state/app_state.dart';

/// Thin navigation helpers over Navigator 1.0.
///
/// The stack is: Splash → (Onboarding → Auth) → [HomeShell] → pushed screens.
/// [HomeShell] is registered under [homeRouteName] so « Terminer » / « Envoyer »
/// can unwind to it from anywhere.
abstract final class PmNav {
  static const String homeRouteName = '/home';

  static Future<T?> push<T>(BuildContext context, Widget page) =>
      Navigator.of(context).push<T>(_route<T>(page));

  static Future<T?> replace<T>(BuildContext context, Widget page) =>
      Navigator.of(context).pushReplacement<T, void>(_route<T>(page));

  /// Enter the tab shell and drop the launch screens.
  static void enterHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil<void>(
      _route<void>(const HomeShell(), name: homeRouteName),
      (_) => false,
    );
  }

  /// Unwind to the shell (creating it if we are still in the launch flow)
  /// and select a tab.
  static void toHome(BuildContext context, {int tab = 0}) {
    context.read<AppState>().tab = tab;
    final nav = Navigator.of(context);
    var found = false;
    nav.popUntil((r) {
      if (r.settings.name == homeRouteName) found = true;
      return found || r.isFirst;
    });
    if (!found) enterHome(context);
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
