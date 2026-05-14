import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ts_management/core/accessibility/accessibility_controller.dart';
import 'package:ts_management/core/i18n/strings.dart';
import 'package:ts_management/features/settings/_settings_widgets.dart';

class AccessibilityPage extends ConsumerWidget {
  const AccessibilityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(accessibilityControllerProvider);
    final ctrl = ref.read(accessibilityControllerProvider.notifier);
    String t(String k) => Strings.of(context, k);

    return Scaffold(
      appBar: AppBar(title: Text(t('accessibility'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSectionCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_size_rounded),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('a11y_text_size'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            Text(t('a11y_text_size_desc'),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 12,
                                )),
                          ],
                        ),
                      ),
                      Text('${(s.textScale * 100).round()}%',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Slider(
                    value: s.textScale,
                    min: 0.85,
                    max: 1.6,
                    divisions: 15,
                    label: '${(s.textScale * 100).round()}%',
                    onChanged: ctrl.setTextScale,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      t('a11y_preview'),
                      style: TextStyle(
                        fontSize: 16 * s.textScale,
                        fontWeight: s.boldText
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SettingsSectionCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: s.highContrast,
                  onChanged: ctrl.setHighContrast,
                  secondary: const Icon(Icons.contrast_rounded),
                  title: Text(t('a11y_high_contrast'),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(t('a11y_high_contrast_desc')),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: s.reduceMotion,
                  onChanged: ctrl.setReduceMotion,
                  secondary: const Icon(Icons.motion_photos_off_rounded),
                  title: Text(t('a11y_reduce_motion'),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(t('a11y_reduce_motion_desc')),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: s.boldText,
                  onChanged: ctrl.setBoldText,
                  secondary: const Icon(Icons.format_bold_rounded),
                  title: Text(t('a11y_bold_text'),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(t('a11y_bold_text_desc')),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: s.largeTouchTargets,
                  onChanged: ctrl.setLargeTouchTargets,
                  secondary: const Icon(Icons.pan_tool_alt_rounded),
                  title: Text(t('a11y_large_targets'),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(t('a11y_large_targets_desc')),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: s.screenReaderHints,
                  onChanged: ctrl.setScreenReaderHints,
                  secondary: const Icon(Icons.record_voice_over_rounded),
                  title: Text(t('a11y_screen_reader'),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(t('a11y_screen_reader_desc')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: ctrl.resetAll,
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(t('a11y_reset')),
          ),
        ],
      ),
    );
  }
}
