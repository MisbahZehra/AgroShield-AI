import 'dart:ui' show Locale;

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const _kOnboarded = 'onboarded';
  static const _kLang = 'lang';
  static const _kTts = 'tts_enabled';
  static const _kNotifPrefix = 'notif_';
  static const _kFarmPrefix = 'farm_';
  static const _kThemeMode = 'theme_mode';

  @override
  Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboarded) ?? false;
  }

  @override
  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarded, true);
  }

  @override
  Future<Locale?> savedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLang);
    if (code == null) return null;
    return Locale(code);
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, locale.languageCode);
  }

  @override
  Future<bool> ttsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kTts) ?? true;
  }

  @override
  Future<void> setTtsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTts, enabled);
  }

  @override
  Future<bool> notifEnabled(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_kNotifPrefix$key') ?? true;
  }

  @override
  Future<void> setNotifEnabled(String key, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kNotifPrefix$key', enabled);
  }

  @override
  Future<Map<String, String>?> farmInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'location', 'province', 'size', 'soil',
      'notes', 'irrigation', 'farmingType', 'crops',
    ];
    final map = <String, String>{};
    var hasAny = false;
    for (final k in keys) {
      final v = prefs.getString('$_kFarmPrefix$k');
      if (v != null && v.isNotEmpty) hasAny = true;
      map[k] = v ?? '';
    }
    return hasAny ? map : null;
  }

  @override
  Future<void> saveFarmInfo(Map<String, String> info) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in info.entries) {
      await prefs.setString('$_kFarmPrefix${entry.key}', entry.value);
    }
  }

  @override
  Future<String> themeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kThemeMode) ?? 'system';
  }

  @override
  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, mode);
  }
}
