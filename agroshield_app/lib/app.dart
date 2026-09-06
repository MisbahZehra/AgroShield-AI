import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'l10n/gen/app_localizations.dart';
import 'providers/app_providers.dart';

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale?>((ref) => LocaleNotifier());

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final saved = await SettingsRepositoryImpl().savedLocale();
    if (saved != null) state = saved;
  }

  Future<void> set(Locale locale) async {
    state = locale;
    await SettingsRepositoryImpl().saveLocale(locale);
  }
}

/// Theme mode provider: "light" | "dark" | "system"
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, String>((ref) => ThemeModeNotifier());

class ThemeModeNotifier extends StateNotifier<String> {
  ThemeModeNotifier() : super('system') {
    _load();
  }

  Future<void> _load() async {
    state = await SettingsRepositoryImpl().themeMode();
  }

  Future<void> set(String mode) async {
    state = mode;
    await SettingsRepositoryImpl().saveThemeMode(mode);
  }

  Future<void> toggle() async {
    final next = state == 'light' ? 'dark' : 'light';
    await set(next);
  }
}

ThemeMode _resolveTheme(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

class AgroShieldApp extends ConsumerStatefulWidget {
  const AgroShieldApp({super.key});

  @override
  ConsumerState<AgroShieldApp> createState() => _AgroShieldAppState();
}

class _AgroShieldAppState extends ConsumerState<AgroShieldApp> {
  late final GoRouter _router = buildRouter();

  @override
  void initState() {
    super.initState();
    ref.read(connectivityServiceProvider).init();
    ref.read(ttsServiceProvider).init();
    ref.read(sttServiceProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    ref.listen<Locale?>(localeProvider, (prev, next) {
      if (next != null) {
        ref.read(ttsServiceProvider).setLanguage(next.languageCode);
        ref.read(sttServiceProvider).setLanguage(next.languageCode);
      }
    });
    return MaterialApp.router(
      title: 'AgroShield AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(locale ?? const Locale('en')),
      darkTheme: AppTheme.buildDark(locale ?? const Locale('en')),
      themeMode: _resolveTheme(themeMode),
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
        Locale('sd'),
        Locale('pa'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
