import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Speech-to-text service wrapping the device's native STT engine.
/// Used by the assistant screen's microphone button.
class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;
  bool _available = false;
  String _localeId = 'en_US';
  void Function()? _onDone;

  bool get isAvailable => _available;

  /// Initialize the STT engine. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    try {
      _available = await _stt.initialize(
        onStatus: (status) {
          if (status == 'notListening') {
            _onDone?.call();
          }
        },
        onError: (error) => debugPrint('STT error: $error'),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('STT init failed: $e');
      _available = false;
    }
  }

  /// Start listening. [onResult] is called with final recognized text.
  /// [onDone] is called when the STT engine stops listening.
  Future<void> startListening({
    required void Function(String text) onResult,
    void Function()? onDone,
  }) async {
    if (!_available) return;
    _onDone = onDone;
    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: false,
        cancelOnError: true,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: _localeId,
      ),
    );
  }

  /// Stop listening immediately.
  Future<void> stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }

  /// Set the recognition language for future listen sessions.
  void setLanguage(String languageCode) {
    _localeId = switch (languageCode) {
      'ur' => 'ur_PK',
      'sd' => 'sd_PK',
      'pa' => 'pa_PK',
      _ => 'en_US',
    };
  }
}
