import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/data/models/person.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class AdminPeoplePage extends ConsumerWidget {
  const AdminPeoplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(peopleRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('People',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800)),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _editDialog(context, ref, null),
              icon: const Icon(Icons.add),
              label: const Text('Add person'),
            ),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Person>>(
              stream: repo.watchAll(),
              builder: (context, snap) {
                final list = snap.data ?? const <Person>[];
                if (list.isEmpty) return const Center(child: Text('No people'));
                return ListView(
                  children: list
                      .map((p) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: p.photoUrl != null
                                    ? NetworkImage(p.photoUrl!)
                                    : null,
                                child: p.photoUrl == null
                                    ? Text(p.name.isNotEmpty ? p.name[0] : '?')
                                    : null,
                              ),
                              title: Text(p.name),
                              subtitle: Text(
                                  '${p.role} · ${p.department} · ${p.buildingId}/${p.roomId ?? '—'}'),
                              trailing: Wrap(children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _editDialog(context, ref, p),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => repo.delete(p.id),
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

  void _editDialog(BuildContext context, WidgetRef ref, Person? p) {
    final id = TextEditingController(text: p?.id ?? '');
    final name = TextEditingController(text: p?.name ?? '');
    final role = TextEditingController(text: p?.role ?? '');
    final dept = TextEditingController(text: p?.department ?? '');
    final building = TextEditingController(text: p?.buildingId ?? '');
    final room = TextEditingController(text: p?.roomId ?? '');
    final contact = TextEditingController(text: p?.contact ?? '');
    final photo = TextEditingController(text: p?.photoUrl ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(p == null ? 'New person' : 'Edit ${p.name}'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: id, enabled: p == null, decoration: const InputDecoration(labelText: 'ID')),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: role, decoration: const InputDecoration(labelText: 'Role')),
              TextField(controller: dept, decoration: const InputDecoration(labelText: 'Department')),
              TextField(controller: building, decoration: const InputDecoration(labelText: 'Building ID')),
              TextField(controller: room, decoration: const InputDecoration(labelText: 'Room ID (optional)')),
              TextField(controller: contact, decoration: const InputDecoration(labelText: 'Contact')),
              TextField(controller: photo, decoration: const InputDecoration(labelText: 'Photo URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(peopleRepositoryProvider).upsert(Person(
                    id: id.text.trim(),
                    name: name.text.trim(),
                    role: role.text.trim(),
                    department: dept.text.trim(),
                    buildingId: building.text.trim(),
                    roomId: room.text.trim().isEmpty ? null : room.text.trim(),
                    contact: contact.text.trim().isEmpty ? null : contact.text.trim(),
                    photoUrl: photo.text.trim().isEmpty ? null : photo.text.trim(),
                  ));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
