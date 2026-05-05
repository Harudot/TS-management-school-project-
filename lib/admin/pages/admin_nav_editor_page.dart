import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/data/models/building.dart';
import 'package:ts_management/data/models/waypoint.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class AdminNavEditorPage extends ConsumerStatefulWidget {
  const AdminNavEditorPage({super.key, required this.buildingId});
  final String buildingId;
  @override
  ConsumerState<AdminNavEditorPage> createState() => _AdminNavEditorPageState();
}

class _AdminNavEditorPageState extends ConsumerState<AdminNavEditorPage> {
  NavigationGraph? _graph;
  List<FloorDoc> _floors = const [];
  int _floor = 1;
  String? _connectFrom;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final navRepo = ref.read(navigationRepositoryProvider);
    final buildingsRepo = ref.read(buildingsRepositoryProvider);
    final graph = await navRepo.getGraph(widget.buildingId);
    final floors = await buildingsRepo.watchFloors(widget.buildingId).first;
    setState(() {
      _graph = graph ?? NavigationGraph(nodes: [], edges: []);
      _floors = floors;
      if (floors.isNotEmpty) _floor = floors.first.number;
    });
  }

  Future<void> _save() async {
    if (_graph == null) return;
    await ref
        .read(navigationRepositoryProvider)
        .setGraph(widget.buildingId, _graph!);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Graph saved')));
    }
  }

  void _addNode(Offset normalized) {
    final id = 'wp_${_floor}_${_graph!.nodes.length + 1}';
    setState(() {
      _graph = NavigationGraph(
        nodes: [
          ..._graph!.nodes,
          Waypoint(
            id: id,
            floor: _floor,
            x: normalized.dx * (_currentFloor?.width ?? 1000),
            y: normalized.dy * (_currentFloor?.height ?? 700),
          ),
        ],
        edges: _graph!.edges,
      );
    });
  }

  void _connect(String aId, String bId) {
    final a = _graph!.nodes.firstWhere((n) => n.id == aId);
    final b = _graph!.nodes.firstWhere((n) => n.id == bId);
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    final w = (dx * dx + dy * dy);
    setState(() {
      _graph = NavigationGraph(
        nodes: _graph!.nodes,
        edges: [
          ..._graph!.edges,
          GraphEdge(from: aId, to: bId, weight: w > 0 ? w : 1, instruction: 'Walk'),
        ],
      );
    });
  }

  void _deleteNode(String id) {
    setState(() {
      _graph = NavigationGraph(
        nodes: _graph!.nodes.where((n) => n.id != id).toList(),
        edges: _graph!.edges.where((e) => e.from != id && e.to != id).toList(),
      );
    });
  }

  FloorDoc? get _currentFloor => _floors.firstWhere(
        (f) => f.number == _floor,
        orElse: () => FloorDoc(number: _floor),
      );

  @override
  Widget build(BuildContext context) {
    if (_graph == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final nodesOnFloor = _graph!.nodes.where((n) => n.floor == _floor).toList();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Navigation editor — ${widget.buildingId}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 16),
            DropdownButton<int>(
              value: _floor,
              items: _floors
                  .map((f) => DropdownMenuItem(
                      value: f.number, child: Text('Floor ${f.number}')))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _floor = v ?? _floor),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save graph'),
            ),
          ]),
          const SizedBox(height: 8),
          const Text('Click empty space → add node. Click node → connect/delete.'),
          const SizedBox(height: 8),
          Expanded(
            child: AspectRatio(
              aspectRatio: (_currentFloor?.width ?? 1000) /
                  (_currentFloor?.height ?? 700),
              child: LayoutBuilder(
                builder: (context, c) => GestureDetector(
                  onTapUp: (d) {
                    final hit = _hitNode(d.localPosition, c.biggest, nodesOnFloor);
                    if (hit != null) {
                      _onNodeTap(hit);
                    } else {
                      _addNode(Offset(d.localPosition.dx / c.maxWidth,
                          d.localPosition.dy / c.maxHeight));
                    }
                  },
                  child: Stack(
                    children: [
                      if (_currentFloor?.floorPlanUrl != null)
                        CachedNetworkImage(
                            imageUrl: _currentFloor!.floorPlanUrl!,
                            fit: BoxFit.cover,
                            width: c.maxWidth,
                            height: c.maxHeight)
                      else
                        Container(color: Colors.grey.shade200),
                      CustomPaint(
                        size: c.biggest,
                        painter: _GraphPainter(
                          graph: _graph!,
                          floor: _floor,
                          viewW: _currentFloor?.width ?? 1000,
                          viewH: _currentFloor?.height ?? 700,
                          highlight: _connectFrom,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_connectFrom != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber,
              child: Text(
                  'Connecting from $_connectFrom — click another node to create an edge, or click the same node again to cancel.'),
            ),
        ],
      ),
    );
  }

  String? _hitNode(Offset pos, Size size, List<Waypoint> nodes) {
    for (final n in nodes) {
      final p = Offset(
        n.x / (_currentFloor?.width ?? 1000) * size.width,
        n.y / (_currentFloor?.height ?? 700) * size.height,
      );
      if ((p - pos).distance < 14) return n.id;
    }
    return null;
  }

  void _onNodeTap(String id) {
    if (_connectFrom == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(id),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _connectFrom = id);
                },
                child: const Text('Start connection')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteNode(id);
                },
                child: const Text('Delete')),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
          ],
        ),
      );
    } else {
      if (id == _connectFrom) {
        setState(() => _connectFrom = null);
      } else {
        _connect(_connectFrom!, id);
        setState(() => _connectFrom = null);
      }
    }
  }
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.graph,
    required this.floor,
    required this.viewW,
    required this.viewH,
    this.highlight,
  });

  final NavigationGraph graph;
  final int floor;
  final double viewW;
  final double viewH;
  final String? highlight;

  Offset _p(Waypoint n, Size s) =>
      Offset(n.x / viewW * s.width, n.y / viewH * s.height);

  @override
  void paint(Canvas canvas, Size size) {
    final byId = {for (final n in graph.nodes) n.id: n};
    final edgePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;
    for (final e in graph.edges) {
      final a = byId[e.from];
      final b = byId[e.to];
      if (a == null || b == null) continue;
      if (a.floor != floor && b.floor != floor) continue;
      canvas.drawLine(_p(a, size), _p(b, size), edgePaint);
    }
    for (final n in graph.nodes.where((n) => n.floor == floor)) {
      final p = _p(n, size);
      canvas.drawCircle(p, 9,
          Paint()..color = n.id == highlight ? Colors.amber : Colors.blue);
      canvas.drawCircle(
          p,
          9,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      final tp = TextPainter(
        text: TextSpan(
            text: n.id, style: const TextStyle(fontSize: 10, color: Colors.black)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p + const Offset(10, -6));
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) =>
      old.graph != graph || old.floor != floor || old.highlight != highlight;
}
