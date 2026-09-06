import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../l10n/gen/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.face,
                      size: 44, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ali Bux',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const Text(
                  '+92 300 1234567',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AgroCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                _item(context, Icons.spa, l.farmInformation, null,
                    () => context.push('/farm-information')),
                _divider(),
                _item(context, Icons.notifications_outlined,
                    l.notificationSettings, null,
                    () => context.push('/notification-settings')),
                _divider(),
                _item(context, Icons.translate, l.language, null,
                    () => context.push('/language')),
                _divider(),
                _item(context, Icons.smart_toy, l.assistant, null,
                    () => context.push('/assistant')),
                _divider(),
                _item(context, Icons.settings_outlined, l.settingsTitle,
                    null, () => context.push('/settings')),
                _divider(),
                _item(context, Icons.help_outline, l.helpSupport, null,
                    () => _infoDialog(context, l.helpSupport, l.helpBody)),
                _divider(),
                _item(context, Icons.info_outline, l.about, null,
                    () => _infoDialog(context, l.about, l.aboutBody)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${l.appVersion} 1.0.0',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 56, endIndent: 8);

  Widget _item(BuildContext context, IconData icon, String label,
      String? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            if (value != null)
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _infoDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }
}
