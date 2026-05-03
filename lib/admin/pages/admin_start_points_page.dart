import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/data/models/waypoint.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class AdminStartPointsPage extends ConsumerWidget {
  const AdminStartPointsPage({super.key, required this.buildingId});
  final String buildingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(navigationRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Start points',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800)),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _editDialog(context, ref, null),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ]),
          Text('Building: $buildingId'),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<StartPoint>>(
              stream: repo.watchStartPoints(buildingId),
              builder: (context, snap) {
                final list = snap.data ?? const <StartPoint>[];
                if (list.isEmpty) return const Center(child: Text('None yet'));
                return ListView(
                  children: list
                      .map((sp) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading:
                                  const CircleAvatar(child: Icon(Icons.place_rounded)),
                              title: Text(sp.name),
                              subtitle: Text(
                                  'F${sp.floor} · waypoint=${sp.waypointId}'),
                              trailing: Wrap(children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _editDialog(context, ref, sp),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      repo.deleteStartPoint(buildingId, sp.id),
                                ),
                              ]),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editDialog(BuildContext context, WidgetRef ref, StartPoint? sp) {
    final id = TextEditingController(text: sp?.id ?? '');
    final name = TextEditingController(text: sp?.name ?? '');
    final floor = TextEditingController(text: '${sp?.floor ?? 1}');
    final waypoint = TextEditingController(text: sp?.waypointId ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(sp == null ? 'New start point' : 'Edit ${sp.name}'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: id, enabled: sp == null, decoration: const InputDecoration(labelText: 'ID')),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: floor, decoration: const InputDecoration(labelText: 'Floor')),
              TextField(controller: waypoint, decoration: const InputDecoration(labelText: 'Waypoint ID')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(navigationRepositoryProvider).upsertStartPoint(
                    buildingId,
                    StartPoint(
                      id: id.text.trim(),
                      name: name.text.trim(),
                      floor: int.tryParse(floor.text) ?? 1,
                      waypointId: waypoint.text.trim(),
                    ),
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
