import 'dart:ui' show Locale;

abstract class SettingsRepository {
  Future<bool> isOnboarded();
  Future<void> setOnboarded();
  Future<Locale?> savedLocale();
  Future<void> saveLocale(Locale locale);
  Future<bool> ttsEnabled();
  Future<void> setTtsEnabled(bool enabled);
  Future<bool> notifEnabled(String key);
  Future<void> setNotifEnabled(String key, bool enabled);
  Future<Map<String, String>?> farmInfo();
  Future<void> saveFarmInfo(Map<String, String> info);
  Future<String> themeMode();
  Future<void> saveThemeMode(String mode);
}
