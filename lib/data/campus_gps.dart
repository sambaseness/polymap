import 'package:latlong2/latlong.dart';

/// Real GPS coordinates for ESP Dakar buildings.
///
/// ESP Dakar is part of Université Cheikh Anta Diop (UCAD) in Dakar, Senegal.
/// These coordinates are approximate based on satellite imagery and campus maps.
/// The campus is located at approximately 14.6928° N, -17.4467° W.
abstract final class CampusGps {
  // Campus center (approximate)
  static final LatLng campusCenter = LatLng(14.6928, -17.4467);

  // Campus bounds for initial map view (approximate)
  static final LatLng campusNorthWest = LatLng(14.6935, -17.4475);
  static final LatLng campusSouthEast = LatLng(14.6918, -17.4455);

  /// Building GPS coordinates with name and short label.
  /// Format: (name, short, latitude, longitude)
  static final List<BuildingGps> buildings = <BuildingGps>[
    // Northern buildings
    BuildingGps(
      name: 'Innodev',
      short: 'Innodev',
      position: LatLng(14.6934, -17.4472),
      color: BuildingColor.blue,
    ),
    BuildingGps(
      name: "Bibliothèque de l'ESP",
      short: 'Biblio.\nESP',
      position: LatLng(14.6930, -17.4471),
      color: BuildingColor.blue,
    ),
    BuildingGps(
      name: 'Amphithéâtre Abdoul Aziz Wane',
      short: 'Amphi\nA.A. Wane',
      position: LatLng(14.6933, -17.4465),
      color: BuildingColor.brown,
    ),
    BuildingGps(
      name: "Secrétariat de l'ESP",
      short: 'Secrétariat',
      position: LatLng(14.6932, -17.4460),
      color: BuildingColor.brown,
    ),
    BuildingGps(
      name: 'Salle DUT1 Informatique',
      short: 'DUT1 Info',
      position: LatLng(14.6927, -17.4460),
      color: BuildingColor.blue,
    ),
    BuildingGps(
      name: 'Département Génie Chimique',
      short: 'Génie\nChimique',
      position: LatLng(14.6929, -17.4453),
      color: BuildingColor.blue,
    ),
    BuildingGps(
      name: 'Département Génie Électrique',
      short: 'Génie\nÉlectrique',
      position: LatLng(14.6925, -17.4453),
      color: BuildingColor.blue,
    ),
    BuildingGps(
      name: 'CEPECS',
      short: 'CEPECS',
      position: LatLng(14.6922, -17.4471),
      color: BuildingColor.blue,
    ),
    BuildingGps(
      name: 'Département Génie Informatique',
      short: 'Génie\nInformatique',
      position: LatLng(14.6919, -17.4470),
      color: BuildingColor.blue,
    ),
    BuildingGps(
      name: 'Terrain de sport',
      short: 'Terrain',
      position: LatLng(14.6918, -17.4462),
      color: BuildingColor.green,
    ),
    BuildingGps(
      name: 'Labo LER',
      short: 'Labo LER',
      position: LatLng(14.6923, -17.4460),
      color: BuildingColor.blue,
    ),
    BuildingGps(
      name: 'Département Génie Civil',
      short: 'Génie Civil',
      position: LatLng(14.6920, -17.4455),
      color: BuildingColor.blue,
    ),
    BuildingGps(
      name: 'Restaurant ESP',
      short: 'Resto\nESP',
      position: LatLng(14.6915, -17.4471),
      color: BuildingColor.ochre,
    ),
    // Pavillons (residences)
    BuildingGps(
      name: 'Pavillon F',
      short: 'Pav. F',
      position: LatLng(14.6910, -17.4472),
      color: BuildingColor.brown,
    ),
    BuildingGps(
      name: 'Pavillon G',
      short: 'Pav. G',
      position: LatLng(14.6907, -17.4473),
      color: BuildingColor.brown,
    ),
    BuildingGps(
      name: 'Pavillon B',
      short: 'Pav. B',
      position: LatLng(14.6908, -17.4467),
      color: BuildingColor.brown,
    ),
    BuildingGps(
      name: 'Salle de télévision',
      short: 'Salle télé',
      position: LatLng(14.6910, -17.4462),
      color: BuildingColor.brown,
    ),
    BuildingGps(
      name: "Mosquée de l'ESP",
      short: 'Mosquée',
      position: LatLng(14.6910, -17.4457),
      color: BuildingColor.brown,
    ),
    BuildingGps(
      name: 'Pavillon A',
      short: 'Pav. A',
      position: LatLng(14.6907, -17.4460),
      color: BuildingColor.brown,
    ),
    BuildingGps(
      name: 'Pavillon C',
      short: 'Pav. C',
      position: LatLng(14.6904, -17.4467),
      color: BuildingColor.brown,
    ),
    BuildingGps(
      name: 'Pavillon E',
      short: 'Pav. E',
      position: LatLng(14.6904, -17.4460),
      color: BuildingColor.brown,
    ),
    BuildingGps(
      name: 'Parking AUF',
      short: 'P. AUF',
      position: LatLng(14.6904, -17.4474),
      color: BuildingColor.brown,
    ),
  ];

  /// User's current position (Pavillon C entrance)
  static final LatLng userPosition = LatLng(14.6904, -17.4467);

  /// Route GPS coordinates (Pavillon C → Génie Informatique)
  static final List<LatLng> route1Walk = [
    const LatLng(14.6904, -17.4467), // Pavillon C
    const LatLng(14.6907, -17.4465),
    const LatLng(14.6910, -17.4463),
    const LatLng(14.6913, -17.4465),
    const LatLng(14.6916, -17.4468),
    const LatLng(14.6919, -17.4470), // Génie Informatique
  ];

  static final List<LatLng> route1Accessible = [
    const LatLng(14.6904, -17.4467),
    const LatLng(14.6906, -17.4468),
    const LatLng(14.6909, -17.4469),
    const LatLng(14.6912, -17.4468),
    const LatLng(14.6915, -17.4469),
    const LatLng(14.6919, -17.4470),
  ];

  static final List<LatLng> route1Shortest = [
    const LatLng(14.6904, -17.4467),
    const LatLng(14.6908, -17.4466),
    const LatLng(14.6912, -17.4468),
    const LatLng(14.6919, -17.4470),
  ];
}

/// Building color matching the design system.
enum BuildingColor { blue, brown, ochre, green }

/// Building with GPS coordinates for the real map.
class BuildingGps {
  const BuildingGps({
    required this.name,
    required this.short,
    required this.position,
    required this.color,
  });

  final String name;
  final String short;
  final LatLng position;
  final BuildingColor color;
}
