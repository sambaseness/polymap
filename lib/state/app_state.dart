import 'package:flutter/material.dart';

import '../data/campus_data.dart';
import '../data/models.dart';

/// App-wide state: theme, session, the route being planned, preferences.
///
/// Kept deliberately small and in-memory for this first iteration; persistence
/// (shared_preferences / offline packs) can be layered on without touching
/// the screens.
class AppState extends ChangeNotifier {
  // ---- Appearance ---------------------------------------------------------

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) {
    if (value == _themeMode) return;
    _themeMode = value;
    notifyListeners();
  }

  String _language = 'Français';
  String get language => _language;
  set language(String value) {
    _language = value;
    notifyListeners();
  }

  // ---- Session ------------------------------------------------------------

  bool _isGuest = true;
  bool get isGuest => _isGuest;

  String _userEmail = '';
  String get userEmail => _userEmail;

  void signIn(String email) {
    _isGuest = false;
    _userEmail = email;
    notifyListeners();
  }

  void continueAsGuest() {
    _isGuest = true;
    _userEmail = '';
    notifyListeners();
  }

  // ---- Route planning -----------------------------------------------------

  int _routeIndex = 0;
  RouteMode _mode = RouteMode.walk;

  CampusRoute get route => CampusData.routes[_routeIndex];
  RouteMode get mode => _mode;
  ComputedRoute get computedRoute => route.compute(_mode);

  /// Select a quick route and reset the mode, like the prototype's `openRoute`.
  void openRoute(int index) {
    _routeIndex = index.clamp(0, CampusData.routes.length - 1);
    _mode = RouteMode.walk;
    notifyListeners();
  }

  set mode(RouteMode value) {
    if (value == _mode) return;
    _mode = value;
    notifyListeners();
  }

  // ---- Floor plan ---------------------------------------------------------

  int _floor = 1;
  int get floor => _floor;
  set floor(int value) {
    if (value == _floor) return;
    _floor = value;
    notifyListeners();
  }

  // ---- Favourites ---------------------------------------------------------

  final Set<String> _favorites = <String>{
    for (final p in CampusData.favorites) p.code,
  };
  bool isFavorite(String code) => _favorites.contains(code);
  void toggleFavorite(String code) {
    if (!_favorites.remove(code)) _favorites.add(code);
    notifyListeners();
  }

  // ---- Accessibility & AR preferences -------------------------------------

  bool avoidStairs = true;
  bool arDoorLabels = true;
  bool voiceGuidance = false;
  bool highContrast = false;

  void setPref(void Function() change) {
    change();
    notifyListeners();
  }

  // ---- Tab shell ----------------------------------------------------------

  int _tab = 0;
  int get tab => _tab;
  set tab(int value) {
    if (value == _tab) return;
    _tab = value;
    notifyListeners();
  }
}
