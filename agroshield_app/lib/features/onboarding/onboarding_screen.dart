import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsRepositoryProvider).setOnboarded();
    if (mounted) context.go('/language');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pages = [
      _Page(Icons.biotech, l.onboard1Title, l.onboard1Body),
      _Page(Icons.offline_bolt, l.onboard2Title, l.onboard2Body),
      _Page(Icons.cloudy_snowing, l.onboard3Title, l.onboard3Body),
      _Page(Icons.record_voice_over, l.onboard4Title, l.onboard4Body),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: TextButton(
                onPressed: _finish,
                child: Text(l.skip,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (v) => setState(() => _page = v),
                children: pages
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              e.key == 0
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(90),
                                      child: Image.asset(
                                        'assets/images/onboarding_farmer.png',
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 180,
                                      height: 180,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(e.value.icon,
                                          size: 90,
                                          color: AppColors.primary),
                                    ),
                              const SizedBox(height: 40),
                              Text(
                                e.value.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                e.value.body,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textSecondary,
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton(
                onPressed: () {
                  if (_page == pages.length - 1) {
                    _finish();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(
                    _page == pages.length - 1 ? l.getStarted : l.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Page {
  final IconData icon;
  final String title;
  final String body;
  const _Page(this.icon, this.title, this.body);
}
