import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polymap/data/campus_data.dart';
import 'package:polymap/data/models.dart';
import 'package:polymap/screens/home_shell.dart';
import 'package:polymap/screens/search_screen.dart';
import 'package:polymap/state/app_state.dart';
import 'package:polymap/theme/pm_theme.dart';
import 'package:provider/provider.dart';

Widget _app(Widget home, {AppState? state}) => ChangeNotifierProvider<AppState>(
      create: (_) => state ?? AppState(),
      child: MaterialApp(
          theme: PmTheme.light(), darkTheme: PmTheme.dark(), home: home),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('route computation', () {
    test('accessible mode adds the ramp detour before the last step', () {
      final r = CampusData.routes[0].compute(RouteMode.accessible);
      expect(r.minutes, 7);
      expect(r.distM, 405);
      expect(r.steps.length, 6);
      expect(r.steps[r.steps.length - 2].n, '↗');
      expect(r.points, CampusData.routes[0].alt);
    });

    test('shortest mode drops the second step', () {
      final r = CampusData.routes[0].compute(RouteMode.shortest);
      expect(r.minutes, 4);
      expect(r.distM, 290);
      expect(r.steps.length, 4);
      expect(r.steps[1].label, "Longer le terrain par l'ouest");
    });
  });

  group('search', () {
    test('« salle 204 » returns the four design results, accent-insensitive',
        () {
      final hits = CampusData.places
          .where((p) => p.matches('salle 204'))
          .map((p) => p.name)
          .toList();
      expect(
          hits,
          containsAll(
              <String>['Salle 204', 'Labo LER 2.04', 'Amphi 204 places']));
      expect(
          CampusData.places.where((p) => p.matches('bibliotheque')).length, 1);
      expect(CampusData.places.where((p) => p.matches('amphi 700')), isEmpty);
    });
  });

  group('screens', () {
    testWidgets('home shell renders map sheet and switches tabs',
        (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(const HomeShell()));
      await tester.pump();
      expect(find.text('Où allez-vous ?'), findsOneWidget);
      expect(find.text('Département Génie Informatique'), findsOneWidget);

      await tester.tap(find.text('Favoris'));
      await tester.pump();
      expect(find.text('Mes lieux'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      await tester.pump();
      expect(find.text('Réglages'), findsOneWidget);
    });

    testWidgets('search shows recents, results, then the empty state',
        (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(const SearchScreen()));
      await tester.pump();
      expect(find.text('RECHERCHES RÉCENTES'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'salle 204');
      await tester.pump();
      expect(find.text('Salle 204'), findsOneWidget);
      expect(find.textContaining('RÉSULTATS'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'amphi 700');
      await tester.pump();
      expect(find.text('Aucun lieu trouvé'), findsOneWidget);
      expect(find.text('Signaler un lieu manquant'), findsOneWidget);
    });
  });
}
