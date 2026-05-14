import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ts_management/core/theme/app_theme.dart';
import 'package:ts_management/core/widgets/building_tile.dart';
import 'package:ts_management/core/widgets/live_event_card.dart';
import 'package:ts_management/core/widgets/section_header.dart';
import 'package:ts_management/data/models/building.dart';
import 'package:ts_management/data/models/event.dart';
import 'package:ts_management/data/repositories/repositories.dart';
import 'package:ts_management/features/auth/auth_providers.dart';

final allEventsProvider = StreamProvider<List<CampusEvent>>(
    (ref) => ref.watch(eventsRepositoryProvider).watchAll());

final allBuildingsProvider = StreamProvider<List<Building>>(
    (ref) => ref.watch(buildingsRepositoryProvider).watchAll());

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).asData?.value;
    final events = ref.watch(allEventsProvider).asData?.value ?? const [];
    final buildings =
        ref.watch(allBuildingsProvider).asData?.value ?? const <Building>[];

    final followedIds = user?.followedBuildings ?? const <String>[];
    final followed = buildings.where((b) => followedIds.contains(b.id)).toList();
    final currentBuilding = followed.isNotEmpty
        ? followed.first
        : (buildings.isNotEmpty ? buildings.first : null);

    final hereEvents = currentBuilding == null
        ? const <CampusEvent>[]
        : (events.where((e) => e.buildingId == currentBuilding.id).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime)));
    final liveOrSoon =
        hereEvents.where((e) => e.endTime.isAfter(DateTime.now())).take(3).toList();

    final upcomingAtFollowed = events
        .where((e) =>
            followedIds.contains(e.buildingId) &&
            e.startTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _GreetingRow(name: user?.name),
          const SizedBox(height: 16),
          _SearchPill(),
          const SizedBox(height: 18),
          if (currentBuilding != null) _HeroCard(building: currentBuilding),
          const SizedBox(height: 22),
          SectionHeader(title: 'Happening here'),
          const SizedBox(height: 8),
          if (liveOrSoon.isEmpty)
            const _Empty(text: 'Nothing happening right now')
          else
            for (final e in liveOrSoon)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LiveEventCard(
                  event: e,
                  onTap: () => context.push('/building/${e.buildingId}'),
                ),
              ),
          const SizedBox(height: 22),
          SectionHeader(title: 'Followed buildings'),
          const SizedBox(height: 10),
          if (followed.isEmpty)
            const _Empty(text: "You haven't followed any buildings yet")
          else
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.05,
              children: [
                for (final b in followed)
                  BuildingTile(
                    name: b.name,
                    subtitle: _buildingSubtitle(b, events),
                    floorCount: b.floorCount,
                    badgeLabel: _badgeFor(b, events),
                    badgeColor: AppTheme.live,
                    onTap: () => context.push('/building/${b.id}'),
                  ),
              ],
            ),
          const SizedBox(height: 22),
          SectionHeader(title: 'Coming up at your buildings'),
          const SizedBox(height: 10),
          if (upcomingAtFollowed.isEmpty)
            const _Empty(text: 'Nothing scheduled')
          else
            for (final e in upcomingAtFollowed.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ComingUpRow(
                  event: e,
                  onTap: () => context.push('/building/${e.buildingId}'),
                ),
              ),
        ],
      ),
    );
  }

  static String _buildingSubtitle(Building b, List<CampusEvent> events) {
    final n = events.where((e) => e.buildingId == b.id && e.isActive).length;
    if (n > 0) return 'Campus · $n live';
    return 'Campus · ${b.floorCount}F';
  }

  static String? _badgeFor(Building b, List<CampusEvent> events) {
    final live = events.where((e) => e.buildingId == b.id && e.isActive).length;
    if (live > 0) return '$live live';
    return null;
  }
}

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({this.name});
  final String? name;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hello',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                name?.isNotEmpty == true ? name! : 'Welcome',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => _NotificationsSheet(),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: AppTheme.textPrimary, size: 20),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.live,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        InkWell(
              onTap: () => context.push('/profile'),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (name?.isNotEmpty == true ? name![0] : 'U').toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.onPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15),
                  ),
                ),
              ),
            )
      ],
    );
  }
}

class _SearchPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/search'),
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Search building, place or event',
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 14)),
            ),
            GestureDetector(
              onTap: () => context.go('/scan'),
              child: const Icon(Icons.qr_code_scanner_rounded,
                  color: AppTheme.primary, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.building});
  final Building building;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(AppTheme.heroRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("You're inside",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('Floor 2 of ${building.floorCount}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(building.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('North wing · near elevator B',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 14),
          Row(
            children: [
              _QuickChip(
                  icon: Icons.wc_rounded,
                  label: 'Restroom',
                  onTap: () => _routeToTag(context, building.id, 'restroom')),
              const SizedBox(width: 8),
              _QuickChip(
                  icon: Icons.elevator_rounded,
                  label: 'Elevator',
                  onTap: () => _routeToTag(context, building.id, 'elevator')),
              const SizedBox(width: 8),
              _QuickChip(
                  icon: Icons.exit_to_app_rounded,
                  label: 'Exit',
                  onTap: () => _routeToTag(context, building.id, 'exit')),
              const SizedBox(width: 8),
              _QuickChip(
                  icon: Icons.local_cafe_rounded,
                  label: 'Café',
                  onTap: () => _routeToTag(context, building.id, 'cafe')),
            ],
          ),
        ],
      ),
    );
  }

  void _routeToTag(BuildContext context, String buildingId, String tag) {
    context.go('/map');
  }
}

class _ComingUpRow extends StatelessWidget {
  const _ComingUpRow({required this.event, required this.onTap});
  final CampusEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat('EEE').format(event.startTime).toUpperCase();
    final dayNum = DateFormat('d').format(event.startTime);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayLabel,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                  Text(dayNum,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Floor ${event.floor} · ${event.buildingId}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}


class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: Text(text,
            style: const TextStyle(color: AppTheme.textSecondary)),
      );
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      'Event A starts soon',
      'New building added',
      'Reminder: Check your schedule',
    ];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: notifications.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(notifications[i]),
                onTap: () => Navigator.of(context).pop(),
              ),
              separatorBuilder: (_, __) => const Divider(height: 1),
            ),
          ),
        ],
      ),
    );
  }
}
