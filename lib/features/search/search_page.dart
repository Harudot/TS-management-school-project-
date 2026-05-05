import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/data/models/event.dart';
import 'package:ts_management/data/models/person.dart';
import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/repositories/repositories.dart';
import 'package:ts_management/features/navigation/start_point_picker.dart';

final _allRoomsProvider = FutureProvider<List<RoomDoc>>((ref) async {
  final repo = ref.watch(buildingsRepositoryProvider);
  final buildings = await repo.watchAll().first;
  final all = <RoomDoc>[];
  for (final b in buildings) {
    all.addAll(await repo.rooms(b.id));
  }
  return all;
});

final _allPeopleProvider = StreamProvider<List<Person>>(
    (ref) => ref.watch(peopleRepositoryProvider).watchAll());

final _allEventsProvider = StreamProvider<List<CampusEvent>>(
    (ref) => ref.watch(eventsRepositoryProvider).watchAll());

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search rooms, people, events…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Rooms'),
              Tab(text: 'People'),
              Tab(text: 'Events'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _RoomsTab(query: _query),
                _PeopleTab(query: _query),
                _EventsTab(query: _query),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomsTab extends ConsumerWidget {
  const _RoomsTab({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(_allRoomsProvider);
    return rooms.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        final filtered = query.isEmpty
            ? list
            : list
                .where((r) =>
                    r.number.toLowerCase().contains(query) ||
                    r.name.toLowerCase().contains(query))
                .toList();
        if (filtered.isEmpty) return const _Empty('No rooms');
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final r = filtered[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                    child: Text(r.number,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700))),
                title: Text(r.name),
                subtitle: Text('Floor ${r.floor}'),
                trailing: const Icon(Icons.navigation_rounded),
                onTap: () => _startNavigation(context, 'main', r.waypointId,
                    '${r.number} · ${r.name}'),
              ),
            );
          },
        );
      },
    );
  }
}

class _PeopleTab extends ConsumerWidget {
  const _PeopleTab({required this.query});
  final String query;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(_allPeopleProvider);
    return people.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        final filtered = query.isEmpty
            ? list
            : list
                .where((p) =>
                    p.name.toLowerCase().contains(query) ||
                    p.role.toLowerCase().contains(query) ||
                    p.department.toLowerCase().contains(query))
                .toList();
        if (filtered.isEmpty) return const _Empty('No people');
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final p = filtered[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      p.photoUrl != null ? NetworkImage(p.photoUrl!) : null,
                  child: p.photoUrl == null
                      ? Text(p.name.isNotEmpty ? p.name[0] : '?')
                      : null,
                ),
                title: Text(p.name),
                subtitle: Text('${p.role} · ${p.department}'),
                trailing: const Icon(Icons.navigation_rounded),
                onTap: () => _navigateToPerson(context, ref, p),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _navigateToPerson(
      BuildContext context, WidgetRef ref, Person p) async {
    if (p.roomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No office set for ${p.name}')),
      );
      return;
    }
    final rooms =
        await ref.read(buildingsRepositoryProvider).rooms(p.buildingId);
    final room = rooms.where((r) => r.id == p.roomId).firstOrNull;
    if (!context.mounted) return;
    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${p.name}'s office (${p.roomId}) not found")),
      );
      return;
    }
    _startNavigation(
        context, p.buildingId, room.waypointId, "${p.name}'s office");
  }
}

class _EventsTab extends ConsumerWidget {
  const _EventsTab({required this.query});
  final String query;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(_allEventsProvider);
    return events.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        final filtered = query.isEmpty
            ? list
            : list
                .where((e) =>
                    e.title.toLowerCase().contains(query) ||
                    e.description.toLowerCase().contains(query))
                .toList();
        if (filtered.isEmpty) return const _Empty('No events');
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final e = filtered[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.event_rounded),
                title: Text(e.title),
                subtitle: Text('Floor ${e.floor}'),
                onTap: () => context.push('/building/${e.buildingId}'),
              ),
            );
          },
        );
      },
    );
  }
}

void _startNavigation(
    BuildContext context, String buildingId, String endWaypoint, String label) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => StartPointPicker(
      buildingId: buildingId,
      endWaypointId: endWaypoint,
      destinationLabel: label,
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Center(
        child: Text(text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}
