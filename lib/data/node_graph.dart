import 'package:latlong2/latlong.dart';

/// Node graph for indoor positioning and navigation.
///
/// Each node represents a waypoint in the building (door, corridor intersection,
/// stairs, etc.). Edges connect nodes with walkable paths.
///
/// The graph is used by the AR system to:
/// 1. Determine user position from QR code scans
/// 2. Calculate routes between nodes
/// 3. Place AR arrows along the path
/// 4. Show door labels at the correct positions
abstract final class NodeGraph {
  /// All nodes in the campus graph.
  static final List<Node> nodes = [
    // === PAVILLON C ===
    // Ground floor (RDC)
    Node(
      id: 'C-RDC-ENTRANCE',
      building: 'Pavillon C',
      floor: 0,
      name: 'Entrée Pavillon C',
      position: const LatLng(14.6904, -17.4467),
      connections: ['C-RDC-CORRIDOR-1', 'C-EXT-NORTH'],
      type: NodeType.entrance,
    ),
    Node(
      id: 'C-RDC-CORRIDOR-1',
      building: 'Pavillon C',
      floor: 0,
      name: 'Couloir RDC - Bout',
      position: const LatLng(14.69042, -17.44668),
      connections: ['C-RDC-ENTRANCE', 'C-RDC-CORRIDOR-2', 'C-RDC-STAIRS-B'],
      type: NodeType.corridor,
    ),
    Node(
      id: 'C-RDC-CORRIDOR-2',
      building: 'Pavillon C',
      floor: 0,
      name: 'Couloir RDC - Milieu',
      position: const LatLng(14.69044, -17.44666),
      connections: ['C-RDC-CORRIDOR-1', 'C-RDC-001', 'C-RDC-002', 'C-RDC-CORRIDOR-3'],
      type: NodeType.corridor,
    ),
    Node(
      id: 'C-RDC-CORRIDOR-3',
      building: 'Pavillon C',
      floor: 0,
      name: 'Couloir RDC - Fin',
      position: const LatLng(14.69046, -17.44664),
      connections: ['C-RDC-CORRIDOR-2', 'C-RDC-003', 'C-RDC-004'],
      type: NodeType.corridor,
    ),
    Node(
      id: 'C-RDC-001',
      building: 'Pavillon C',
      floor: 0,
      name: 'Salle C-001',
      position: const LatLng(14.69043, -17.44667),
      connections: ['C-RDC-CORRIDOR-2'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-RDC-002',
      building: 'Pavillon C',
      floor: 0,
      name: 'Salle C-002',
      position: const LatLng(14.69045, -17.44665),
      connections: ['C-RDC-CORRIDOR-2'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-RDC-003',
      building: 'Pavillon C',
      floor: 0,
      name: 'Salle C-003',
      position: const LatLng(14.69047, -17.44663),
      connections: ['C-RDC-CORRIDOR-3'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-RDC-004',
      building: 'Pavillon C',
      floor: 0,
      name: 'Salle C-004',
      position: const LatLng(14.69049, -17.44661),
      connections: ['C-RDC-CORRIDOR-3'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-RDC-STAIRS-B',
      building: 'Pavillon C',
      floor: 0,
      name: 'Escalier B (RDC)',
      position: const LatLng(14.69041, -17.44669),
      connections: ['C-RDC-CORRIDOR-1', 'C-R1-STAIRS-B'],
      type: NodeType.stairs,
    ),

    // 1st floor (R+1)
    Node(
      id: 'C-R1-ENTRANCE',
      building: 'Pavillon C',
      floor: 1,
      name: 'Entrée R+1',
      position: const LatLng(14.6904, -17.4467),
      connections: ['C-R1-CORRIDOR-1'],
      type: NodeType.entrance,
    ),
    Node(
      id: 'C-R1-CORRIDOR-1',
      building: 'Pavillon C',
      floor: 1,
      name: 'Couloir R+1 - Bout',
      position: const LatLng(14.69042, -17.44668),
      connections: ['C-R1-ENTRANCE', 'C-R1-CORRIDOR-2', 'C-R1-STAIRS-B'],
      type: NodeType.corridor,
    ),
    Node(
      id: 'C-R1-CORRIDOR-2',
      building: 'Pavillon C',
      floor: 1,
      name: 'Couloir R+1 - Milieu',
      position: const LatLng(14.69044, -17.44666),
      connections: ['C-R1-CORRIDOR-1', 'C-R1-101', 'C-R1-102', 'C-R1-CORRIDOR-3'],
      type: NodeType.corridor,
    ),
    Node(
      id: 'C-R1-CORRIDOR-3',
      building: 'Pavillon C',
      floor: 1,
      name: 'Couloir R+1 - Fin',
      position: const LatLng(14.69046, -17.44664),
      connections: ['C-R1-CORRIDOR-2', 'C-R1-104', 'C-R1-107'],
      type: NodeType.corridor,
    ),
    Node(
      id: 'C-R1-101',
      building: 'Pavillon C',
      floor: 1,
      name: 'Salle C-101',
      position: const LatLng(14.69043, -17.44667),
      connections: ['C-R1-CORRIDOR-2'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-R1-102',
      building: 'Pavillon C',
      floor: 1,
      name: 'Salle C-102',
      position: const LatLng(14.69045, -17.44665),
      connections: ['C-R1-CORRIDOR-2'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-R1-104',
      building: 'Pavillon C',
      floor: 1,
      name: 'Salle C-104',
      position: const LatLng(14.69047, -17.44663),
      connections: ['C-R1-CORRIDOR-3'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-R1-107',
      building: 'Pavillon C',
      floor: 1,
      name: 'Salle C-107 (TD)',
      position: const LatLng(14.69049, -17.44661),
      connections: ['C-R1-CORRIDOR-3'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-R1-STAIRS-B',
      building: 'Pavillon C',
      floor: 1,
      name: 'Escalier B (R+1)',
      position: const LatLng(14.69041, -17.44669),
      connections: ['C-R1-CORRIDOR-1', 'C-RDC-STAIRS-B', 'C-R2-STAIRS-B'],
      type: NodeType.stairs,
    ),

    // 2nd floor (R+2)
    Node(
      id: 'C-R2-ENTRANCE',
      building: 'Pavillon C',
      floor: 2,
      name: 'Entrée R+2',
      position: const LatLng(14.6904, -17.4467),
      connections: ['C-R2-CORRIDOR-1'],
      type: NodeType.entrance,
    ),
    Node(
      id: 'C-R2-CORRIDOR-1',
      building: 'Pavillon C',
      floor: 2,
      name: 'Couloir R+2 - Bout',
      position: const LatLng(14.69042, -17.44668),
      connections: ['C-R2-ENTRANCE', 'C-R2-CORRIDOR-2', 'C-R2-STAIRS-B'],
      type: NodeType.corridor,
    ),
    Node(
      id: 'C-R2-CORRIDOR-2',
      building: 'Pavillon C',
      floor: 2,
      name: 'Couloir R+2 - Milieu',
      position: const LatLng(14.69044, -17.44666),
      connections: ['C-R2-CORRIDOR-1', 'C-R2-201', 'C-R2-203', 'C-R2-CORRIDOR-3'],
      type: NodeType.corridor,
    ),
    Node(
      id: 'C-R2-CORRIDOR-3',
      building: 'Pavillon C',
      floor: 2,
      name: 'Couloir R+2 - Fin',
      position: const LatLng(14.69046, -17.44664),
      connections: ['C-R2-CORRIDOR-2', 'C-R2-205', 'C-R2-208'],
      type: NodeType.corridor,
    ),
    Node(
      id: 'C-R2-201',
      building: 'Pavillon C',
      floor: 2,
      name: 'Salle C-201',
      position: const LatLng(14.69043, -17.44667),
      connections: ['C-R2-CORRIDOR-2'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-R2-203',
      building: 'Pavillon C',
      floor: 2,
      name: 'Salle C-203',
      position: const LatLng(14.69045, -17.44665),
      connections: ['C-R2-CORRIDOR-2'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-R2-205',
      building: 'Pavillon C',
      floor: 2,
      name: 'Salle C-205',
      position: const LatLng(14.69047, -17.44663),
      connections: ['C-R2-CORRIDOR-3'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-R2-208',
      building: 'Pavillon C',
      floor: 2,
      name: 'Salle C-208',
      position: const LatLng(14.69049, -17.44661),
      connections: ['C-R2-CORRIDOR-3'],
      type: NodeType.room,
    ),
    Node(
      id: 'C-R2-STAIRS-B',
      building: 'Pavillon C',
      floor: 2,
      name: 'Escalier B (R+2)',
      position: const LatLng(14.69041, -17.44669),
      connections: ['C-R2-CORRIDOR-1', 'C-R1-STAIRS-B'],
      type: NodeType.stairs,
    ),

    // === EXTERIOR NODES ===
    Node(
      id: 'C-EXT-NORTH',
      building: 'Extérieur',
      floor: 0,
      name: 'Extérieur Nord Pavillon C',
      position: const LatLng(14.6905, -17.4467),
      connections: ['C-RDC-ENTRANCE', 'GI-ENTRANCE'],
      type: NodeType.exterior,
    ),
    Node(
      id: 'GI-ENTRANCE',
      building: 'Génie Informatique',
      floor: 0,
      name: 'Entrée Génie Informatique',
      position: const LatLng(14.6919, -17.4470),
      connections: ['C-EXT-NORTH'],
      type: NodeType.entrance,
    ),
  ];

  /// Find a node by ID.
  static Node? findNode(String id) {
    try {
      return nodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Find all nodes for a building.
  static List<Node> nodesInBuilding(String building) {
    return nodes.where((n) => n.building == building).toList();
  }

  /// Find all nodes on a specific floor of a building.
  static List<Node> nodesOnFloor(String building, int floor) {
    return nodes.where((n) => n.building == building && n.floor == floor).toList();
  }

  /// Calculate distance between two nodes in meters.
  static double distanceBetween(Node a, Node b) {
    const distance = Distance();
    return distance.as(LengthUnit.Meter, a.position, b.position);
  }

  /// Find the shortest path between two nodes using Dijkstra's algorithm.
  static List<Node>? findPath(String startId, String endId) {
    final start = findNode(startId);
    final end = findNode(endId);
    if (start == null || end == null) return null;

    // Dijkstra's algorithm
    final distances = <String, double>{};
    final previous = <String, String?>{};
    final unvisited = <String>{};

    for (final node in nodes) {
      distances[node.id] = double.infinity;
      previous[node.id] = null;
      unvisited.add(node.id);
    }

    distances[startId] = 0;

    while (unvisited.isNotEmpty) {
      // Find unvisited node with smallest distance
      String? currentId;
      double minDist = double.infinity;
      for (final id in unvisited) {
        if (distances[id]! < minDist) {
          minDist = distances[id]!;
          currentId = id;
        }
      }

      if (currentId == null || currentId == endId) break;
      unvisited.remove(currentId);

      final current = findNode(currentId);
      if (current == null) continue;

      for (final neighborId in current.connections) {
        if (!unvisited.contains(neighborId)) continue;

        final neighbor = findNode(neighborId);
        if (neighbor == null) continue;

        final alt = distances[currentId]! + distanceBetween(current, neighbor);
        if (alt < distances[neighborId]!) {
          distances[neighborId] = alt;
          previous[neighborId] = currentId;
        }
      }
    }

    // Reconstruct path
    final path = <Node>[];
    String? currentId = endId;
    while (currentId != null) {
      final node = findNode(currentId);
      if (node == null) break;
      path.insert(0, node);
      currentId = previous[currentId];
    }

    if (path.isEmpty || path.first.id != startId) return null;
    return path;
  }
}

/// Types of nodes in the graph.
enum NodeType {
  entrance,
  corridor,
  room,
  stairs,
  elevator,
  exterior,
}

/// A node in the indoor positioning graph.
class Node {
  const Node({
    required this.id,
    required this.building,
    required this.floor,
    required this.name,
    required this.position,
    required this.connections,
    required this.type,
  });

  /// Unique identifier (e.g., "C-RDC-001").
  final String id;

  /// Building name (e.g., "Pavillon C").
  final String building;

  /// Floor number (0 = RDC, 1 = R+1, 2 = R+2).
  final int floor;

  /// Human-readable name (e.g., "Salle C-001").
  final String name;

  /// GPS coordinates.
  final LatLng position;

  /// IDs of connected nodes.
  final List<String> connections;

  /// Node type.
  final NodeType type;

  /// Whether this node is accessible (no stairs).
  bool get isAccessible => type != NodeType.stairs;

  @override
  String toString() => 'Node($id: $name)';
}
