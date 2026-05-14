import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/core/theme/app_theme.dart';
import 'package:ts_management/data/models/event.dart';
import 'package:ts_management/data/models/person.dart';
import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/repositories/repositories.dart';
import 'package:ts_management/features/navigation/start_point_picker.dart';

final _allRoomsProvider = FutureProvider<List<({String buildingId, RoomDoc room})>>((ref) async {
  final repo = ref.watch(buildingsRepositoryProvider);
  final buildings = await repo.watchAll().first;
  final all = <({String buildingId, RoomDoc room})>[];
  for (final b in buildings) {
    for (final r in await repo.rooms(b.id)) {
      all.add((buildingId: b.id, room: r));
    }
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

class _SearchPageState extends ConsumerState<SearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(_allRoomsProvider).asData?.value ??
        const <({String buildingId, RoomDoc room})>[];
    final people =
        ref.watch(_allPeopleProvider).asData?.value ?? const <Person>[];
    final events =
        ref.watch(_allEventsProvider).asData?.value ?? const <CampusEvent>[];
    final personById = {for (final p in people) p.id: p};

    final q = _query.toLowerCase();
    final results = <_SearchResult>[];
    if (q.isNotEmpty) {
      for (final entry in rooms) {
        final r = entry.room;
        final occupantNames = r.occupantIds
            .map((id) => personById[id]?.name ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        final matches = r.number.toLowerCase().contains(q) ||
            r.name.toLowerCase().contains(q) ||
            occupantNames.any((n) => n.toLowerCase().contains(q));
        if (!matches) continue;
        results.add(_SearchResult.room(
          buildingId: entry.buildingId,
          room: r,
          occupantPreview: occupantNames.take(2).join(', '),
        ));
      }
      for (final p in people) {
        if (p.name.toLowerCase().contains(q) ||
            p.role.toLowerCase().contains(q) ||
            p.department.toLowerCase().contains(q)) {
          results.add(_SearchResult.person(p));
        }
      }
      for (final e in events) {
        if (e.title.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q)) {
          results.add(_SearchResult.event(e));
        }
      }
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: const InputDecoration(
                hintText: 'Room number, name, or person…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: q.isEmpty
                ? const Center(
                    child: Text(
                      'Try "305", "Багш нарын" or a name',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : results.isEmpty
                    ? const Center(
                        child: Text('No matches',
                            style:
                                TextStyle(color: AppTheme.textSecondary)),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: results.length,
                        itemBuilder: (_, i) => _ResultTile(
                          result: results[i],
                          peopleById: personById,
                          rooms: rooms,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SearchResult {
  final _Kind kind;
  final RoomDoc? room;
  final String? buildingId;
  final String? occupantPreview;
  final Person? person;
  final CampusEvent? event;

  _SearchResult.room({
    required RoomDoc this.room,
    required String this.buildingId,
    required String this.occupantPreview,
  })  : kind = _Kind.room,
        person = null,
        event = null;
  _SearchResult.person(Person p)
      : kind = _Kind.person,
        person = p,
        room = null,
        buildingId = null,
        occupantPreview = null,
        event = null;
  _SearchResult.event(CampusEvent e)
      : kind = _Kind.event,
        event = e,
        person = null,
        room = null,
        buildingId = null,
        occupantPreview = null;
}

enum _Kind { room, person, event }

class _ResultTile extends ConsumerWidget {
  const _ResultTile({
    required this.result,
    required this.peopleById,
    required this.rooms,
  });
  final _SearchResult result;
  final Map<String, Person> peopleById;
  final List<({String buildingId, RoomDoc room})> rooms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (result.kind) {
      case _Kind.room:
        final r = result.room!;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.surfaceVariant,
              child: Text(r.number,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800)),
            ),
            title: Text(r.name,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(
                'Floor ${r.floor}${result.occupantPreview!.isEmpty ? '' : ' · ${result.occupantPreview}'}'),
            trailing: const Icon(Icons.navigation_rounded),
            onTap: () => _startNavigation(
                context, result.buildingId!, r.waypointId,
                '${r.number} · ${r.name}'),
          ),
        );
      case _Kind.person:
        final p = result.person!;
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
            title: Text(p.name,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${p.role} · ${p.department}'),
            trailing: const Icon(Icons.navigation_rounded),
            onTap: () async {
              if (p.roomId == null) return;
              final match = rooms
                  .where((r) => r.room.id == p.roomId)
                  .firstOrNull;
              if (match == null || !context.mounted) return;
              _startNavigation(context, match.buildingId,
                  match.room.waypointId, "${p.name}'s office");
            },
          ),
        );
      case _Kind.event:
        final e = result.event!;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.event_rounded),
            title: Text(e.title),
            subtitle: Text('Floor ${e.floor} · ${e.buildingId}'),
            onTap: () => context.push('/building/${e.buildingId}'),
          ),
        );
    }
  }
}

void _startNavigation(BuildContext context, String buildingId,
    String endWaypoint, String label) {
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
