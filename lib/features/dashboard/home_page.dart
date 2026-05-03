import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ts_management/data/models/event.dart';
import 'package:ts_management/data/repositories/repositories.dart';
import 'package:ts_management/features/auth/auth_providers.dart';

final allEventsProvider = StreamProvider<List<CampusEvent>>(
    (ref) => ref.watch(eventsRepositoryProvider).watchAll());

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final events = ref.watch(allEventsProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(
                      user.maybeWhen(
                        data: (u) => u?.name.isNotEmpty == true ? u!.name : 'Welcome',
                        orElse: () => 'Welcome',
                      ),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _QuickActions(),
          const SizedBox(height: 28),

          _SectionHeader(title: "Today's events"),
          const SizedBox(height: 8),
          events.when(
            data: (list) {
              final today = list.where(_isToday).toList();
              if (today.isEmpty) return const _EmptyCard(text: 'No events today');
              return Column(
                children: today.map((e) => _EventCard(event: e)).toList(),
              );
            },
            loading: () => const _SkeletonCard(),
            error: (e, _) => _EmptyCard(text: 'Failed to load: $e'),
          ),
          const SizedBox(height: 28),

          _SectionHeader(title: 'Upcoming'),
          const SizedBox(height: 8),
          events.when(
            data: (list) {
              final upcoming = list
                  .where((e) => e.startTime.isAfter(DateTime.now()))
                  .take(5)
                  .toList();
              if (upcoming.isEmpty) {
                return const _EmptyCard(text: 'Nothing scheduled');
              }
              return Column(
                children: upcoming.map((e) => _EventCard(event: e)).toList(),
              );
            },
            loading: () => const _SkeletonCard(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  static bool _isToday(CampusEvent e) {
    final now = DateTime.now();
    return e.startTime.year == now.year &&
        e.startTime.month == now.month &&
        e.startTime.day == now.day;
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Action(icon: Icons.qr_code_scanner_rounded, label: 'Scan', to: '/scan'),
        const SizedBox(width: 12),
        _Action(icon: Icons.search_rounded, label: 'Search', to: '/search'),
        const SizedBox(width: 12),
        _Action(icon: Icons.map_rounded, label: 'Map', to: '/map'),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.to});
  final IconData icon;
  final String label;
  final String to;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: () => context.go(to),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(icon, color: scheme.primary, size: 28),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) =>
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700));
}

class _EventCard extends ConsumerWidget {
  const _EventCard({required this.event});
  final CampusEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('h:mm a');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context.push('/building/${event.buildingId}'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: event.isActive
                      ? scheme.primary
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.event_rounded,
                    color: event.isActive
                        ? scheme.onPrimary
                        : scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      'Floor ${event.floor} · ${fmt.format(event.startTime)} – ${fmt.format(event.endTime)}',
                      style: TextStyle(
                          color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (event.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('LIVE',
                      style: TextStyle(
                          color: scheme.onTertiaryContainer,
                          fontWeight: FontWeight.w700,
                          fontSize: 11)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: scheme.onSurfaceVariant)),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
