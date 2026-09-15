# PolyMap

Navigation du campus de l'École Supérieure Polytechnique de Dakar — Flutter.

Implémentation du design system et des 24 écrans de la maquette Claude Design
« PolyMap campus navigation app » (le bundle de handoff est la référence
visuelle ; ce dépôt en est la transcription Flutter).

## Lancer

```bash
flutter pub get
flutter run            # appareil / émulateur Android ou iOS
flutter run -d chrome  # aperçu web (le flux caméra AR utilise la webcam)
```

SDK : Flutter ≥ 3.35 / Dart ≥ 3.5. Le SDK utilisé pour le développement est
installé dans `C:\dev\flutter`.

## Structure

```
lib/
  theme/        tokens : couleurs (2 thèmes), typographie, trame, ThemeData
  widgets/      briques du design system : boutons, cartes, puces, carte du campus, logo…
  data/         modèles + contenu statique du campus (bâtiments, itinéraires, salles, EDT)
  state/        AppState (thème, session, itinéraire en cours, préférences)
  screens/      un fichier par écran ; screens/ar/ pour les trois écrans AR
  navigation.dart  helpers Navigator (pile Splash → Onboarding → Auth → HomeShell → …)
docs/AR_APPROACH.md  options et recommandation pour le positionnement AR
```

## Ce qui est réel, ce qui est simulé

| Réel | Simulé (données statiques) |
|---|---|
| Thème clair / sombre / système, polices embarquées | Contenu du campus (`lib/data/campus_data.dart`) |
| Recherche avec filtrage, récents, catégories, état « aucun résultat » | Position de l'utilisateur (Pavillon C) |
| Choix d'itinéraire (À pied / Accessible / Le plus court) et étapes recalculées | Progression de la navigation 2D |
| Favoris, préférences d'accessibilité, session étudiant / visiteur | Authentification (aucun backend) |
| Flux caméra arrière sur les écrans QR et AR | Ancrage AR, décodage QR, calibrage — voir `docs/AR_APPROACH.md` |

## Décision en attente : AR

Les écrans AR sont des coquilles fidèles au design au-dessus de la caméra.
Le moteur de positionnement indoor n'est pas choisi ; les options sont
comparées dans [docs/AR_APPROACH.md](docs/AR_APPROACH.md).
