import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/components.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../app.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.goodMorning;
    if (h < 18) return l.goodAfternoon;
    return l.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final weather = ref.watch(weatherProvider);
    final risk = ref.watch(riskProvider);
    final online = ref.watch(connectivityServiceProvider).isOnline;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(weatherProvider);
          ref.invalidate(riskProvider);
        },
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            OfflineBanner(online: online),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greeting(l)}, ${l.farmer}! 👋',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(l.farmSubtitle,
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      ref.read(themeModeProvider.notifier).toggle(),
                  icon: Icon(
                    ref.watch(themeModeProvider) == 'dark'
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    size: 22,
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/notifications'),
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined, size: 26),
                      if (risk.valueOrNull != null &&
                          risk.valueOrNull!
                              .any((d) => d.level.name == 'high'))
                        const Positioned(
                          right: 2,
                          top: 2,
                          child: Icon(Icons.circle,
                              size: 9, color: AppColors.danger),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            weather.when(
              data: (w) => _WeatherCard(w: w, l: l),
              loading: () => const AgroCard(
                  child: SizedBox(
                      height: 90, child: Center(child: CircularProgressIndicator()))),
              error: (e, s) => AgroCard(
                child: Text(l.weatherUnavailable,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: l.quickActions),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _QuickAction(
                  icon: Icons.camera_alt,
                  title: l.scanDisease,
                  subtitle: l.scanDiseaseDesc,
                  onTap: () => context.push('/scan'),
                ),
                _QuickAction(
                  icon: Icons.calendar_month,
                  title: l.sevenDayForecast,
                  subtitle: l.sevenDayForecastDesc,
                  onTap: () => context.push('/risk'),
                ),
                _QuickAction(
                  icon: Icons.spa,
                  title: l.myCrops,
                  subtitle: l.myCropsDesc,
                  onTap: () => context.go('/crops'),
                ),
                _QuickAction(
                  icon: Icons.history,
                  title: l.history,
                  subtitle: l.historyDesc,
                  onTap: () => context.go('/history'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(title: l.fieldAlerts),
            const SizedBox(height: 12),
            risk.when(
              data: (days) {
                final high = days.where((d) => d.level.name == 'high');
                if (high.isEmpty) {
                  return AgroCard(
                    color: AppColors.successLight,
                    child: Row(
                      children: [
                        const Icon(Icons.verified_outlined,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(l.noAlerts,
                                style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  );
                }
                // Show a single deduplicated alert card
                return AgroCard(
                  color: AppColors.dangerLight,
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppColors.danger),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.highRiskAlert('wheat'),
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward,
                            size: 18),
                        onPressed: () => context.push('/risk'),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => AgroCard(
                child: Text(l.weatherUnavailable,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(height: 16),
            AgroCard(
              color: AppColors.primaryLight,
              child: Row(
                children: [
                  const Icon(Icons.psychology_alt, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l.offlineAiDesc,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    onPressed: () => context.push('/assistant'),
                    child: Text(l.assistant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final dynamic w;
  final AppLocalizations l;

  const _WeatherCard({required this.w, required this.l});

  @override
  Widget build(BuildContext context) {
    final today = w.days.isNotEmpty ? w.days.first : null;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 40),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                today == null
                    ? l.weatherUnavailable
                    : '${today.tempC.round()}°C',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                w.isSample ? l.weatherSample : (today?.condition ?? ''),
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${l.humidity} ${today?.humidity ?? '--'}%',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
              const SizedBox(height: 4),
              Text(w.locationName as String,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12)),
              if (w.isSample as bool)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(l.weatherSample,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const Spacer(),
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
