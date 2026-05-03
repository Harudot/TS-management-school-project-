import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/data/models/building.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class AdminFloorsPage extends ConsumerWidget {
  const AdminFloorsPage({super.key, required this.buildingId});
  final String buildingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(buildingsRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Floors',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _editDialog(context, ref, null),
                icon: const Icon(Icons.add),
                label: const Text('Add floor'),
              ),
            ],
          ),
          Text('Building: $buildingId'),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<FloorDoc>>(
              stream: repo.watchFloors(buildingId),
              builder: (context, snap) {
                final list = snap.data ?? const <FloorDoc>[];
                if (list.isEmpty) {
                  return const Center(child: Text('No floors yet'));
                }
                return ListView(
                  children: list
                      .map((f) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(child: Text('${f.number}')),
                              title: Text('Floor ${f.number}'),
                              subtitle: Text(
                                  'Plan: ${f.floorPlanUrl ?? '— none —'}\nSize: ${f.width.toInt()}×${f.height.toInt()}'),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _editDialog(context, ref, f),
                              ),
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

  void _editDialog(BuildContext context, WidgetRef ref, FloorDoc? f) {
    final number = TextEditingController(text: '${f?.number ?? 1}');
    final url = TextEditingController(text: f?.floorPlanUrl ?? '');
    final width = TextEditingController(text: '${f?.width ?? 1000}');
    final height = TextEditingController(text: '${f?.height ?? 700}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(f == null ? 'New floor' : 'Floor ${f.number}'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: number,
                  enabled: f == null,
                  decoration:
                      const InputDecoration(labelText: 'Floor number')),
              const SizedBox(height: 8),
              TextField(
                  controller: url,
                  decoration: const InputDecoration(
                      labelText: 'Floor plan image URL (Storage)')),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: width,
                        decoration:
                            const InputDecoration(labelText: 'Width (px)'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: height,
                        decoration:
                            const InputDecoration(labelText: 'Height (px)'))),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(buildingsRepositoryProvider).upsertFloor(
                    buildingId,
                    FloorDoc(
                      number: int.parse(number.text),
                      floorPlanUrl: url.text.trim().isEmpty ? null : url.text.trim(),
                      width: double.tryParse(width.text) ?? 1000,
                      height: double.tryParse(height.text) ?? 700,
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
