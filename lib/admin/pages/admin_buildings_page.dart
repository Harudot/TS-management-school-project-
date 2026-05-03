import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:ts_management/data/models/building.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class AdminBuildingsPage extends ConsumerWidget {
  const AdminBuildingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(buildingsRepositoryProvider).watchAll();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Buildings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _editDialog(context, ref, null),
                icon: const Icon(Icons.add),
                label: const Text('New building'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Building>>(
              stream: stream,
              builder: (context, snap) {
                final list = snap.data ?? const <Building>[];
                if (list.isEmpty) {
                  return const Center(child: Text('No buildings yet'));
                }
                return ListView(
                  children: list.map((b) => _BuildingRow(b: b)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildingRow extends ConsumerWidget {
  const _BuildingRow({required this.b});
  final Building b;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.apartment_rounded)),
        title: Text(b.name),
        subtitle: Text(b.address),
        trailing: Wrap(spacing: 4, children: [
          IconButton(
            tooltip: 'Floors',
            icon: const Icon(Icons.layers_outlined),
            onPressed: () => context.go('/admin/buildings/${b.id}/floors'),
          ),
          IconButton(
            tooltip: 'Rooms',
            icon: const Icon(Icons.meeting_room_outlined),
            onPressed: () => context.go('/admin/buildings/${b.id}/rooms'),
          ),
          IconButton(
            tooltip: 'Navigation graph',
            icon: const Icon(Icons.account_tree_outlined),
            onPressed: () => context.go('/admin/buildings/${b.id}/nav'),
          ),
          IconButton(
            tooltip: 'Start points',
            icon: const Icon(Icons.place_outlined),
            onPressed: () => context.go('/admin/buildings/${b.id}/start-points'),
          ),
          IconButton(
            tooltip: 'QR code',
            icon: const Icon(Icons.qr_code_2_rounded),
            onPressed: () => _showQr(context, b),
          ),
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editDialog(context, ref, b),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                ref.read(buildingsRepositoryProvider).delete(b.id),
          ),
        ]),
      ),
    );
  }

  void _showQr(BuildContext context, Building b) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${b.name} QR'),
        content: SizedBox(
          width: 280,
          height: 280,
          child: QrImageView(
            data: 'campus://${b.id}',
            backgroundColor: Colors.white,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }
}

void _editDialog(BuildContext context, WidgetRef ref, Building? b) {
  final id = TextEditingController(text: b?.id ?? '');
  final name = TextEditingController(text: b?.name ?? '');
  final addr = TextEditingController(text: b?.address ?? '');
  final floors = TextEditingController(text: '${b?.floorCount ?? 1}');
  final companies = TextEditingController(text: b?.companies.join(', ') ?? '');
  final photo = TextEditingController(text: b?.photoUrl ?? '');

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(b == null ? 'New building' : 'Edit ${b.name}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: id,
                enabled: b == null,
                decoration: const InputDecoration(labelText: 'ID')),
            const SizedBox(height: 8),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(controller: addr, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 8),
            TextField(
                controller: floors,
                decoration: const InputDecoration(labelText: 'Floor count'),
                keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            TextField(
                controller: companies,
                decoration: const InputDecoration(
                    labelText: 'Companies (comma-separated)')),
            const SizedBox(height: 8),
            TextField(
                controller: photo,
                decoration: const InputDecoration(labelText: 'Photo URL')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            await ref.read(buildingsRepositoryProvider).upsert(Building(
                  id: id.text.trim(),
                  name: name.text.trim(),
                  address: addr.text.trim(),
                  floorCount: int.tryParse(floors.text) ?? 1,
                  companies: companies.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
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
