import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/data/models/building.dart';
import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/models/waypoint.dart';
import 'package:ts_management/data/repositories/repositories.dart';
import 'package:ts_management/domain/services/routing_service.dart';
import 'package:ts_management/features/navigation/floor_painter.dart';

class NavigationPage extends ConsumerStatefulWidget {
  const NavigationPage({
    super.key,
    required this.buildingId,
    required this.startWaypointId,
    required this.endWaypointId,
    required this.destinationLabel,
  });

  final String buildingId;
  final String startWaypointId;
  final String endWaypointId;
  final String destinationLabel;

  @override
  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage> {
  ComputedRoute? _route;
  List<FloorDoc> _floors = const [];
  NavigationGraph? _graph;
  List<RoomDoc> _rooms = const [];
  int _segmentIndex = 0;
  int _stepIndex = 0;
  bool _arrived = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    try {
      final navRepo = ref.read(navigationRepositoryProvider);
      final buildingsRepo = ref.read(buildingsRepositoryProvider);
      final graph = await navRepo.getGraph(widget.buildingId);
      if (graph == null) {
        setState(() => _error = 'No navigation graph for this building');
        return;
      }
      final route = RoutingService()
          .findRoute(graph, widget.startWaypointId, widget.endWaypointId);
      final floors = await buildingsRepo.watchFloors(widget.buildingId).first;
      final rooms = await buildingsRepo.rooms(widget.buildingId);
      if (!mounted) return;
      setState(() {
        _route = route;
        _floors = floors;
        _graph = graph;
        _rooms = rooms;
        if (route.isEmpty) _error = 'No route found';
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  RouteSegment? get _segment {
    if (_route == null || _route!.segments.isEmpty) return null;
    return _route!.segments[_segmentIndex];
  }

  FloorDoc? get _currentFloor {
    final s = _segment;
    if (s == null) return null;
    return _floors.firstWhere(
      (f) => f.number == s.floor,
      orElse: () => FloorDoc(number: s.floor),
    );
  }

  void _next() {
    final seg = _segment;
    if (seg == null) return;
    if (_stepIndex < seg.instructions.length - 1) {
      setState(() => _stepIndex++);
      return;
    }
    // Last step in this segment.
    if (_segmentIndex < _route!.segments.length - 1) {
      _confirmFloorTransition();
    } else {
      setState(() => _arrived = true);
    }
  }

  void _previous() {
    if (_stepIndex > 0) {
      setState(() => _stepIndex--);
    } else if (_segmentIndex > 0) {
      setState(() {
        _segmentIndex--;
        _stepIndex = _route!.segments[_segmentIndex].instructions.length - 1;
      });
    }
  }

  Future<void> _confirmFloorTransition() async {
    final nextFloor = _route!.segments[_segmentIndex + 1].floor;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Are you on Floor $nextFloor?'),
        content: const Text('Confirm when you reach the next floor.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not yet')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes, I'm here")),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() {
        _segmentIndex++;
        _stepIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigation')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_route == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    final segments = _route!.segments;
    final segment = _segment!;
    final floorDoc = _currentFloor!;
    final floorNodes =
        _graph!.nodes.where((n) => n.floor == segment.floor).toList();
    final floorNodeIds = floorNodes.map((n) => n.id).toSet();
    final floorEdges = _graph!.edges
        .where((e) =>
            floorNodeIds.contains(e.from) && floorNodeIds.contains(e.to))
        .toList();
    final floorRooms =
        _rooms.where((r) => r.floor == segment.floor).toList();

    final progress = _arrived
        ? 1.0
        : (segments.take(_segmentIndex).fold<int>(
                    0,
                    (sum, s) => sum + s.instructions.length) +
                _stepIndex +
                1) /
            segments.fold<int>(0, (sum, s) => sum + s.instructions.length).clamp(1, 1 << 30);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.destinationLabel,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: LinearProgressIndicator(value: progress, minHeight: 4),
        ),
      ),
      body: Column(
        children: [
          // Floor header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('Floor ${segment.floor}',
                      style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Text(
                    'Segment ${_segmentIndex + 1} of ${segments.length}',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          // Floor map
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: floorDoc.width / floorDoc.height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (floorDoc.floorPlanUrl != null)
                        CachedNetworkImage(
                            imageUrl: floorDoc.floorPlanUrl!,
                            fit: BoxFit.cover)
                      else
                        Container(color: scheme.surfaceContainerHigh),
                      CustomPaint(
                        painter: FloorPlanPainter(
                          routeNodes: segment.nodes,
                          allNodes: floorNodes,
                          allEdges: floorEdges,
                          rooms: floorRooms,
                          viewWidth: floorDoc.width,
                          viewHeight: floorDoc.height,
                          activeIndex: _stepIndex + 1,
                          routeColor: scheme.primary,
                          scheme: scheme,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Current step card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey('$_segmentIndex-$_stepIndex-$_arrived'),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _arrived ? Colors.green : scheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                        _arrived
                            ? Icons.check_circle_rounded
                            : Icons.directions_walk_rounded,
                        color: Colors.white,
                        size: 36),
                    const SizedBox(height: 8),
                    Text(
                      _arrived
                          ? 'You have arrived!'
                          : segment.instructions[_stepIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bottom buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: _arrived
                ? FilledButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Finish'),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (_segmentIndex == 0 && _stepIndex == 0)
                              ? null
                              : _previous,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _next,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(_isLastStep ? 'Finish' : 'Next'),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  bool get _isLastStep =>
      _segmentIndex == _route!.segments.length - 1 &&
      _stepIndex == _segment!.instructions.length - 1;
}
