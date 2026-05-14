import 'package:flutter/material.dart';

import 'package:ts_management/core/theme/app_theme.dart';

/// Three columns separated by hairline dividers.
class StatTriple extends StatelessWidget {
  const StatTriple({
    super.key,
    required this.items,
  });

  final List<({String value, String label})> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    Text(items[i].value,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(items[i].label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              if (i < items.length - 1)
                const VerticalDivider(
                  color: AppTheme.surfaceVariant,
                  width: 1,
                  thickness: 1,
                  indent: 6,
                  endIndent: 6,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
