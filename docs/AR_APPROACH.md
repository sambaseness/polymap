# PolyMap — Approche AR : décision à prendre

Ce document cadre la **seule** partie de l'app qui n'est pas encore implémentée
« pour de vrai » : le guidage en réalité augmentée (écrans 15, 16, 17).

## État actuel (implémenté)

* **Rendu** : `lib/ar/ar_scene.dart` dessine une chaîne de flèches 3D
  (chevrons épais, faces ombrées, halo au sol) couchées le long de
  l'itinéraire, projetées en perspective (focale ≈ 62° vertical), la plus
  proche flottant légèrement, les suivantes s'estompant avec la distance.
  Étiquettes de portes = panneaux ancrés dans le même repère métrique.
* **Orientation** : `ArPoseController` fusionne la boussole inclinée
  (accéléromètre + magnétomètre via `sensors_plus`) ou `deviceorientation`
  sur le web, lissée, plus un décalage au doigt (glisser pour regarder,
  double-tap pour recentrer). Sans capteurs (ordinateur), la vue démarre dans
  l'axe du chemin.
* **Chemin** : `ArPath.fromRoute` convertit le tracé de la carte en mètres
  (échelle calée sur la distance annoncée), nord = haut de la carte, origine
  = position du marcheur.

Ce qui reste, c'est donc uniquement **la position** (où est l'origine du
chemin, et comment elle avance). Tout le reste de l'app est fonctionnel et ne
dépend pas de ce choix.

## Ce que le design exige de l'AR

| Exigence (design system / écrans) | Conséquence technique |
|---|---|
| Flèche posée « au bon endroit » après calibrage (écran 15 : « PolyMap reconnaît les repères du couloir ») | Il faut une **position + orientation indoor** fiable, pas seulement une boussole |
| Étiquettes sur les portes (« C-104 · Bureau ») | Il faut savoir **où sont les portes dans le repère de la caméra** |
| Changement d'étage (escalier B, R+1) | Le positionnement doit connaître **l'étage** |
| Mode hors-ligne : « Repères AR · Génie Informatique · 7 Mo » | Les données d'ancrage doivent être **téléchargeables par bâtiment** |
| Recalage par QR code à l'entrée (écran 04) | Le QR est déjà prévu comme **source de vérité de position** |
| Sortie toujours visible vers la 2D | L'AR est un mode additionnel, jamais obligatoire |

Le GPS est inutilisable à l'intérieur (précision 5–15 m, pas d'étage). Le vrai
problème n'est pas « dessiner une flèche en 3D », c'est **savoir où est le
téléphone dans le bâtiment**.

## Les options

### Option A — QR + odométrie visuelle (ARCore/ARKit « dead reckoning »)

* Le QR de la porte donne la position exacte et l'orientation initiale.
* ARCore (Android) / ARKit (iOS) suivent ensuite le déplacement du téléphone
  (6 DoF) en temps réel, sans réseau.
* Le chemin est un graphe de nœuds (portes, croisements, escaliers) par étage,
  saisi une fois par bâtiment — c'est exactement le « Schéma simplifié » de
  l'écran 11.
* La flèche est ancrée au prochain nœud ; la dérive se corrige au prochain QR
  ou en scannant une porte étiquetée.

| | |
|---|---|
| Plugins Flutter | `ar_flutter_plugin_2` (ARCore + ARKit), ou `arcore_flutter_plugin` + `arkit_plugin` séparés ; `mobile_scanner` pour le QR |
| Coût contenu | 1 QR par entrée + graphe de nœuds par étage (≈ 1 h par bâtiment, faisable par les étudiants) |
| Précision | 0,5–2 m sur 50–100 m de marche, puis dérive → recalage QR |
| Hors-ligne | ✅ total |
| Appareils | Android avec ARCore (la majorité des Android ≥ 2018, **pas** tous les entrées de gamme) ; iPhone ≥ 6s |
| Risque | Dérive en couloir uniforme (murs blancs) ; ARCore absent sur certains téléphones courants à Dakar |

**Recommandation : c'est l'option à lancer en premier.** Elle colle au design
(QR déjà prévu, packs AR par bâtiment, calibrage « balayez autour de vous »),
elle est hors-ligne, et elle ne demande aucune infrastructure dans les murs.

### Option B — Visual Positioning System (Google Geospatial / Immersal / Niantic Lightship VPS)

* On scanne les couloirs une fois pour construire une carte 3D de repères ;
  ensuite le téléphone se localise à ~10 cm en comparant l'image caméra.
* Google Geospatial ne couvre que l'extérieur cartographié par Street View —
  **pas les couloirs de l'ESP**. Immersal / Lightship permettent un scan privé.

| | |
|---|---|
| Plugins Flutter | Aucun mature : passer par un plugin natif maison (Kotlin/Swift) ou Unity-as-a-library |
| Coût contenu | Scan de chaque couloir + re-scan si le mobilier change |
| Précision | Excellente (< 30 cm) |
| Hors-ligne | ❌ (Immersal a un mode on-device payant) |
| Risque | Dépendance à un SaaS, tarifs, couverture réseau sur le campus, effort natif important |

À garder pour une **v2** si l'option A dérive trop dans certains bâtiments.

### Option C — Balises BLE (beacons) + boussole

* Beacons dans les couloirs, trilatération ≈ 3–5 m, orientation par boussole.
* La « flèche AR » devient une flèche 2D superposée à la caméra, pas ancrée.

| | |
|---|---|
| Plugins Flutter | `flutter_blue_plus` / `beacon` |
| Coût | Matériel (≈ 20–30 balises pour un bâtiment), piles, maintenance |
| Précision | 3–5 m, pas assez pour « 2e porte à gauche » |
| Hors-ligne | ✅ |
| Verdict | Pas à la hauteur du design ; utile seulement comme **recalage complémentaire** à l'option A |

### Option D — « AR » caméra + boussole seule (pas de positionnement)

Ce qui existe aujourd'hui, plus une rotation de la flèche selon le cap
magnétique. Honnête à afficher comme « orientation », mais ce n'est pas du
guidage : on ne sait pas où est l'utilisateur. À considérer seulement comme
mode dégradé quand ARCore est absent.

## Ce que je propose concrètement

1. **Valider l'option A** (QR + ARCore/ARKit + graphe de nœuds).
2. Étape 1 (sans AR encore) : `mobile_scanner` sur l'écran QR → position
   réelle + étage dans `AppState` ; le schéma d'étage et la navigation 2D
   deviennent vrais dès ce moment.
3. Étape 2 : intégrer `ar_flutter_plugin_2`, ancrer la flèche sur le prochain
   nœud du graphe, brancher l'écran de calibrage sur l'état de suivi
   (`TrackingState`) au lieu du compteur simulé.
4. Étape 3 : étiquettes de portes = nœuds « porte » (déjà rendues par
   `ArScene`, il suffit de les alimenter depuis le graphe) ; changement
   d'étage = nœud « escalier » avec transition d'étage.
5. Pilote sur **un** bâtiment (Pavillon C, déjà modélisé dans l'app), mesurer
   la dérive, puis étendre.

## Points à trancher ensemble avant d'écrire du code AR

* **Parc d'appareils** : quelle part des étudiants a un Android compatible
  ARCore ? (Vérifiable avec `ArCoreApk.checkAvailability` — je peux ajouter un
  écran de diagnostic.) Si < 60 %, prévoir l'option D en secours dès le départ.
* **Qui saisit les graphes** : équipe projet, ou outil de saisie dans l'app
  (mode « contribution », dans l'esprit de l'écran 24) ?
* **Plateformes** : Android seul pour le pilote, ou Android + iOS ?
* **Unity ou pur Flutter** : pur Flutter suffit pour une flèche et des
  étiquettes ; Unity ne se justifie que pour des visuels 3D riches.
