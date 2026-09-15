import 'package:flutter/painting.dart' show Offset;

import 'models.dart';

/// Static campus content for the ESP Dakar (Fann) campus.
///
/// Ported from the design prototype. This is the seed for a future backend /
/// offline pack; every screen reads from here so swapping the source later is
/// a single-file change.
abstract final class CampusData {
  // ---- Schematic map ------------------------------------------------------

  static const List<Building> buildings = <Building>[
    Building(name: 'Innodev', short: 'Innodev', x: 17, y: 5, w: 15, h: 6.5),
    Building(name: "Bibliothèque de l'ESP", short: 'Biblio.\nESP', x: 15, y: 14, w: 17, h: 6),
    Building(name: 'Amphithéâtre Abdoul Aziz Wane', short: 'Amphi\nA.A. Wane', x: 34, y: 3, w: 15, h: 6.5),
    Building(name: "Secrétariat de l'ESP", short: 'Secrétariat', x: 51, y: 4, w: 20, h: 6),
    Building(name: 'Salle DUT1 Informatique', short: 'DUT1 Info', x: 52, y: 12, w: 19, h: 5.5),
    Building(name: 'Département Génie Chimique', short: 'Génie\nChimique', x: 75, y: 7, w: 22, h: 6.5),
    Building(name: 'Département Génie Électrique', short: 'Génie\nÉlectrique', x: 75, y: 16, w: 22, h: 6.5),
    Building(name: 'CEPECS', short: 'CEPECS', x: 7, y: 25, w: 16, h: 6),
    Building(name: 'Département Génie Informatique', short: 'Génie\nInformatique', x: 11, y: 34, w: 21, h: 8),
    Building(name: 'Terrain de sport', short: 'Terrain', x: 34, y: 30, w: 30, h: 35, isGreen: true),
    Building(name: 'Labo LER', short: 'Labo LER', x: 53, y: 22, w: 18, h: 5.5),
    Building(name: 'Département Génie Civil', short: 'Génie Civil', x: 71, y: 29, w: 25, h: 7),
    Building(name: 'Restaurant ESP', short: 'Resto\nESP', x: 9, y: 49, w: 15, h: 7),
    Building(name: 'Pavillon F', short: 'Pav. F', x: 7, y: 67, w: 12, h: 6),
    Building(name: 'Pavillon G', short: 'Pav. G', x: 5, y: 77, w: 12, h: 6),
    Building(name: 'Pavillon B', short: 'Pav. B', x: 20, y: 75, w: 12, h: 7),
    Building(name: 'Salle de télévision', short: 'Salle télé', x: 36, y: 69, w: 16, h: 6),
    Building(name: "Mosquée de l'ESP", short: 'Mosquée', x: 57, y: 69, w: 16, h: 6),
    Building(name: 'Pavillon A', short: 'Pav. A', x: 49, y: 77, w: 13, h: 7),
    Building(name: 'Pavillon C', short: 'Pav. C', x: 22, y: 87, w: 22, h: 6),
    Building(name: 'Pavillon E', short: 'Pav. E', x: 48, y: 88, w: 14, h: 6),
    Building(name: 'Parking AUF', short: 'P. AUF', x: 2, y: 87, w: 12, h: 7),
  ];

  /// Where the user is standing on the home map (Pavillon C).
  static const Offset userPosition = Offset(32.5, 90);

  // ---- Routes -------------------------------------------------------------

  static const List<CampusRoute> routes = <CampusRoute>[
    CampusRoute(
      from: 'Pavillon C',
      to: 'Département Génie Informatique',
      destShort: 'Génie Info',
      minutes: 5,
      distM: 335,
      pts: <Offset>[Offset(33, 90), Offset(39, 84), Offset(39, 72), Offset(33, 62), Offset(30, 48), Offset(22, 39)],
      alt: <Offset>[Offset(33, 90), Offset(27, 84), Offset(22, 74), Offset(24, 60), Offset(26, 48), Offset(22, 39)],
      short: <Offset>[Offset(33, 90), Offset(33, 76), Offset(31, 58), Offset(26, 44), Offset(22, 39)],
      steps: <RouteStep>[
        RouteStep('1', 'Sortir du Pavillon C côté nord', '40 m'),
        RouteStep('2', "Traverser l'Allée Jardin", '85 m'),
        RouteStep('3', "Longer le terrain par l'ouest", '120 m'),
        RouteStep('4', 'Passer devant le Restaurant ESP', '60 m'),
        RouteStep('5', 'Entrée du Département Génie Informatique', '30 m'),
      ],
    ),
    CampusRoute(
      from: 'Restaurant ESP',
      to: 'Amphithéâtre Abdoul Aziz Wane',
      destShort: 'Amphi A.A.W.',
      minutes: 4,
      distM: 260,
      pts: <Offset>[Offset(17, 53), Offset(26, 46), Offset(30, 30), Offset(36, 16), Offset(40, 10)],
      alt: <Offset>[Offset(17, 53), Offset(22, 44), Offset(24, 30), Offset(32, 20), Offset(40, 10)],
      short: <Offset>[Offset(17, 53), Offset(28, 42), Offset(33, 24), Offset(40, 10)],
      steps: <RouteStep>[
        RouteStep('1', 'Sortir du Restaurant ESP, direction nord', '55 m'),
        RouteStep('2', "Remonter l'allée bordant le CEPECS", '95 m'),
        RouteStep('3', 'Tourner à droite après la Bibliothèque', '70 m'),
        RouteStep('4', "Entrée de l'amphithéâtre, porte est", '40 m'),
      ],
    ),
    CampusRoute(
      from: 'Parking AUF',
      to: "Secrétariat de l'ESP",
      destShort: 'Secrétariat',
      minutes: 6,
      distM: 420,
      pts: <Offset>[Offset(8, 90), Offset(18, 84), Offset(28, 70), Offset(32, 46), Offset(45, 26), Offset(59, 10)],
      alt: <Offset>[Offset(8, 90), Offset(16, 80), Offset(24, 66), Offset(30, 44), Offset(40, 30), Offset(52, 16), Offset(59, 10)],
      short: <Offset>[Offset(8, 90), Offset(20, 78), Offset(30, 52), Offset(44, 24), Offset(59, 10)],
      steps: <RouteStep>[
        RouteStep('1', 'Sortir du Parking AUF, portail nord', '60 m'),
        RouteStep('2', 'Passer entre le Pavillon G et le Pavillon B', '110 m'),
        RouteStep('3', "Longer le terrain par l'ouest", '130 m'),
        RouteStep('4', "Traverser l'allée centrale", '80 m'),
        RouteStep('5', "Secrétariat de l'ESP, 1re porte", '40 m'),
      ],
    ),
  ];

  /// Two-letter tags and tints for the three quick routes on Home.
  static const List<String> quickRouteTags = <String>['GI', 'AW', 'SE'];
  static const List<PmTint> quickRouteTints = <PmTint>[PmTint.blue, PmTint.brown, PmTint.ochre];

  // ---- Buildings & rooms --------------------------------------------------

  static const List<String> floorLabels = <String>['RDC', '1er étage', '2e étage'];
  static const List<String> floorShort = <String>['RDC', 'R+1', 'R+2'];

  static const List<List<RoomDot>> pavillonCFloors = <List<RoomDot>>[
    <RoomDot>[
      RoomDot('C-001', 18, 26, PmTint.ochre), RoomDot('C-002', 34, 26, PmTint.blue),
      RoomDot('C-003', 52, 26, PmTint.blue), RoomDot('C-004', 70, 26, PmTint.brown),
      RoomDot('C-005', 84, 40, PmTint.ochre), RoomDot('C-006', 22, 74, PmTint.blue),
      RoomDot('C-007', 44, 74, PmTint.blue), RoomDot('C-008', 66, 74, PmTint.brown),
    ],
    <RoomDot>[
      RoomDot('C-101', 20, 26, PmTint.blue), RoomDot('C-102', 38, 26, PmTint.blue),
      RoomDot('C-104', 58, 26, PmTint.brown), RoomDot('C-105', 78, 26, PmTint.blue),
      RoomDot('C-107', 30, 74, PmTint.blue), RoomDot('C-108', 52, 74, PmTint.blue),
      RoomDot('C-109', 74, 74, PmTint.ochre),
    ],
    <RoomDot>[
      RoomDot('C-201', 24, 26, PmTint.blue), RoomDot('C-203', 46, 26, PmTint.brown),
      RoomDot('C-205', 68, 26, PmTint.blue), RoomDot('C-206', 34, 74, PmTint.blue),
      RoomDot('C-208', 60, 74, PmTint.ochre),
    ],
  ];

  static const List<DirectoryGroup> directory = <DirectoryGroup>[
    DirectoryGroup('Enseignement', <DirectoryItem>[
      DirectoryItem('GI', 'Département Génie Informatique', '3 niveaux · 18 salles', PmTint.blue),
      DirectoryItem('GE', 'Département Génie Électrique', '2 niveaux · 12 salles', PmTint.blue),
      DirectoryItem('GC', 'Département Génie Civil', '2 niveaux · 9 salles', PmTint.blue),
      DirectoryItem('AW', 'Amphithéâtre Abdoul Aziz Wane', '204 places', PmTint.brown),
    ]),
    DirectoryGroup('Résidences', <DirectoryItem>[
      DirectoryItem('A', 'Pavillon A', '3 niveaux · 52 chambres', PmTint.brown),
      DirectoryItem('C', 'Pavillon C', '3 niveaux · 48 chambres', PmTint.brown),
      DirectoryItem('F', 'Pavillon F', '2 niveaux · 30 chambres', PmTint.brown),
    ]),
    DirectoryGroup('Services', <DirectoryItem>[
      DirectoryItem('RE', 'Restaurant ESP', 'Ouvert 11h30 — 14h30', PmTint.ochre),
      DirectoryItem('BI', "Bibliothèque de l'ESP", 'Ouvert 08h — 19h', PmTint.ochre),
      DirectoryItem('SE', "Secrétariat de l'ESP", 'Ouvert 08h — 16h', PmTint.ochre),
    ]),
  ];

  static const List<String> categoryChips = <String>[
    'Salles de cours', 'Amphis', 'Départements', 'Pavillons', 'Services',
  ];

  static const List<String> searchCategories = <String>[
    'Amphis', 'Salles de TD', 'Départements', 'Pavillons', 'Laboratoires', 'Restauration', 'Sanitaires',
  ];

  // ---- Places (search index) ---------------------------------------------

  static const List<Place> places = <Place>[
    Place(code: '204', name: 'Salle 204', place: 'Génie Informatique · 1er étage', dist: '335 m',
        target: RouteTarget(0), keywords: <String>['salle 204', 'gi', 'informatique']),
    Place(code: '107', name: 'Salle C-107 (TD)', place: 'Pavillon C · 1er étage', dist: '40 m',
        target: RoomTarget(), keywords: <String>['salle 107', 'c-107', 'c107', 'td', 'pavillon c']),
    Place(code: 'LER', name: 'Labo LER 2.04', place: "Laboratoire d'Énergies Renouvelables", dist: '410 m',
        target: RouteTarget(2), keywords: <String>['salle 204', 'labo', 'laboratoire']),
    Place(code: 'AW', name: 'Amphi 204 places', place: 'Amphithéâtre Abdoul Aziz Wane', dist: '260 m',
        target: RouteTarget(1), keywords: <String>['amphi', 'amphithéâtre', 'salle 204', 'wane']),
    Place(code: 'RE', name: 'Restaurant ESP', place: 'Ouest du terrain', dist: '120 m',
        target: RouteTarget(1), keywords: <String>['resto', 'restauration', 'cantine']),
    Place(code: 'BI', name: "Bibliothèque de l'ESP", place: 'Aile nord · face Innodev', dist: '290 m',
        target: DirectoryTarget(), keywords: <String>['biblio', 'bibliotheque']),
    Place(code: 'SE', name: "Secrétariat de l'ESP", place: 'Nord du campus', dist: '420 m',
        target: RouteTarget(2), keywords: <String>['secretariat', 'administration']),
    Place(code: 'C', name: 'Pavillon C', place: 'Résidence · 3 niveaux', dist: '0 m',
        target: DirectoryTarget(), keywords: <String>['pavillon', 'residence']),
  ];

  static const List<Place> recents = <Place>[
    Place(code: '204', name: 'Salle 204 · Génie Informatique', place: '', dist: '', target: RouteTarget(0)),
    Place(code: 'RE', name: 'Restaurant ESP', place: '', dist: '', target: RouteTarget(1)),
    Place(code: 'BI', name: "Bibliothèque de l'ESP", place: '', dist: '', target: DirectoryTarget()),
    Place(code: 'SE', name: "Secrétariat de l'ESP", place: '', dist: '', target: RouteTarget(2)),
  ];

  static const List<Place> favorites = <Place>[
    Place(code: '204', name: 'Salle 204', place: 'Génie Informatique · 1er étage', dist: '335 m', target: RouteTarget(0)),
    Place(code: 'BI', name: "Bibliothèque de l'ESP", place: 'Aile nord · face Innodev', dist: '290 m', target: RouteTarget(1)),
    Place(code: 'RE', name: 'Restaurant ESP', place: 'Ouest du terrain', dist: '120 m', target: RouteTarget(1)),
  ];

  // ---- Rooms & timetable --------------------------------------------------

  static const List<String> roomEquipment = <String>[
    'Tableau blanc', 'Vidéoprojecteur', 'Prises secteur', 'Wi-Fi ESP', 'Climatisation',
  ];

  static const List<Course> todaySchedule = <Course>[
    Course(time: '08h — 10h', title: "Systèmes d'exploitation", who: 'M. Diop', room: 'Salle 204 · Génie Info', tint: PmTint.line),
    Course(time: '14h — 16h', title: 'TD Réseaux IP', who: 'Mme Ndiaye · en cours', room: 'Salle 204 · Génie Info', tint: PmTint.blue),
    Course(time: '16h — 18h', title: 'Projet DUT1 Informatique', who: 'Encadré', room: 'Salle DUT1 · Secrétariat', tint: PmTint.brown),
  ];

  static const List<String> weekDays = <String>['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];

  static const List<Course> week = <Course>[
    Course(hour: '08h', duration: '2h00', time: '', title: "Systèmes d'exploitation", who: '', room: 'Salle 204 · Génie Informatique', walk: '5 min à pied', tint: PmTint.brown),
    Course(hour: '10h15', duration: '1h30', time: '', title: 'Mathématiques du signal', who: '', room: 'Amphi Abdoul Aziz Wane', walk: '4 min à pied', tint: PmTint.ochre),
    Course(hour: '14h', duration: '2h00', time: '', title: 'TD Réseaux IP', who: '', room: 'Salle 204 · Génie Informatique', walk: 'Sur place', tint: PmTint.blue),
    Course(hour: '16h', duration: '2h00', time: '', title: 'Projet DUT1 Informatique', who: '', room: 'Salle DUT1 · près du Secrétariat', walk: '6 min à pied', tint: PmTint.brown),
  ];

  // ---- Offline & reporting ------------------------------------------------

  static const List<OfflinePack> offlinePacks = <OfflinePack>[
    OfflinePack('Campus ESP · extérieur', '12 Mo', 'Téléchargé', 1),
    OfflinePack('Plans intérieurs · pavillons', '9 Mo', 'Téléchargé', 1),
    OfflinePack('Repères AR · Génie Informatique', '7 Mo', 'En cours — 64 %', 0.64),
  ];

  static const List<String> issueTypes = <String>[
    'Salle introuvable', 'Mauvais itinéraire', 'Flèche AR décalée', 'Nom incorrect', 'Accès fermé',
  ];
}
