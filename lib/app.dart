import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme/pm_theme.dart';

class PolyMapApp extends StatelessWidget {
  const PolyMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<AppState, ThemeMode>((s) => s.themeMode);
    return MaterialApp(
      title: 'PolyMap',
      debugShowCheckedModeBanner: false,
      theme: PmTheme.light(),
      darkTheme: PmTheme.dark(),
      themeMode: themeMode,
      locale: const Locale('fr'),
      home: const SplashScreen(),
    );
  }
}
