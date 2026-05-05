import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/data/models/waypoint.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class StartPointPicker extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(navigationRepositoryProvider).watchStartPoints(buildingId);
    return StreamBuilder<List<StartPoint>>(
      stream: stream,
      builder: (context, snap) {
        final list = snap.data ?? const <StartPoint>[];
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
                  'Pick the closest landmark — we\'ll guide you to $destinationLabel',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                if (list.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No start points configured for this building.'),
                  ),
                ...list.map((sp) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                            child: Icon(Icons.place_rounded)),
                        title: Text(sp.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('Floor ${sp.floor}'),
                        trailing: const Icon(Icons.arrow_forward_rounded),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/navigate', extra: {
                            'buildingId': buildingId,
                            'startWaypointId': sp.waypointId,
                            'endWaypointId': endWaypointId,
                            'destinationLabel': destinationLabel,
                          });
                        },
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
