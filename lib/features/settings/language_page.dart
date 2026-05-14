import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/core/i18n/locale_controller.dart';
import 'package:ts_management/core/i18n/strings.dart';
import 'package:ts_management/features/settings/_settings_widgets.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(localeControllerProvider);
    String t(String k) => Strings.of(context, k);

    Widget tile(String code, String label, String flag) {
      final isSelected = selected?.languageCode == code;
      return RadioListTile<String>(
        value: code,
        groupValue: selected?.languageCode ?? '_system',
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(_subtitleFor(code)),
        secondary: Text(flag, style: const TextStyle(fontSize: 24)),
        onChanged: (_) =>
            ref.read(localeControllerProvider.notifier).set(Locale(code)),
        selected: isSelected,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t('language'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSectionLabel(t('lang_choose')),
          SettingsSectionCard(
            child: Column(children: [
              tile('en', t('english'), '🇬🇧'),
              const Divider(height: 1),
              tile('mn', t('mongolian'), '🇲🇳'),
              const Divider(height: 1),
              RadioListTile<String>(
                value: '_system',
                groupValue: selected?.languageCode ?? '_system',
                title: Text(t('system_default'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(t('lang_app_subtitle')),
                secondary: const Icon(Icons.phone_iphone_rounded),
                onChanged: (_) =>
                    ref.read(localeControllerProvider.notifier).set(null),
                selected: selected == null,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  String _subtitleFor(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'mn':
        return 'Монгол хэл';
      default:
        return '';
    }
  }
}
