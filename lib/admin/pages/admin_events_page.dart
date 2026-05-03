import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ts_management/data/models/event.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class AdminEventsPage extends ConsumerWidget {
  const AdminEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(eventsRepositoryProvider);
    final fmt = DateFormat('MMM d, h:mm a');
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Events',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800)),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _editDialog(context, ref, null),
              icon: const Icon(Icons.add),
              label: const Text('New event'),
            ),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<CampusEvent>>(
              stream: repo.watchAll(),
              builder: (context, snap) {
                final list = snap.data ?? const <CampusEvent>[];
                if (list.isEmpty) return const Center(child: Text('No events'));
                return ListView(
                  children: list
                      .map((e) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.event_rounded),
                              title: Text(e.title),
                              subtitle: Text(
                                  '${e.buildingId} · F${e.floor} · ${fmt.format(e.startTime)} – ${fmt.format(e.endTime)}'),
                              trailing: Wrap(children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _editDialog(context, ref, e),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => repo.delete(e.id),
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

  void _editDialog(BuildContext context, WidgetRef ref, CampusEvent? e) {
    final id = TextEditingController(text: e?.id ?? '');
    final title = TextEditingController(text: e?.title ?? '');
    final desc = TextEditingController(text: e?.description ?? '');
    final building = TextEditingController(text: e?.buildingId ?? '');
    final floor = TextEditingController(text: '${e?.floor ?? 1}');
    final room = TextEditingController(text: e?.roomId ?? '');
    final category = TextEditingController(text: e?.category ?? 'general');
    var start = e?.startTime ?? DateTime.now().add(const Duration(hours: 1));
    var end = e?.endTime ?? DateTime.now().add(const Duration(hours: 3));
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(e == null ? 'New event' : 'Edit ${e.title}'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: id, enabled: e == null, decoration: const InputDecoration(labelText: 'ID')),
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                TextField(controller: building, decoration: const InputDecoration(labelText: 'Building ID')),
                Row(children: [
                  Expanded(child: TextField(controller: floor, decoration: const InputDecoration(labelText: 'Floor'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: room, decoration: const InputDecoration(labelText: 'Room ID (optional)'))),
                ]),
                TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')),
                const SizedBox(height: 8),
                ListTile(
                  title: Text('Start: ${start.toLocal()}'),
                  trailing: TextButton(
                    onPressed: () async {
                      final picked = await _pickDateTime(context, start);
                      if (picked != null) setState(() => start = picked);
                    },
                    child: const Text('Pick'),
                  ),
                ),
                ListTile(
                  title: Text('End: ${end.toLocal()}'),
                  trailing: TextButton(
                    onPressed: () async {
                      final picked = await _pickDateTime(context, end);
                      if (picked != null) setState(() => end = picked);
                    },
                    child: const Text('Pick'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                await ref.read(eventsRepositoryProvider).upsert(CampusEvent(
                      id: id.text.trim(),
                      title: title.text.trim(),
                      description: desc.text.trim(),
                      buildingId: building.text.trim(),
                      floor: int.tryParse(floor.text) ?? 1,
                      roomId: room.text.trim().isEmpty ? null : room.text.trim(),
                      startTime: start,
                      endTime: end,
                      category: category.text.trim(),
                    ));
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return null;
    if (!context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
