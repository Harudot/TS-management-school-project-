import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/core/i18n/strings.dart';
import 'package:ts_management/data/repositories/repositories.dart';
import 'package:ts_management/features/auth/auth_providers.dart';
import 'package:ts_management/features/settings/_settings_widgets.dart';

class _Faq {
  final String q;
  final String a;
  const _Faq(this.q, this.a);
}

const _faqs = <_Faq>[
  _Faq('How do I follow a building?',
      'Open the building from the home page or search and tap the heart icon. Followed buildings stay on your home screen and you get updates.'),
  _Faq('How does indoor navigation work?',
      'Pick a destination from the map, then choose your starting point. The app traces a route across floors using stairs and elevators.'),
  _Faq('Why does scanning a QR code go nowhere?',
      'Make sure the QR is the campus QR (it starts with campus://). Otherwise, it opens externally.'),
  _Faq('Can I use the app offline?',
      'Maps and basic navigation work offline if you have visited the building once with internet access.'),
  _Faq('I cannot sign in. What should I do?',
      'Check your email and password. Use Forgot password to reset, or contact your administrator if your account was just created.'),
];

class HelpFeedbackPage extends ConsumerStatefulWidget {
  const HelpFeedbackPage({super.key});

  @override
  ConsumerState<HelpFeedbackPage> createState() => _HelpFeedbackPageState();
}

class _HelpFeedbackPageState extends ConsumerState<HelpFeedbackPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    String t(String k) => Strings.of(context, k);
    final filtered = _query.trim().isEmpty
        ? _faqs
        : _faqs
            .where((f) =>
                f.q.toLowerCase().contains(_query.toLowerCase()) ||
                f.a.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text(t('help_feedback'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: t('help_search'),
              prefixIcon: const Icon(Icons.search_rounded),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 18),
          SettingsSectionLabel(t('help_faq')),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: Text('—',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
            )
          else
            SettingsSectionCard(
              child: Column(children: [
                for (var i = 0; i < filtered.length; i++) ...[
                  _FaqTile(faq: filtered[i]),
                  if (i != filtered.length - 1) const Divider(height: 1),
                ]
              ]),
            ),
          const SizedBox(height: 18),
          SettingsSectionLabel(t('help_contact')),
          SettingsSectionCard(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.feedback_rounded),
                title: Text(t('help_send_feedback'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _openFeedbackSheet,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email_rounded),
                title: Text(t('help_email_support'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('support@erdenetis.edu.mn'),
                trailing: const Icon(Icons.copy_rounded, size: 18),
                onTap: () {
                  Clipboard.setData(const ClipboardData(
                      text: 'support@erdenetis.edu.mn'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Copied support@erdenetis.edu.mn')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.bug_report_rounded),
                title: Text(t('help_report_issue'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _openFeedbackSheet,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.menu_book_rounded),
                title: Text(t('help_view_guide'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Guide will open at help.erdenetis.edu.mn')),
                  );
                },
              ),
            ]),
          ),
          const SizedBox(height: 18),
          SettingsSectionCard(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.gavel_rounded),
                title: Text(t('help_terms'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline_rounded),
                title: Text(t('help_privacy_policy'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(t('help_version'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Text('1.0.0'),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _openFeedbackSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: _FeedbackSheet(),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});
  final _Faq faq;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.help_outline_rounded),
      title: Text(faq.q,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      childrenPadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
      expandedAlignment: Alignment.centerLeft,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(faq.a)],
    );
  }
}

class _FeedbackSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<_FeedbackSheet> {
  final _ctrl = TextEditingController();
  String _kind = 'feedback';
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      final user = ref.read(currentUserProvider).asData?.value;
      final db = ref.read(firestoreProvider);
      await db.collection('feedback').add({
        'kind': _kind,
        'message': _ctrl.text.trim(),
        'uid': user?.uid,
        'email': user?.email,
        'name': user?.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.of(context, 'help_feedback_thanks'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String k) => Strings.of(context, k);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              )),
        ),
        const SizedBox(height: 12),
        Text(t('help_send_feedback'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
                value: 'feedback',
                icon: const Icon(Icons.feedback_outlined),
                label: Text(t('help_send_feedback'))),
            ButtonSegment(
                value: 'bug',
                icon: const Icon(Icons.bug_report_outlined),
                label: Text(t('help_report_issue'))),
          ],
          selected: {_kind},
          onSelectionChanged: (s) => setState(() => _kind = s.first),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ctrl,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: t('help_feedback_describe'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    _sending ? null : () => Navigator.pop(context),
                child: Text(t('help_feedback_cancel')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _sending ? null : _send,
                icon: const Icon(Icons.send_rounded),
                label: Text(_sending ? '…' : t('help_feedback_send')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
