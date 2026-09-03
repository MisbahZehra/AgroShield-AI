import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final _keys = [
    const _NotifKey('disease_risk', Icons.eco),
    const _NotifKey('weather', Icons.cloud),
    const _NotifKey('high_risk', Icons.warning),
    const _NotifKey('seven_day', Icons.calendar_month),
    const _NotifKey('daily_summary', Icons.summarize),
  ];

  final _values = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(settingsRepositoryProvider);
    for (final k in _keys) {
      _values[k.id] = await repo.notifEnabled(k.id);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [
      l.diseaseRiskAlerts,
      l.weatherAlerts,
      l.highRiskAlerts,
      l.sevenDayRiskAlerts,
      l.dailyFarmSummary,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.notificationSettings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AgroCard(
            child: Column(
              children: [
                for (var i = 0; i < _keys.length; i++) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(_keys[i].icon, color: AppColors.primary),
                    title: Text(labels[i],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    value: _values[_keys[i].id] ?? true,
                    onChanged: (v) async {
                      setState(() => _values[_keys[i].id] = v);
                      await ref
                          .read(settingsRepositoryProvider)
                          .setNotifEnabled(_keys[i].id, v);
                    },
                  ),
                  if (i < _keys.length - 1)
                    const Divider(height: 1, indent: 56, endIndent: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l.notifSettingsHint,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _NotifKey {
  final String id;
  final IconData icon;
  const _NotifKey(this.id, this.icon);
}
