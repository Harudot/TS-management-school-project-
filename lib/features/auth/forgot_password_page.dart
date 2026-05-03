import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/features/auth/auth_providers.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).sendPasswordReset(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Reset password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text("We'll send a reset link to your email."),
              const SizedBox(height: 24),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading || _sent ? null : _submit,
                child: Text(_sent ? 'Email sent ✓' : 'Send reset link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
