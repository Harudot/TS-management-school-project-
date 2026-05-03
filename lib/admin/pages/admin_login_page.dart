import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/features/auth/auth_providers.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});
  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInEmail(_email.text.trim(), _pw.text);
      final token = await FirebaseAuth.instance.currentUser?.getIdTokenResult(true);
      if (token?.claims?['role'] != 'admin') {
        await ref.read(authServiceProvider).signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Not an admin account')));
        }
        return;
      }
      if (mounted) context.go('/admin/overview');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Admin sign in',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pw,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _login,
                child: Text(_loading ? '…' : 'Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
