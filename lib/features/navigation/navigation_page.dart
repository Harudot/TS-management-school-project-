import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/core/theme/app_theme.dart';
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

class _NavigationPageState extends ConsumerState<NavigationPage>
    with SingleTickerProviderStateMixin {
  ComputedRoute? _route;
  List<FloorDoc> _floors = const [];
  NavigationGraph? _graph;
  List<RoomDoc> _rooms = const [];
  int _segmentIndex = 0;
  int _stepIndex = 0;
  bool _arrived = false;
  bool _stepsExpanded = false;
  String? _error;

  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
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

  void _advanceStep() {
    final seg = _segment;
    if (seg == null) return;
    if (_stepIndex < seg.instructions.length - 1) {
      setState(() => _stepIndex++);
      return;
    }
    if (_segmentIndex < _route!.segments.length - 1) {
      setState(() {
        _segmentIndex++;
        _stepIndex = 0;
      });
    } else {
      setState(() => _arrived = true);
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

    final isLastSegment = _segmentIndex == segments.length - 1;
    final crossFloor = !isLastSegment;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.destinationLabel,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: Column(
        children: [
          // Floor pill
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('Floor ${segment.floor}',
                      style: const TextStyle(
                          color: AppTheme.onPrimary,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Text('Segment ${_segmentIndex + 1} of ${segments.length}',
                    style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          // Floor map with animated dot
          Expanded(
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
                        Image.asset(
                          'assets/floorplans/${segment.floor <= 0 ? "floor_b1" : "floor_${segment.floor}"}.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: scheme.surfaceContainerHigh),
                        ),
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, __) => CustomPaint(
                          painter: FloorPlanPainter(
                            routeNodes: segment.nodes,
                            allNodes: floorNodes,
                            allEdges: floorEdges,
                            rooms: floorRooms,
                            viewWidth: floorDoc.width,
                            viewHeight: floorDoc.height,
                            activeIndex: _stepIndex + 1,
                            routeColor: AppTheme.primary,
                            scheme: scheme,
                            pulseT: _pulse.value,
                            destinationWaypointId: isLastSegment
                                ? widget.endWaypointId
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (crossFloor && _stepIndex == segment.instructions.length - 1)
            _CrossFloorCard(
              fromFloor: segment.floor,
              toFloor: segments[_segmentIndex + 1].floor,
              onNext: () => setState(() {
                _segmentIndex++;
                _stepIndex = 0;
              }),
            ),
          _StepsPanel(
            current: _arrived
                ? const BilingualStep('Хүрлээ', 'You have arrived')
                : (segment.steps.isNotEmpty
                    ? segment.steps[_stepIndex]
                    : const BilingualStep('Урагш яв', 'Walk forward')),
            allSteps:
                _route!.segments.expand((s) => s.steps).toList(growable: false),
            expanded: _stepsExpanded,
            onToggle: () =>
                setState(() => _stepsExpanded = !_stepsExpanded),
            onNext: _arrived ? null : _advanceStep,
            arrived: _arrived,
          ),
        ],
      ),
      bottomNavigationBar: _arrived
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Finish'),
                ),
              ),
            )
          : null,
    );
  }
}

class _CrossFloorCard extends StatelessWidget {
  const _CrossFloorCard({
    required this.fromFloor,
    required this.toFloor,
    required this.onNext,
  });
  final int fromFloor;
  final int toFloor;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: const Border(
              left: BorderSide(color: AppTheme.live, width: 3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.stairs_rounded, color: AppTheme.live),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Take stairs → Floor $toFloor',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            FilledButton.tonal(
              onPressed: onNext,
              child: const Text('Next floor'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsPanel extends StatelessWidget {
  const _StepsPanel({
    required this.current,
    required this.allSteps,
    required this.expanded,
    required this.onToggle,
    required this.onNext,
    required this.arrived,
  });

  final BilingualStep current;
  final List<BilingualStep> allSteps;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback? onNext;
  final bool arrived;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: arrived ? AppTheme.success : AppTheme.primary,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                    arrived
                        ? Icons.check_circle_rounded
                        : Icons.directions_walk_rounded,
                    color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(current.mn,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800)),
                      Text(current.en,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    expanded ? Icons.expand_more_rounded : Icons.list_rounded,
                    color: Colors.white,
                  ),
                  onPressed: onToggle,
                ),
                if (onNext != null)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                    ),
                    onPressed: onNext,
                    child: const Text('Next'),
                  ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 10),
              const Divider(color: Colors.white24),
              ...allSteps.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${e.key + 1}.',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.value.mn,
                                  style: const TextStyle(color: Colors.white)),
                              Text(e.value.en,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
