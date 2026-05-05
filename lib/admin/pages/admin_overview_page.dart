import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/data/repositories/repositories.dart';

final _countsProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = ref.watch(firestoreProvider);
  Future<int> count(String c) async =>
      (await db.collection(c).count().get()).count ?? 0;
  return {
    'buildings': await count('buildings'),
    'people': await count('people'),
    'events': await count('events'),
    'users': await count('users'),
  };
});

class AdminOverviewPage extends ConsumerWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(_countsProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          counts.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (c) => Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(label: 'Buildings', value: c['buildings']!, icon: Icons.apartment_rounded),
                _StatCard(label: 'People', value: c['people']!, icon: Icons.people_rounded),
                _StatCard(label: 'Events', value: c['events']!, icon: Icons.event_rounded),
                _StatCard(label: 'Users', value: c['users']!, icon: Icons.person_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, size: 28),
          const SizedBox(height: 12),
          Text('$value',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
