import 'package:flutter/material.dart';

import 'package:ts_management/core/theme/app_theme.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.value,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? value;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? AppTheme.danger : AppTheme.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
            if (value != null) ...[
              Text(value!,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(width: 6),
            ],
            if (!danger)
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(const Divider(
            height: 1, color: AppTheme.surfaceVariant, indent: 56));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(children: items),
    );
  }
}
