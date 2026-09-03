import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/crops/crops_screen.dart';
import '../../features/farm/farm_information_screen.dart';
import '../../features/history/history_detail_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/language/language_screen.dart';
import '../../features/notifications/notification_center_screen.dart';
import '../../features/notifications/notification_settings_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/result/result_screen.dart';
import '../../features/risk/risk_screen.dart';
import '../../features/scan/analyzing_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/treatment/treatment_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/language', builder: (c, s) => const LanguageScreen()),
      GoRoute(path: '/scan', builder: (c, s) => const ScanScreen()),
      GoRoute(
        path: '/analyzing',
        builder: (c, s) =>
            AnalyzingScreen(imagePath: s.extra as String),
      ),
      GoRoute(path: '/result', builder: (c, s) => const ResultScreen()),
      GoRoute(path: '/treatment', builder: (c, s) => const TreatmentScreen()),
      GoRoute(path: '/risk', builder: (c, s) => const RiskScreen()),
      GoRoute(path: '/assistant', builder: (c, s) => const AssistantScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/notifications',
          builder: (c, s) => const NotificationCenterScreen()),
      GoRoute(path: '/notification-settings',
          builder: (c, s) => const NotificationSettingsScreen()),
      GoRoute(path: '/farm-information',
          builder: (c, s) => const FarmInformationScreen()),
      GoRoute(
        path: '/history/:id',
        builder: (c, s) => HistoryDetailScreen(
            id: int.parse(s.pathParameters['id']!)),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/crops', builder: (c, s) => const CropsScreen()),
          GoRoute(path: '/history', builder: (c, s) => const HistoryScreen()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
        ],
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/crops')) return 1;
    if (loc.startsWith('/history')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, 0, Icons.home_filled, 'Home', '/home'),
                _navItem(context, 1, Icons.spa, 'Crops', '/crops'),
                _scanButton(context),
                _navItem(context, 2, Icons.history, 'History', '/history'),
                _navItem(context, 3, Icons.person, 'Profile', '/profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, String label,
      String path) {
    final selected = _index(context) == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.go(path),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 22,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scanButton(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => context.push('/scan'),
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryLight, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 26),
      ),
    );
  }
}
