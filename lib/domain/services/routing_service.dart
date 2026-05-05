import 'package:collection/collection.dart';

import 'package:ts_management/data/models/waypoint.dart';

class RouteSegment {
  final int floor;
  final List<Waypoint> nodes;
  final List<String> instructions;
  final double distance;

  RouteSegment({
    required this.floor,
    required this.nodes,
    required this.instructions,
    required this.distance,
  });
}

class ComputedRoute {
  final List<Waypoint> path;
  final List<GraphEdge> edges;
  final List<RouteSegment> segments; // grouped per-floor for UI
  final double totalDistance;

  ComputedRoute({
    required this.path,
    required this.edges,
    required this.segments,
    required this.totalDistance,
  });

  bool get isEmpty => path.isEmpty;
}

class RoutingService {
  /// Dijkstra over the waypoint graph.
  ComputedRoute findRoute(NavigationGraph graph, String startId, String endId) {
    if (startId == endId) {
      return ComputedRoute(
          path: [], edges: [], segments: [], totalDistance: 0);
    }

    final nodesById = {for (final n in graph.nodes) n.id: n};
    if (!nodesById.containsKey(startId) || !nodesById.containsKey(endId)) {
      return ComputedRoute(path: [], edges: [], segments: [], totalDistance: 0);
    }

    // Adjacency list (undirected)
    final adj = <String, List<GraphEdge>>{};
    for (final e in graph.edges) {
      adj.putIfAbsent(e.from, () => []).add(e);
      adj.putIfAbsent(e.to, () => []).add(
          GraphEdge(from: e.to, to: e.from, weight: e.weight, instruction: e.instruction));
    }

    final dist = <String, double>{startId: 0};
    final prev = <String, String>{};
    final prevEdge = <String, GraphEdge>{};
    final visited = <String>{};

    final queue = HeapPriorityQueue<MapEntry<String, double>>(
        (a, b) => a.value.compareTo(b.value));
    queue.add(MapEntry(startId, 0));

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final id = current.key;
      if (!visited.add(id)) continue;
      if (id == endId) break;

      for (final edge in adj[id] ?? const <GraphEdge>[]) {
        final alt = (dist[id] ?? double.infinity) + edge.weight;
        if (alt < (dist[edge.to] ?? double.infinity)) {
          dist[edge.to] = alt;
          prev[edge.to] = id;
          prevEdge[edge.to] = edge;
          queue.add(MapEntry(edge.to, alt));
        }
      }
    }

    if (!prev.containsKey(endId) && startId != endId) {
      return ComputedRoute(path: [], edges: [], segments: [], totalDistance: 0);
    }

    final pathIds = <String>[endId];
    while (pathIds.last != startId) {
      final p = prev[pathIds.last];
      if (p == null) break;
      pathIds.add(p);
    }
    final path = pathIds.reversed.map((id) => nodesById[id]!).toList();
    final edges = <GraphEdge>[];
    for (var i = 1; i < pathIds.length; i++) {
      final e = prevEdge[pathIds.reversed.elementAt(i)];
      if (e != null) edges.add(e);
    }

    final segments = _segmentByFloor(path, edges);
    return ComputedRoute(
      path: path,
      edges: edges,
      segments: segments,
      totalDistance: dist[endId] ?? 0,
    );
  }

  List<RouteSegment> _segmentByFloor(
      List<Waypoint> path, List<GraphEdge> edges) {
    if (path.isEmpty) return [];
    final segments = <RouteSegment>[];
    var currentFloor = path.first.floor;
    var nodeBuf = <Waypoint>[path.first];
    var instrBuf = <String>[];
    var distBuf = 0.0;

    for (var i = 1; i < path.length; i++) {
      final node = path[i];
      final edge = edges[i - 1];
      distBuf += edge.weight;
      final instr = edge.instruction ?? _fallbackInstruction(path[i - 1], node);
      instrBuf.add(instr);
      nodeBuf.add(node);

      if (node.floor != currentFloor) {
        segments.add(RouteSegment(
          floor: currentFloor,
          nodes: List.of(nodeBuf),
          instructions: List.of(instrBuf),
          distance: distBuf,
        ));
        currentFloor = node.floor;
        nodeBuf = [node];
        instrBuf = [];
        distBuf = 0;
      }
    }
    segments.add(RouteSegment(
      floor: currentFloor,
      nodes: nodeBuf,
      instructions: instrBuf,
      distance: distBuf,
    ));
    return segments;
  }

  String _fallbackInstruction(Waypoint a, Waypoint b) {
    if (a.floor != b.floor) {
      return b.type == WaypointType.elevator
          ? 'Take the elevator to floor ${b.floor}'
          : 'Take the stairs to floor ${b.floor}';
    }
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    if (dx.abs() > dy.abs()) {
      return dx > 0 ? 'Walk right' : 'Walk left';
    } else {
      return dy > 0 ? 'Walk forward' : 'Walk back';
    }
  }
}
