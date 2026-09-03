import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const _options = [
    ('en', 'English', 'English'),
    ('ur', 'اردو', 'Urdu'),
    ('sd', 'سنڌي', 'Sindhi'),
    ('pa', 'پنجابی', 'Punjabi'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(localeProvider)?.languageCode;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.translate, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(l.selectLanguage,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(l.languageNote,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              ..._options.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        await ref
                            .read(localeProvider.notifier)
                            .set(Locale(o.$1));
                        if (context.mounted) context.go('/home');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: current == o.$1
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            width: current == o.$1 ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(o.$2,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600)),
                            Text(o.$3,
                                style: const TextStyle(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
