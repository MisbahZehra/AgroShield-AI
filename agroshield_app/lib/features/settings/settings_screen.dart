import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _tts = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await ref.read(settingsRepositoryProvider).ttsEnabled();
    if (mounted) setState(() => _tts = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AgroCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary:
                  const Icon(Icons.record_voice_over, color: AppColors.primary),
              title: Text(l.ttsEnabled,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              value: _tts,
              onChanged: (v) async {
                setState(() => _tts = v);
                await ref.read(settingsRepositoryProvider).setTtsEnabled(v);
                ref.read(ttsServiceProvider).enabled = v;
              },
            ),
          ),
          const SizedBox(height: 12),
          AgroCard(
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.defaultLocation,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        '${AppConstants.defaultLocationName} '
                        '(${AppConstants.defaultLatitude}, ${AppConstants.defaultLongitude})',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AgroCard(
            child: InkWell(
              onTap: () => _confirmClear(context),
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, color: AppColors.danger),
                  const SizedBox(width: 14),
                  Text(l.clearHistory,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.clearHistory),
        content: Text(l.clearHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                minimumSize: const Size(0, 44)),
            onPressed: () async {
              await ref.read(historyRepositoryProvider).clear();
              ref.invalidate(historyProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l.delete),
          ),
        ],
      ),
    );
  }
}
