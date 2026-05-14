import 'package:flutter/material.dart';

import 'package:ts_management/core/theme/app_theme.dart';
import 'package:ts_management/data/models/event.dart';

/// Event tile used on the home "Happening here" section.
/// - Live event: pink left-border + pink LIVE pill + thin progress bar.
/// - Upcoming: muted, "in Xh" chip.
class LiveEventCard extends StatelessWidget {
  const LiveEventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final CampusEvent event;
  final VoidCallback? onTap;

  double _progress() {
    final now = DateTime.now();
    final total = event.endTime.difference(event.startTime).inSeconds;
    if (total <= 0) return 0;
    final passed = now.difference(event.startTime).inSeconds;
    return (passed / total).clamp(0.0, 1.0);
  }

  String _untilLabel() {
    final diff = event.startTime.difference(DateTime.now());
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(0, 99)}m';
    if (diff.inHours < 48) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final isLive = event.isActive;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: isLive
              ? const Border(
                  left: BorderSide(color: AppTheme.live, width: 4),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.live,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'in ${_untilLabel()}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Floor ${event.floor}${event.roomId != null ? ' · ${event.roomId}' : ''}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
            if (isLive) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: _progress(),
                  minHeight: 3,
                  backgroundColor: AppTheme.surfaceVariant,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.live),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
