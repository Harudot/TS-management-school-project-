import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class AdminRoomsPage extends ConsumerWidget {
  const AdminRoomsPage({super.key, required this.buildingId});
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
              Text('Rooms',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _editDialog(context, ref, null),
                icon: const Icon(Icons.add),
                label: const Text('Add room'),
              ),
            ],
          ),
          Text('Building: $buildingId'),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<RoomDoc>>(
              stream: repo.watchRooms(buildingId),
              builder: (context, snap) {
                final list = snap.data ?? const <RoomDoc>[];
                list.sort((a, b) {
                  final byFloor = a.floor.compareTo(b.floor);
                  return byFloor != 0 ? byFloor : a.number.compareTo(b.number);
                });
                if (list.isEmpty) return const Center(child: Text('No rooms'));
                return ListView(
                  children: list
                      .map((r) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(child: Text(r.number)),
                              title: Text(r.name),
                              subtitle: Text(
                                  'Floor ${r.floor} · ${r.type.name} · waypoint=${r.waypointId}'),
                              trailing: Wrap(children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _editDialog(context, ref, r),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => repo.deleteRoom(buildingId, r.id),
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

  void _editDialog(BuildContext context, WidgetRef ref, RoomDoc? r) {
    final id = TextEditingController(text: r?.id ?? '');
    final number = TextEditingController(text: r?.number ?? '');
    final floor = TextEditingController(text: '${r?.floor ?? 1}');
    final name = TextEditingController(text: r?.name ?? '');
    final occupant = TextEditingController(text: r?.occupantId ?? '');
    final waypoint = TextEditingController(text: r?.waypointId ?? '');
    var type = r?.type ?? RoomType.office;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(r == null ? 'New room' : 'Edit ${r.number}'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: id,
                    enabled: r == null,
                    decoration: const InputDecoration(labelText: 'Room ID')),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: number,
                          decoration:
                              const InputDecoration(labelText: 'Number'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: floor,
                          decoration: const InputDecoration(labelText: 'Floor'))),
                ]),
                TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                    controller: waypoint,
                    decoration: const InputDecoration(labelText: 'Waypoint ID')),
                TextField(
                    controller: occupant,
                    decoration:
                        const InputDecoration(labelText: 'Occupant person ID (optional)')),
                const SizedBox(height: 8),
                DropdownButtonFormField<RoomType>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: RoomType.values
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t.name)))
                      .toList(),
                  onChanged: (v) => setState(() => type = v ?? RoomType.office),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                await ref.read(buildingsRepositoryProvider).upsertRoom(
                      buildingId,
                      RoomDoc(
                        id: id.text.trim(),
                        number: number.text.trim(),
                        floor: int.tryParse(floor.text) ?? 1,
                        name: name.text.trim(),
                        occupantId:
                            occupant.text.trim().isEmpty ? null : occupant.text.trim(),
                        waypointId: waypoint.text.trim(),
                        type: type,
                      ),
                    );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
