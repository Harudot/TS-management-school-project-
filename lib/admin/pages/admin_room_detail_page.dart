import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/data/models/person.dart';
import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class AdminRoomDetailPage extends ConsumerStatefulWidget {
  const AdminRoomDetailPage({
    super.key,
    required this.buildingId,
    required this.roomId,
  });

  final String buildingId;
  final String roomId;

  @override
  ConsumerState<AdminRoomDetailPage> createState() =>
      _AdminRoomDetailPageState();
}

class _AdminRoomDetailPageState extends ConsumerState<AdminRoomDetailPage> {
  late final TextEditingController _name;
  late final TextEditingController _number;
  late final TextEditingController _floor;
  RoomType? _type;
  RoomDoc? _loaded;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _number = TextEditingController();
    _floor = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _floor.dispose();
    super.dispose();
  }

  void _hydrate(RoomDoc r) {
    if (_loaded?.id == r.id) return;
    _loaded = r;
    _name.text = r.name;
    _number.text = r.number;
    _floor.text = '${r.floor}';
    _type = r.type;
  }

  Future<void> _saveHeader() async {
    if (_loaded == null) return;
    final updated = _loaded!.copyWith(
      name: _name.text.trim(),
      number: _number.text.trim(),
      floor: int.tryParse(_floor.text) ?? _loaded!.floor,
      type: _type ?? _loaded!.type,
    );
    await ref
        .read(buildingsRepositoryProvider)
        .upsertRoom(widget.buildingId, updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  Future<void> _addWorker() async {
    if (_loaded == null) return;
    final picked = await showDialog<Person>(
      context: context,
      builder: (_) => _AddOccupantDialog(
        buildingId: widget.buildingId,
        excludeIds: _loaded!.occupantIds.toSet(),
      ),
    );
    if (picked == null) return;
    await ref.read(buildingsRepositoryProvider).addOccupant(
          buildingId: widget.buildingId,
          roomId: widget.roomId,
          personId: picked.id,
          setAsPrimary: picked.roomId == null || picked.roomId!.isEmpty,
        );
  }

  Future<void> _remove(String personId) async {
    await ref.read(buildingsRepositoryProvider).removeOccupant(
          buildingId: widget.buildingId,
          roomId: widget.roomId,
          personId: personId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(buildingsRepositoryProvider);
    final peopleRepo = ref.watch(peopleRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Room')),
      body: StreamBuilder<RoomDoc?>(
        stream: repo.watchRoom(widget.buildingId, widget.roomId),
        builder: (context, snap) {
          final room = snap.data;
          if (room == null) {
            return const Center(child: CircularProgressIndicator());
          }
          _hydrate(room);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Room ${room.number}',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _number,
                        decoration: const InputDecoration(labelText: 'Number'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _floor,
                        decoration: const InputDecoration(labelText: 'Floor'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _name,
                        decoration:
                            const InputDecoration(labelText: 'Name (Mongolian)'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<RoomType>(
                        value: _type ?? room.type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: RoomType.values
                            .map((t) => DropdownMenuItem(
                                value: t, child: Text(t.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _type = v),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Save'),
                          onPressed: _saveHeader,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Occupants',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: _addWorker,
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Add worker'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (room.occupantIds.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('No occupants assigned'),
                )
              else
                FutureBuilder<List<Person>>(
                  future: Future.wait(
                      room.occupantIds.map((id) => peopleRepo.get(id))).then(
                          (list) => list.whereType<Person>().toList()),
                  builder: (context, s) {
                    final list = s.data ?? const <Person>[];
                    return Column(
                      children: list
                          .map((p) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: p.photoUrl != null
                                        ? NetworkImage(p.photoUrl!)
                                        : null,
                                    child: p.photoUrl == null
                                        ? Text(p.name.isNotEmpty
                                            ? p.name[0]
                                            : '?')
                                        : null,
                                  ),
                                  title: Text(p.name),
                                  subtitle: Text('${p.role} · ${p.department}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: Colors.red,
                                    onPressed: () => _remove(p.id),
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AddOccupantDialog extends ConsumerStatefulWidget {
  const _AddOccupantDialog({
    required this.buildingId,
    required this.excludeIds,
  });
  final String buildingId;
  final Set<String> excludeIds;

  @override
  ConsumerState<_AddOccupantDialog> createState() =>
      _AddOccupantDialogState();
}

class _AddOccupantDialogState extends ConsumerState<_AddOccupantDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final stream = ref.watch(peopleRepositoryProvider).watchAll();
    return Dialog(
      child: SizedBox(
        width: 480,
        child: StreamBuilder<List<Person>>(
          stream: stream,
          builder: (context, snap) {
            final all = snap.data ?? const <Person>[];
            final candidates = all.where((p) {
              if (widget.excludeIds.contains(p.id)) return false;
              if (p.buildingId.isNotEmpty &&
                  p.buildingId != widget.buildingId) {
                return false;
              }
              if (_query.isEmpty) return true;
              final q = _query.toLowerCase();
              return p.name.toLowerCase().contains(q) ||
                  p.role.toLowerCase().contains(q) ||
                  p.department.toLowerCase().contains(q);
            }).toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('Add worker',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search name, role, department…',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (v) => setState(() => _query = v.trim()),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: candidates.length,
                    itemBuilder: (_, i) {
                      final p = candidates[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: p.photoUrl != null
                              ? NetworkImage(p.photoUrl!)
                              : null,
                          child: p.photoUrl == null
                              ? Text(p.name.isNotEmpty ? p.name[0] : '?')
                              : null,
                        ),
                        title: Text(p.name),
                        subtitle: Text('${p.role} · ${p.department}'),
                        onTap: () => Navigator.pop(context, p),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
