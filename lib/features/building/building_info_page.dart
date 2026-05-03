import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ts_management/data/models/building.dart';
import 'package:ts_management/data/models/event.dart';
import 'package:ts_management/data/models/room.dart';
import 'package:ts_management/data/repositories/repositories.dart';
import 'package:ts_management/features/auth/auth_providers.dart';

class BuildingInfoPage extends ConsumerWidget {
  const BuildingInfoPage({super.key, required this.buildingId});
  final String buildingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(buildingsRepositoryProvider);
    final eventsRepo = ref.watch(eventsRepositoryProvider);

    return Scaffold(
      body: FutureBuilder<Building?>(
        future: repo.get(buildingId),
        builder: (context, snap) {
          if (!snap.hasData && snap.connectionState == ConnectionState.waiting) {
            return _Fallback(child: const Center(child: CircularProgressIndicator()));
          }
          final b = snap.data;
          if (b == null) {
            return const _Fallback(
              child: Center(child: Text('Building not found')),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(b.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  background: b.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: b.photoUrl!, fit: BoxFit.cover)
                      : Container(color: Theme.of(context).colorScheme.primaryContainer),
                ),
                actions: [
                  Consumer(builder: (_, ref, __) {
                    final user = ref.watch(currentUserProvider).asData?.value;
                    final following = user?.followedBuildings.contains(b.id) ?? false;
                    return IconButton(
                      icon: Icon(following
                          ? Icons.notifications_active
                          : Icons.notifications_outlined),
                      onPressed: () async {
                        if (user == null) return;
                        final repo = ref.read(usersRepositoryProvider);
                        if (following) {
                          await repo.unfollowBuilding(user.uid, b.id);
                        } else {
                          await repo.followBuilding(user.uid, b.id);
                        }
                      },
                    );
                  }),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList.list(children: [
                  Text(b.address,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 20),
                  if (b.companies.isNotEmpty) ...[
                    _SectionTitle('Companies & departments'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: b.companies
                          .map((c) => Chip(label: Text(c)))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _SectionTitle('Live events'),
                  const SizedBox(height: 8),
                  StreamBuilder<List<CampusEvent>>(
                    stream: eventsRepo.watchForBuilding(b.id),
                    builder: (context, s) {
                      final list = s.data ?? const <CampusEvent>[];
                      if (list.isEmpty) {
                        return const _Empty(text: 'No events scheduled');
                      }
                      return Column(
                          children: list.map((e) => _EventTile(event: e)).toList());
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('Floors'),
                  const SizedBox(height: 8),
                  StreamBuilder<List<RoomDoc>>(
                    stream: repo.watchRooms(b.id),
                    builder: (context, s) {
                      final rooms = s.data ?? const <RoomDoc>[];
                      final byFloor = <int, List<RoomDoc>>{};
                      for (final r in rooms) {
                        byFloor.putIfAbsent(r.floor, () => []).add(r);
                      }
                      final floors = byFloor.keys.toList()..sort();
                      return Column(
                        children: floors.map((f) {
                          return _FloorTile(
                            floor: f,
                            rooms: byFloor[f]!,
                            buildingId: b.id,
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => context.go('/search'),
                    icon: const Icon(Icons.navigation_rounded),
                    label: const Text('Navigate to a room'),
                  ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700));
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final CampusEvent event;
  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('h:mm a');
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.event_rounded, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'F${event.floor} · ${fmt.format(event.startTime)}–${fmt.format(event.endTime)}',
                  style: TextStyle(
                      color: scheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorTile extends StatelessWidget {
  const _FloorTile({
    required this.floor,
    required this.rooms,
    required this.buildingId,
  });
  final int floor;
  final List<RoomDoc> rooms;
  final String buildingId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(),
        title: Text('Floor $floor',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${rooms.length} rooms',
            style: TextStyle(color: scheme.onSurfaceVariant)),
        children: rooms
            .map((r) => ListTile(
                  leading: const Icon(Icons.meeting_room_outlined),
                  title: Text('${r.number} · ${r.name}'),
                  trailing: const Icon(Icons.navigation_rounded, size: 18),
                  onTap: () {},
                ))
            .toList(),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}
