import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/core/theme/app_theme.dart';
import 'package:ts_management/data/models/building.dart';
import 'package:ts_management/data/models/person.dart';
import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/models/waypoint.dart';
import 'package:ts_management/data/repositories/repositories.dart';
import 'package:ts_management/features/navigation/default_layout.dart';
import 'package:ts_management/features/navigation/floor_painter.dart';
import 'package:ts_management/features/navigation/start_point_picker.dart';

/// Per-building floor map. Vertical floor pills on the right, InteractiveViewer
/// rendering the architectural floor plan with an overlay of tappable rooms.
///
/// Floor 0 (basement) is intentionally omitted from the floor selector and
/// the renderer per product decision — see [isVisibleFloor].
class BuildingMapPage extends ConsumerStatefulWidget {
  const BuildingMapPage({
    super.key,
    required this.buildingId,
    this.initialFloor,
    this.previewEndWaypointId,
  });

  final String buildingId;
  final int? initialFloor;
  final String? previewEndWaypointId;

  @override
  ConsumerState<BuildingMapPage> createState() => _BuildingMapPageState();
}

class _BuildingMapPageState extends ConsumerState<BuildingMapPage> {
  int _floor = 1;
  Building? _building;
  List<FloorDoc> _floors = const [];
  List<RoomDoc> _rooms = const [];
  NavigationGraph? _graph;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _floor = widget.initialFloor ?? 1;
    _load();
  }

  Future<void> _load() async {
    final br = ref.read(buildingsRepositoryProvider);
    final nr = ref.read(navigationRepositoryProvider);
    final b = await br.get(widget.buildingId);
    final floors = await br.watchFloors(widget.buildingId).first;
    final rooms = await br.rooms(widget.buildingId);
    final graph = await nr.getGraph(widget.buildingId);

    // Build a synthetic graph for any rooms whose waypoints don't exist in
    // Firestore. Always exposes at least the visible floors (≥ 1) with stairs,
    // elevators, and named entry points.
    final synthetic = buildSyntheticGraph(rooms);
    final mergedGraph = _mergeGraphs(graph, synthetic);
    final reconciledRooms = reconcileRoomsToGraph(rooms, mergedGraph);

    if (!mounted) return;
    setState(() {
      _building = b;
      _floors = floors
          .where((f) => isVisibleFloor(f.number))
          .toList()
        ..sort((a, b) => a.number.compareTo(b.number));
      // If the building seeded no FloorDoc for visible floors, derive them
      // from the rooms list so the floor selector still works.
      if (_floors.isEmpty) {
        final derived = reconciledRooms
            .map((r) => r.floor)
            .where(isVisibleFloor)
            .toSet()
            .toList()
          ..sort();
        _floors = [for (final f in derived) FloorDoc(number: f)];
      }
      _rooms = reconciledRooms;
      _graph = mergedGraph;
      _loading = false;
      if (_floors.isNotEmpty &&
          !_floors.any((f) => f.number == _floor)) {
        _floor = _floors.first.number;
      }
    });
  }

  NavigationGraph _mergeGraphs(NavigationGraph? primary, NavigationGraph fallback) {
    if (primary == null || primary.nodes.isEmpty) return fallback;
    final ids = primary.nodes.map((n) => n.id).toSet();
    final mergedNodes = [
      ...primary.nodes,
      ...fallback.nodes.where((n) => !ids.contains(n.id)),
    ];
    final edgeKeys = primary.edges.map((e) => '${e.from}->${e.to}').toSet();
    final mergedEdges = [
      ...primary.edges,
      ...fallback.edges
          .where((e) => !edgeKeys.contains('${e.from}->${e.to}')),
    ];
    return NavigationGraph(nodes: mergedNodes, edges: mergedEdges);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_building == null) {
      return const Scaffold(body: Center(child: Text('Building not found')));
    }

    final floorDoc = _floors.firstWhere(
      (f) => f.number == _floor,
      orElse: () => FloorDoc(number: _floor),
    );
    final rooms = _rooms.where((r) => r.floor == _floor).toList();
    final allNodes = _graph?.nodes.where((n) => n.floor == _floor).toList() ??
        const <Waypoint>[];
    final nodeIds = allNodes.map((n) => n.id).toSet();
    final allEdges = _graph?.edges
            .where((e) => nodeIds.contains(e.from) && nodeIds.contains(e.to))
            .toList() ??
        const <GraphEdge>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F8F6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_building!.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            Text('${_floors.length} floors · Tap a room for details',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.go('/search'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map canvas
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 60, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F8F6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InteractiveViewer(
                    minScale: 0.4,
                    maxScale: 5,
                    child: AspectRatio(
                      aspectRatio: floorDoc.width / floorDoc.height,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapUp: (d) {
                          final ctx = context;
                          final renderObject =
                              ctx.findRenderObject() as RenderBox?;
                          final boxSize = renderObject?.size ??
                              Size(floorDoc.width, floorDoc.height);
                          final view =
                              Size(floorDoc.width, floorDoc.height);
                          final logical = Offset(
                            d.localPosition.dx *
                                view.width /
                                boxSize.width,
                            d.localPosition.dy *
                                view.height /
                                boxSize.height,
                          );
                          final hit = _hitRoom(logical, rooms, allNodes);
                          if (hit != null) _openRoomSheet(hit);
                        },
                        child: CustomPaint(
                          painter: FloorPlanPainter(
                            routeNodes: const [],
                            allNodes: allNodes,
                            allEdges: allEdges,
                            rooms: rooms,
                            viewWidth: floorDoc.width,
                            viewHeight: floorDoc.height,
                            activeIndex: -1,
                            routeColor: AppTheme.primary,
                            scheme: Theme.of(context).colorScheme,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Compass top-left
          Positioned(
            left: 20,
            top: 20,
            child: _CompassWidget(),
          ),

          // Floor label top-center
          Positioned(
            top: 20,
            left: 0,
            right: 60,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.93),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                      color: const Color(0xFFE5E3DB), width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '$_floor-р давхар  ·  Floor $_floor',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A18)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floor selector right edge
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _FloorSelector(
                floors: _floors
                    .map((f) => f.number)
                    .where(isVisibleFloor)
                    .toList(),
                active: _floor,
                onTap: (f) => setState(() => _floor = f),
              ),
            ),
          ),

          // Legend strip at the bottom
          Positioned(
            left: 12,
            right: 60,
            bottom: 12,
            child: _MapLegend(),
          ),
        ],
      ),
    );
  }

  RoomDoc? _hitRoom(
      Offset tap, List<RoomDoc> rooms, List<Waypoint> nodes) {
    final byId = {for (final n in nodes) n.id: n};
    const w = 130.0;
    const h = 92.0;
    for (final r in rooms) {
      final wp = byId[r.waypointId];
      if (wp == null) continue;
      final rect = Rect.fromCenter(
          center: Offset(wp.x, wp.y), width: w, height: h);
      if (rect.contains(tap)) return r;
    }
    return null;
  }

  void _openRoomSheet(RoomDoc r) {
    HapticFeedback.selectionClick();
    final peopleRepo = ref.read(peopleRepositoryProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                        child: Text(r.number,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${r.type.name} · floor $_floor',
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<Person>>(
                future: Future.wait(
                        r.occupantIds.map((id) => peopleRepo.get(id)))
                    .then((l) => l.whereType<Person>().toList()),
                builder: (context, snap) {
                  final occ = snap.data ?? const <Person>[];
                  if (occ.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text('No occupants',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    );
                  }
                  return Column(
                    children: occ
                        .map((p) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundImage: p.photoUrl != null
                                        ? NetworkImage(p.photoUrl!)
                                        : null,
                                    child: p.photoUrl == null
                                        ? Text(p.name.isNotEmpty
                                            ? p.name[0]
                                            : '?')
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(p.name,
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w600))),
                                  Text(p.role,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12)),
                                ],
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => StartPointPicker(
                      buildingId: widget.buildingId,
                      endWaypointId: r.waypointId,
                      destinationLabel: '${r.number} · ${r.name}',
                    ),
                  );
                },
                icon: const Icon(Icons.directions_rounded),
                label: const Text('Find route here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloorSelector extends StatelessWidget {
  const _FloorSelector({
    required this.floors,
    required this.active,
    required this.onTap,
  });

  final List<int> floors;
  final int active;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final ordered = [...floors]..sort((a, b) => b.compareTo(a));
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFE5E3DB), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final f in ordered)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: GestureDetector(
                onTap: () => onTap(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: f == active
                        ? AppTheme.primary
                        : const Color(0xFFF3F2EF),
                    shape: BoxShape.circle,
                    boxShadow: f == active
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$f',
                      style: TextStyle(
                        color: f == active
                            ? Colors.white
                            : const Color(0xFF444441),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompassWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E3DB), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: const SizedBox(
        width: 36,
        height: 36,
        child: CustomPaint(painter: _CompassPainter()),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    // Cross lines
    final linePaint = Paint()
      ..color = const Color(0xFFD3D1C7)
      ..strokeWidth = 1.2;
    canvas.drawLine(center.translate(0, -r), center.translate(0, r), linePaint);
    canvas.drawLine(center.translate(-r, 0), center.translate(r, 0), linePaint);
    // North arrow (filled red)
    final northPath = Path()
      ..moveTo(center.dx, center.dy - r * 0.85)
      ..lineTo(center.dx - 4, center.dy - 2)
      ..lineTo(center.dx + 4, center.dy - 2)
      ..close();
    canvas.drawPath(northPath, Paint()..color = AppTheme.primary);
    // Center dot
    canvas.drawCircle(center, 3, Paint()..color = const Color(0xFF888780));
    // N label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
            color: Color(0xFF0C447C),
            fontSize: 9,
            fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _MapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E3DB), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          _legendItem(const Color(0xFFDCECFD), const Color(0xFF185FA5), 'Classroom'),
          _legendItem(const Color(0xFFD4F0E4), const Color(0xFF1D9E75), 'Lab'),
          _legendItem(const Color(0xFFEEEDFE), const Color(0xFF7F77DD), 'Meeting'),
          _legendItem(const Color(0xFFF1EFE8), const Color(0xFF888780), 'Office'),
          _legendItem(const Color(0xFFFFF3CD), const Color(0xFFC88A00), 'Cafeteria'),
        ],
      ),
    );
  }

  Widget _legendItem(Color fill, Color stroke, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 8,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: stroke, width: 1),
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF666664),
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
