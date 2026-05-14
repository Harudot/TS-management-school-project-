import 'package:collection/collection.dart';

import 'package:ts_management/data/models/waypoint.dart';

class BilingualStep {
  final String mn;
  final String en;
  const BilingualStep(this.mn, this.en);
}

class RouteSegment {
  final int floor;
  final List<Waypoint> nodes;
  final List<String> instructions; // English (legacy)
  final List<BilingualStep> steps;
  final double distance;

  RouteSegment({
    required this.floor,
    required this.nodes,
    required this.instructions,
    required this.steps,
    required this.distance,
  });
}

class ComputedRoute {
  final List<Waypoint> path;
  final List<GraphEdge> edges;
  final List<RouteSegment> segments;
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
  ComputedRoute findRoute(NavigationGraph graph, String startId, String endId) {
    if (startId == endId) {
      return ComputedRoute(
          path: [], edges: [], segments: [], totalDistance: 0);
    }

    final nodesById = {for (final n in graph.nodes) n.id: n};
    if (!nodesById.containsKey(startId) || !nodesById.containsKey(endId)) {
      return ComputedRoute(path: [], edges: [], segments: [], totalDistance: 0);
    }

    final adj = <String, List<GraphEdge>>{};
    for (final e in graph.edges) {
      adj.putIfAbsent(e.from, () => []).add(e);
      adj.putIfAbsent(e.to, () => []).add(GraphEdge(
          from: e.to, to: e.from, weight: e.weight, instruction: e.instruction));
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
    return ComputedRoute(
      path: path,
      edges: edges,
      segments: _segmentByFloor(path, edges),
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
    var stepBuf = <BilingualStep>[];
    var distBuf = 0.0;

    for (var i = 1; i < path.length; i++) {
      final node = path[i];
      final edge = edges[i - 1];
      distBuf += edge.weight;
      final step = _stepFor(path[i - 1], node, edge);
      instrBuf.add(step.en);
      stepBuf.add(step);
      nodeBuf.add(node);

      if (node.floor != currentFloor) {
        segments.add(RouteSegment(
          floor: currentFloor,
          nodes: List.of(nodeBuf),
          instructions: List.of(instrBuf),
          steps: List.of(stepBuf),
          distance: distBuf,
        ));
        currentFloor = node.floor;
        nodeBuf = [node];
        instrBuf = [];
        stepBuf = [];
        distBuf = 0;
      }
    }
    segments.add(RouteSegment(
      floor: currentFloor,
      nodes: nodeBuf,
      instructions: instrBuf,
      steps: stepBuf,
      distance: distBuf,
    ));
    return segments;
  }

  BilingualStep _stepFor(Waypoint a, Waypoint b, GraphEdge edge) {
    if (a.floor != b.floor) {
      if (b.type == WaypointType.elevator) {
        return BilingualStep(
          'Лифтээр ${b.floor}-р давхар руу яв',
          'Take the elevator to floor ${b.floor}',
        );
      }
      return BilingualStep(
        'Шатаар ${b.floor}-р давхар руу яв',
        'Take the stairs to floor ${b.floor}',
      );
    }
    if (edge.instruction != null && edge.instruction!.isNotEmpty) {
      return BilingualStep(edge.instruction!, edge.instruction!);
    }
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final meters = (edge.weight).round();
    if (dx.abs() > dy.abs()) {
      // east (У) / west (З)
      if (dx > 0) {
        return BilingualStep(
          'Баруун тийш ${meters}м яв',
          'Walk right ~${meters}m',
        );
      }
      return BilingualStep(
        'Зүүн тийш ${meters}м яв',
        'Walk left ~${meters}m',
      );
    } else {
      // north (ТА) / south (Б)
      if (dy < 0) {
        return BilingualStep(
          'Урагш ${meters}м яв',
          'Walk forward ~${meters}m',
        );
      }
      return BilingualStep(
        'Хойш ${meters}м яв',
        'Walk back ~${meters}m',
      );
    }
  }
}
