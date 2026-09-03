import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final risk = ref.watch(riskProvider);
    final weather = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.notifications)),
      body: risk.when(
        data: (riskDays) {
          final alerts = <_AlertItem>[];

          // Generate alerts from high-risk days
          for (final d in riskDays) {
            if (d.level.name == 'high') {
              alerts.add(_AlertItem(
                icon: Icons.warning_amber_rounded,
                color: AppColors.danger,
                title: l.highRiskAlert('crop'),
                subtitle: _riskReason(d),
                time: _formatDate(d.date),
              ));
            }
          }

          // Weather-based alert
          weather.whenData((w) {
            if (!w.isSample && w.days.isNotEmpty) {
              final today = w.days.first;
              if (today.rainChance > 60) {
                alerts.insert(
                  0,
                  _AlertItem(
                    icon: Icons.water_drop,
                    color: Colors.blue,
                    title: l.rainAlert,
                    subtitle: '${l.rainChance} ${today.rainChance}%',
                    time: l.today,
                  ),
                );
              }
            }
          });

          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(l.noNotifications,
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (ctx, i) {
              final a = alerts[i];
              return AgroCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: a.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(a.icon, color: a.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(a.subtitle,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Text(a.time,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Text(l.weatherUnavailable,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  String _riskReason(dynamic d) {
    final parts = <String>[];
    if (d.humidity > 75) parts.add('High humidity (${d.humidity}%)');
    if (d.rainChance > 50) parts.add('Rain likely (${d.rainChance}%)');
    if (d.tempC > 30) parts.add('Warm (${d.tempC.toStringAsFixed(0)}°C)');
    return parts.isEmpty
        ? 'Elevated disease risk from weather conditions'
        : '${parts.join(', ')} may increase fungal disease risk.';
  }
}

class _AlertItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _AlertItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}
