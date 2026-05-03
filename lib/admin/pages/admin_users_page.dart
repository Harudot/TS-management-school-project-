import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/data/models/app_user.dart';
import 'package:ts_management/data/repositories/repositories.dart';

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(firestoreProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Users',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
              'Note: promoting users to admin requires the Cloud Function `setAdminClaim`. This page also flips the role field in Firestore.',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: db.collection('users').snapshots(),
              builder: (context, snap) {
                final docs = snap.data?.docs ?? const [];
                if (docs.isEmpty) return const Center(child: Text('No users'));
                return ListView(
                  children: docs.map((d) {
                    final u = AppUser.fromMap(d.id, d.data());
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: u.photoUrl != null
                              ? NetworkImage(u.photoUrl!)
                              : null,
                          child: u.photoUrl == null
                              ? Text(u.name.isNotEmpty ? u.name[0] : '?')
                              : null,
                        ),
                        title: Text(u.name.isEmpty ? u.email : u.name),
                        subtitle: Text('${u.email} · role=${u.role}'),
                        trailing: u.role == 'admin'
                            ? OutlinedButton(
                                onPressed: () => db
                                    .collection('users')
                                    .doc(u.uid)
                                    .update({'role': 'user'}),
                                child: const Text('Demote'),
                              )
                            : FilledButton(
                                onPressed: () => db
                                    .collection('users')
                                    .doc(u.uid)
                                    .update({'role': 'admin'}),
                                child: const Text('Promote'),
                              ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
