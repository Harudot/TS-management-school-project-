import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/models/waypoint.dart';
import 'package:ts_management/data/repositories/repositories.dart';
import 'package:ts_management/features/navigation/default_layout.dart';

class StartPointPicker extends ConsumerStatefulWidget {
  const StartPointPicker({
    super.key,
    required this.buildingId,
    required this.endWaypointId,
    required this.destinationLabel,
  });

  final String buildingId;
  final String endWaypointId;
  final String destinationLabel;

  @override
  ConsumerState<StartPointPicker> createState() => _StartPointPickerState();
}

class _StartPointPickerState extends ConsumerState<StartPointPicker> {
  late Future<_PickerData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_PickerData> _load() async {
    final navRepo = ref.read(navigationRepositoryProvider);
    final brRepo = ref.read(buildingsRepositoryProvider);
    final firestoreSp = await navRepo.startPoints(widget.buildingId);
    final graph = await navRepo.getGraph(widget.buildingId);
    final rooms = await brRepo.rooms(widget.buildingId);
    final synthetic = buildSyntheticGraph(rooms);
    final merged = _mergeGraphs(graph, synthetic);
    final fallback = defaultStartPoints(merged, rooms: rooms);

    // Merge: keep all Firestore start points, then add any fallback whose
    // floor is not represented yet. This way the per-floor entry points
    // (Сургуулын төв хаалга / Хүндэтгэлийн танхим / 3 давхарын эхлэх цэг)
    // always show up even if the building has no `start_points/*` doc yet.
    final byFloor = {for (final sp in firestoreSp) sp.floor: sp};
    final out = <StartPoint>[
      ...firestoreSp,
      ...fallback.where((sp) => !byFloor.containsKey(sp.floor)),
    ]..sort((a, b) => a.floor.compareTo(b.floor));

    return _PickerData(out, rooms);
  }

  NavigationGraph _mergeGraphs(NavigationGraph? a, NavigationGraph b) {
    if (a == null || a.nodes.isEmpty) return b;
    final ids = a.nodes.map((n) => n.id).toSet();
    return NavigationGraph(
      nodes: [...a.nodes, ...b.nodes.where((n) => !ids.contains(n.id))],
      edges: [...a.edges, ...b.edges],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Where are you?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              "Pick the closest landmark — we'll guide you to ${widget.destinationLabel}",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FutureBuilder<_PickerData>(
              future: _future,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final list = snap.data!.startPoints;
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                        'No start points configured for this building.'),
                  );
                }
                return Column(
                  children: list
                      .map((sp) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${sp.floor}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                              ),
                              title: Text(sp.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              subtitle: Text('Floor ${sp.floor}'),
                              trailing: const Icon(Icons.arrow_forward_rounded),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.push('/navigate', extra: {
                                  'buildingId': widget.buildingId,
                                  'startWaypointId': sp.waypointId,
                                  'endWaypointId': widget.endWaypointId,
                                  'destinationLabel': widget.destinationLabel,
                                });
                              },
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerData {
  _PickerData(this.startPoints, this.rooms);
  final List<StartPoint> startPoints;
  final List<RoomDoc> rooms;
}
