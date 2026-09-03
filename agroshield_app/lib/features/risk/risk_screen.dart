import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class RiskScreen extends ConsumerWidget {
  const RiskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final risk = ref.watch(riskProvider);
    final weather = ref.watch(weatherProvider);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.riskTitle),
        actions: [
          AudioButton(
            text: risk.valueOrNull == null
                ? l.weatherUnavailable
                : '${l.riskSubtitle} '
                    '${risk.valueOrNull!
                        .map((d) =>
                            '${DateFormat.EEEE(locale.toString()).format(d.date)}: ${_levelText(l, d.level.name)}')
                        .take(3)
                        .join('. ')}',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(weatherProvider);
          ref.invalidate(riskProvider);
        },
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.riskSubtitle,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        Text(l.ruleBasedNote,
                            style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.85),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (weather.valueOrNull?.isSample == true)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l.noWeather,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.warning)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            risk.when(
              data: (days) => AgroCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    for (var i = 0; i < days.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 74,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    i == 0
                                        ? l.today
                                        : DateFormat.EEEE(
                                                locale.toString())
                                            .format(days[i].date),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    DateFormat.MMMd(locale.toString())
                                        .format(days[i].date),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                          Icons.water_drop_outlined,
                                          size: 14,
                                          color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text('${days[i].humidity}%',
                                          style: const TextStyle(
                                              fontSize: 12)),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.umbrella_outlined,
                                          size: 14,
                                          color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text('${days[i].rainChance}%',
                                          style: const TextStyle(
                                              fontSize: 12)),
                                      const SizedBox(width: 12),
                                      Text(
                                          '${days[i].tempC.round()}°C',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors
                                                  .textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _levelText(l, days[i].level.name),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: switch (days[i].level.name) {
                                  'high' => AppColors.danger,
                                  'medium' => AppColors.warning,
                                  _ => AppColors.primary,
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            RiskDot(level: days[i].level.name),
                          ],
                        ),
                      ),
                      if (i != days.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
              ),
              loading: () => const LoadingView(),
              error: (e, s) => ErrorView(
                message: l.weatherUnavailable,
                onRetry: () => ref.invalidate(riskProvider),
              ),
            ),
            const SizedBox(height: 16),
            AgroCard(
              color: AppColors.successLight,
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined,
                      color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.ruleBasedNote,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _levelText(AppLocalizations l, String level) => switch (level) {
        'high' => l.riskHigh,
        'medium' => l.riskMedium,
        _ => l.riskLow,
      };
}
