import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/data/models/building.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildings = ref.watch(buildingsRepositoryProvider).watchAll();
    return SafeArea(
      child: StreamBuilder<List<Building>>(
        stream: buildings,
        builder: (context, snap) {
          final list = snap.data ?? const <Building>[];
          if (list.isEmpty && snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Buildings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ...list.map((b) => _BuildingCard(b: b)),
            ],
          );
        },
      ),
    );
  }
}

class _BuildingCard extends StatelessWidget {
  const _BuildingCard({required this.b});
  final Building b;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => context.push('/building/${b.id}'),
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: scheme.surfaceContainerHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: b.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: b.photoUrl!, fit: BoxFit.cover)
                      : Container(color: scheme.primaryContainer),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(b.address,
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.layers_rounded,
                            size: 16, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('${b.floorCount} floors',
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
