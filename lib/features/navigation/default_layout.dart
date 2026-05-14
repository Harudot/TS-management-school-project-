import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/models/waypoint.dart';

/// View-space dimensions used when no explicit floor doc width/height exist.
/// Matches the seeded `width: 1000, height: 700` in [seed-building.js].
const double kFloorViewWidth = 1000;
const double kFloorViewHeight = 700;

/// Floors that should be visible in the building map. We deliberately omit
/// floor 0 (basement) per product decision — it is not surfaced in the UI.
bool isVisibleFloor(int floor) => floor >= 1;

class FloorLayoutResult {
  FloorLayoutResult({
    required this.nodes,
    required this.edges,
    required this.rooms,
  });

  final List<Waypoint> nodes;
  final List<GraphEdge> edges;
  final List<RoomDoc> rooms;
}

/// Synthesise a clean architectural floor layout from the existing rooms list.
///
/// The seed data only stores room metadata (number, name, type) — there is no
/// per-room (x, y). This function arranges rooms in two rows around a central
/// corridor in number order, places stairs on each end, an elevator on the
/// right, and an entrance node on floor 1, mirroring the rough shape of the
/// PDF floor plan.
///
/// Returns the merged set of nodes/edges/rooms for the floor. If the caller
/// already has waypoints positioned in Firestore for a room, they take
/// precedence; this function is used as a fallback when [graph] lacks an entry
/// for a room.
FloorLayoutResult buildSyntheticFloor({
  required int floor,
  required List<RoomDoc> rooms,
  NavigationGraph? existingGraph,
  double width = kFloorViewWidth,
  double height = kFloorViewHeight,
}) {
  final byWaypointId = {
    for (final n in (existingGraph?.nodes ?? const <Waypoint>[])) n.id: n,
  };

  // Sort rooms by their leading number. Some seed rooms have suffixes like
  // "306-А" — the regex pulls out the leading integer.
  final sorted = [...rooms]..sort((a, b) {
      final ai = _leadingInt(a.number);
      final bi = _leadingInt(b.number);
      if (ai != bi) return ai.compareTo(bi);
      return a.number.compareTo(b.number);
    });

  // 2-row grid of rooms around a central corridor.
  // Top row: y = 140, bottom row: y = 560. Corridor band: y = 350.
  const topY = 140.0;
  const bottomY = 560.0;
  const corridorY = 350.0;
  const marginX = 80.0;
  final cols = (sorted.length / 2).ceil().clamp(1, 1000).toInt();
  final spanX = (width - marginX * 2);
  final stepX = cols <= 1 ? 0.0 : spanX / (cols - 1);

  final nodes = <Waypoint>[];
  final edges = <GraphEdge>[];
  final positionedRooms = <RoomDoc>[];

  // Build a corridor spine. We place corridor anchor nodes evenly across
  // the centre line so we can connect rooms to the closest spine node.
  final spineCount = cols.clamp(2, 8);
  final spineStepX = spineCount <= 1 ? 0.0 : spanX / (spineCount - 1);
  final spineNodes = <Waypoint>[];
  for (var i = 0; i < spineCount; i++) {
    final x = marginX + i * spineStepX;
    final id = 'wp_${floor}_corridor_$i';
    final n = Waypoint(
      id: id,
      floor: floor,
      x: x,
      y: corridorY,
      type: WaypointType.junction,
      label: 'Corridor F$floor',
    );
    spineNodes.add(n);
    nodes.add(n);
    if (i > 0) {
      edges.add(GraphEdge(
        from: spineNodes[i - 1].id,
        to: n.id,
        weight: spineStepX,
        instruction: 'Walk along the corridor',
      ));
    }
  }

  for (var i = 0; i < sorted.length; i++) {
    final room = sorted[i];
    final col = i ~/ 2;
    final row = i.isEven ? 0 : 1; // even index → top, odd → bottom
    final x = marginX + (cols <= 1 ? spanX / 2 : col * stepX);
    final y = row == 0 ? topY : bottomY;

    final wpId = room.waypointId.isEmpty ? 'wp_${room.id}' : room.waypointId;

    Waypoint wp;
    if (byWaypointId.containsKey(wpId) && byWaypointId[wpId]!.x != 0) {
      wp = byWaypointId[wpId]!;
    } else {
      wp = Waypoint(
        id: wpId,
        floor: floor,
        x: x,
        y: y,
        type: WaypointType.room,
        label: '${room.number} ${room.name}',
      );
    }
    nodes.add(wp);
    positionedRooms.add(room.copyWith(waypointId: wp.id));

    // Connect each room to the closest corridor spine node.
    final closest = spineNodes.reduce((a, b) =>
        ((a.x - wp.x).abs() < (b.x - wp.x).abs()) ? a : b);
    edges.add(GraphEdge(
      from: wp.id,
      to: closest.id,
      weight: (wp.y - corridorY).abs(),
      instruction: 'Walk to corridor',
    ));
  }

  // Stairs at both ends of the corridor.
  final stairsLeft = Waypoint(
    id: 'wp_${floor}_stairs_w',
    floor: floor,
    x: marginX - 30,
    y: corridorY,
    type: WaypointType.stairs,
    label: 'West stairs F$floor',
  );
  final stairsRight = Waypoint(
    id: 'wp_${floor}_stairs_e',
    floor: floor,
    x: width - marginX + 30,
    y: corridorY,
    type: WaypointType.stairs,
    label: 'East stairs F$floor',
  );
  nodes.addAll([stairsLeft, stairsRight]);
  edges.addAll([
    GraphEdge(
        from: stairsLeft.id,
        to: spineNodes.first.id,
        weight: 30,
        instruction: 'Step away from west stairs'),
    GraphEdge(
        from: stairsRight.id,
        to: spineNodes.last.id,
        weight: 30,
        instruction: 'Step away from east stairs'),
  ]);

  // Elevator on the right side.
  final elevator = Waypoint(
    id: 'wp_${floor}_elevator',
    floor: floor,
    x: width - marginX + 30,
    y: corridorY + 80,
    type: WaypointType.elevator,
    label: 'Elevator F$floor',
  );
  nodes.add(elevator);
  edges.add(GraphEdge(
      from: elevator.id,
      to: spineNodes.last.id,
      weight: 80,
      instruction: 'Walk to elevator'));

  // Per-floor named entry waypoints.
  if (floor == 1) {
    final entrance = Waypoint(
      id: 'wp_1_main_gate',
      floor: 1,
      x: width / 2,
      y: bottomY + 80,
      type: WaypointType.entrance,
      label: 'Сургуулын төв хаалга',
    );
    nodes.add(entrance);
    final mid = spineNodes[spineNodes.length ~/ 2];
    edges.add(GraphEdge(
        from: entrance.id,
        to: mid.id,
        weight: 80,
        instruction: 'Enter through the main gate and walk forward'));
  }

  return FloorLayoutResult(
    nodes: nodes,
    edges: edges,
    rooms: positionedRooms,
  );
}

int _leadingInt(String s) {
  final m = RegExp(r'^(\d+)').firstMatch(s);
  if (m == null) return 0;
  return int.tryParse(m.group(1)!) ?? 0;
}

/// Default per-floor entry start points for any building. These are surfaced
/// when Firestore has no `start_points/{building}/points` collection.
List<StartPoint> defaultStartPoints(NavigationGraph graph,
    {List<RoomDoc> rooms = const []}) {
  final out = <StartPoint>[];

  // Floor 1: main gate entrance
  final gate = graph.nodes.firstWhere(
    (n) => n.floor == 1 && n.type == WaypointType.entrance,
    orElse: () => graph.nodes.firstWhere(
      (n) => n.floor == 1,
      orElse: () => Waypoint(
          id: 'wp_1_main_gate', floor: 1, x: 500, y: 640),
    ),
  );
  out.add(StartPoint(
    id: 'sp_main_gate',
    name: 'Сургуулын төв хаалга',
    floor: 1,
    waypointId: gate.id,
  ));

  // Floor 2: Хүндэтгэлийн танхим — bind to the room with that name if seeded,
  // else any floor-2 corridor anchor.
  final hall = rooms.firstWhere(
    (r) => r.floor == 2 && r.name.contains('Хүндэтгэлийн'),
    orElse: () => RoomDoc(
        id: '_synthetic_hall',
        number: '227',
        floor: 2,
        name: 'Хүндэтгэлийн танхим',
        waypointId: 'wp_2_corridor_2'),
  );
  // Make sure that waypoint exists in the graph; otherwise fall back to
  // a floor-2 corridor anchor.
  final hallWp = graph.nodes.firstWhere(
    (n) => n.id == hall.waypointId,
    orElse: () => graph.nodes.firstWhere(
      (n) => n.floor == 2,
      orElse: () => Waypoint(id: 'wp_2_corridor_0', floor: 2, x: 500, y: 350),
    ),
  );
  out.add(StartPoint(
    id: 'sp_hundetgel',
    name: 'Хүндэтгэлийн танхим',
    floor: 2,
    waypointId: hallWp.id,
  ));

  // Floor 3: generic floor-3 entry point
  final f3 = graph.nodes.firstWhere(
    (n) => n.floor == 3 && n.type == WaypointType.stairs,
    orElse: () => graph.nodes.firstWhere(
      (n) => n.floor == 3,
      orElse: () => Waypoint(id: 'wp_3_corridor_0', floor: 3, x: 500, y: 350),
    ),
  );
  out.add(StartPoint(
    id: 'sp_floor3_start',
    name: '3 давхарын эхлэх цэг',
    floor: 3,
    waypointId: f3.id,
  ));

  return out;
}

/// Build a fallback graph from a flat list of rooms, covering all visible
/// floors. Cross-floor edges connect the same-named stair/elevator nodes
/// across consecutive floors.
NavigationGraph buildSyntheticGraph(List<RoomDoc> rooms) {
  final allFloors = rooms
      .map((r) => r.floor)
      .where(isVisibleFloor)
      .toSet()
      .toList()
    ..sort();
  final allNodes = <Waypoint>[];
  final allEdges = <GraphEdge>[];

  for (final f in allFloors) {
    final result = buildSyntheticFloor(
      floor: f,
      rooms: rooms.where((r) => r.floor == f).toList(),
    );
    allNodes.addAll(result.nodes);
    allEdges.addAll(result.edges);
  }

  // Cross-floor edges: stairs on each end + elevator.
  for (var i = 0; i < allFloors.length - 1; i++) {
    final a = allFloors[i];
    final b = allFloors[i + 1];
    allEdges.add(GraphEdge(
        from: 'wp_${a}_stairs_w',
        to: 'wp_${b}_stairs_w',
        weight: 30,
        instruction: 'Take the west stairs to floor $b'));
    allEdges.add(GraphEdge(
        from: 'wp_${a}_stairs_e',
        to: 'wp_${b}_stairs_e',
        weight: 30,
        instruction: 'Take the east stairs to floor $b'));
    allEdges.add(GraphEdge(
        from: 'wp_${a}_elevator',
        to: 'wp_${b}_elevator',
        weight: 25,
        instruction: 'Take the elevator to floor $b'));
  }

  return NavigationGraph(nodes: allNodes, edges: allEdges);
}

/// Re-order rooms so each room.waypointId points to a node that exists in
/// [graph]. This keeps the renderer in sync after we synthesise positions.
List<RoomDoc> reconcileRoomsToGraph(
    List<RoomDoc> rooms, NavigationGraph graph) {
  final byId = {for (final n in graph.nodes) n.id: n};
  return rooms.map((r) {
    if (byId.containsKey(r.waypointId)) return r;
    final candidate = graph.nodes
        .firstWhere((n) => n.id == 'wp_${r.id}', orElse: () => graph.nodes.first);
    return r.copyWith(waypointId: candidate.id);
  }).toList();
}
