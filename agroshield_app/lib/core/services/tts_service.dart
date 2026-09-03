import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool enabled = true;

  Future<void> init() async {
    if (_ready) return;
    try {
      await _tts.setSpeechRate(0.5);
      _ready = true;
    } catch (e) {
      debugPrint('TTS init failed: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    final locale = switch (languageCode) {
      'ur' => 'ur-PK',
      'sd' => 'sd-PK',
      'pa' => 'pa-PK',
      _ => 'en-US',
    };
    try {
      await _tts.setLanguage(locale);
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    if (!enabled) return;
    await init();
    if (!_ready) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak failed: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
