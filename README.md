# PolyMap

Navigation du campus de l'École Supérieure Polytechnique de Dakar — Flutter.

Implémentation du design system et des 24 écrans de la maquette Claude Design
« PolyMap campus navigation app » (le bundle de handoff est la référence
visuelle ; ce dépôt en est la transcription Flutter).

## Plateformes

| Cible | État |
|---|---|
| **Android** | `flutter run` / `flutter build apk` — caméra, boussole et inclinomètre réels |
| **iOS** | `flutter run` / `flutter build ios` — idem (permissions caméra/mouvement dans `Info.plist`) |
| **Web** | `flutter run -d chrome` / `flutter build web` — responsive : téléphone, tablette (rail latéral), bureau (rail + panneaux latéraux). Boussole via `DeviceOrientation` sur mobile ; glisser pour regarder autour sur ordinateur |

Points de rupture (`lib/theme/pm_layout.dart`) : < 720 dp = téléphone (barre d'onglets), 720–1100 = tablette (rail, pages centrées), ≥ 1100 = bureau (rail + panneau de 400 dp à côté de la carte).

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
  ar/           moteur AR : pose (boussole + inclinaison), chemin métrique, rendu 3D des flèches
  navigation.dart  helpers Navigator (racine : lancement, coquille, écrans plein écran ; imbriqué : contenu)
docs/AR_APPROACH.md  options et recommandation pour le positionnement AR
```

## Ce qui est réel, ce qui est simulé

| Réel | Simulé (données statiques) |
|---|---|
| Thème clair / sombre / système, polices embarquées | Contenu du campus (`lib/data/campus_data.dart`) |
| Recherche avec filtrage, récents, catégories, état « aucun résultat » | Position de l'utilisateur (Pavillon C) |
| Choix d'itinéraire (À pied / Accessible / Le plus court) et étapes recalculées | Progression de la navigation 2D |
| Favoris, préférences d'accessibilité, session étudiant / visiteur | Authentification (aucun backend) |
| Flux caméra arrière sur les écrans QR et AR | Décodage QR, calibrage (compteur simulé) |
| **AR** : flèches 3D posées au sol le long de l'itinéraire, en perspective, orientées par la boussole et l'inclinaison du téléphone ; étiquettes de portes ancrées dans le même repère ; « prochain virage » calculé depuis le chemin | Position du marcheur sur l'itinéraire (point de démo) — pas encore de positionnement indoor, voir `docs/AR_APPROACH.md` |

## AR : ce qui marche, ce qui reste

`lib/ar/` rend une chaîne de flèches 3D (`ArScene`) dans un repère métrique
est/nord centré sur le marcheur, à partir du tracé de l'itinéraire
(`ArPath`). La vue est orientée par les capteurs (`ArPoseController` :
accéléromètre + magnétomètre sur mobile, `deviceorientation` sur le web) et
toujours pilotable au doigt. Ce qui manque pour un guidage réel, c'est la
**position** du téléphone dans le bâtiment ; les options (QR + ARCore/ARKit
recommandé) sont comparées dans [docs/AR_APPROACH.md](docs/AR_APPROACH.md).
Le rendu n'a pas à changer quand un moteur de positionnement sera branché :
il suffit de déplacer l'origine du chemin.
