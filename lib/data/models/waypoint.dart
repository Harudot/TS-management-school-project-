enum WaypointType {
  room,
  stairs,
  elevator,
  entrance,
  junction;

  static WaypointType parse(String? v) =>
      WaypointType.values.firstWhere((e) => e.name == v,
          orElse: () => WaypointType.junction);
}

class Waypoint {
  final String id;
  final int floor;
  final double x;
  final double y;
  final WaypointType type;
  final String label;

  Waypoint({
    required this.id,
    required this.floor,
    required this.x,
    required this.y,
    this.type = WaypointType.junction,
    this.label = '',
  });

  factory Waypoint.fromMap(Map<String, dynamic> m) => Waypoint(
        id: (m['id'] ?? '') as String,
        floor: (m['floor'] ?? 1) as int,
        x: (m['x'] ?? 0).toDouble(),
        y: (m['y'] ?? 0).toDouble(),
        type: WaypointType.parse(m['type'] as String?),
        label: (m['label'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'floor': floor,
        'x': x,
        'y': y,
        'type': type.name,
        'label': label,
      };
}

class GraphEdge {
  final String from;
  final String to;
  final double weight;
  final String? instruction;

  GraphEdge({
    required this.from,
    required this.to,
    this.weight = 1,
    this.instruction,
  });

  factory GraphEdge.fromMap(Map<String, dynamic> m) => GraphEdge(
        from: (m['from'] ?? '') as String,
        to: (m['to'] ?? '') as String,
        weight: (m['weight'] ?? 1).toDouble(),
        instruction: m['instruction'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'from': from,
        'to': to,
        'weight': weight,
        'instruction': instruction,
      };
}

class NavigationGraph {
  final List<Waypoint> nodes;
  final List<GraphEdge> edges;

  NavigationGraph({required this.nodes, required this.edges});

  factory NavigationGraph.fromMap(Map<String, dynamic> m) => NavigationGraph(
        nodes: ((m['nodes'] ?? []) as List)
            .map((e) => Waypoint.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        edges: ((m['edges'] ?? []) as List)
            .map((e) => GraphEdge.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'nodes': nodes.map((e) => e.toMap()).toList(),
        'edges': edges.map((e) => e.toMap()).toList(),
      };
}

class StartPoint {
  final String id;
  final String name;
  final int floor;
  final String waypointId;
  final String? photoUrl;

  StartPoint({
    required this.id,
    required this.name,
    required this.floor,
    required this.waypointId,
    this.photoUrl,
  });

  factory StartPoint.fromMap(String id, Map<String, dynamic> m) => StartPoint(
        id: id,
        name: (m['name'] ?? '') as String,
        floor: (m['floor'] ?? 1) as int,
        waypointId: (m['waypointId'] ?? '') as String,
        photoUrl: m['photoUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'floor': floor,
        'waypointId': waypointId,
        'photoUrl': photoUrl,
      };
}
