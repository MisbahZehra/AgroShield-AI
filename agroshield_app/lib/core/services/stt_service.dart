import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Speech-to-text service with manual-toggle continuous listening.
///
/// The mic stays active indefinitely, auto-restarting the underlying
/// STT engine each time it pauses, until [stopListening] is called.
class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;
  bool _available = false;
  String _localeId = 'en_US';

  /// True while the user wants the mic to keep listening.
  bool _shouldListen = false;

  /// Accumulates recognised words across auto-restart cycles.
  final StringBuffer _buffer = StringBuffer();

  /// Called with the final accumulated text when listening stops.
  void Function(String text)? _onFinished;

  bool get isAvailable => _available;
  bool get isListening => _shouldListen;

  /// Initialize the STT engine. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    try {
      _available = await _stt.initialize(
        onStatus: _onStatusChange,
        onError: (error) => debugPrint('STT error: $error'),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('STT init failed: $e');
      _available = false;
    }
  }

  /// Called on every STT status change.
  void _onStatusChange(String status) {
    if (status == 'notListening' && _shouldListen) {
      // The engine paused — auto-restart to keep listening.
      _startSession();
    }
  }

  /// Internal: start a single STT listen session.
  Future<void> _startSession() async {
    if (!_shouldListen || !_available) return;
    try {
      await _stt.listen(
        onResult: (SpeechRecognitionResult result) {
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            if (_buffer.isNotEmpty) _buffer.write(' ');
            _buffer.write(result.recognizedWords);
          }
        },
        listenOptions: SpeechListenOptions(
          partialResults: false,
          cancelOnError: false,
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 3),
          localeId: _localeId,
        ),
      );
    } catch (e) {
      debugPrint('STT listen session error: $e');
      // If a session fails while we should still be listening, retry once
      // after a short delay.
      if (_shouldListen) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_shouldListen) _startSession();
        });
      }
    }
  }

  /// Start continuous listening. The mic stays active until [stopListening].
  /// [onFinished] is called with the accumulated recognised text when
  /// the user taps stop.
  Future<void> startListening({
    required void Function(String text) onFinished,
  }) async {
    if (!_available) return;
    _onFinished = onFinished;
    _buffer.clear();
    _shouldListen = true;
    await _startSession();
  }

  /// Stop listening and deliver accumulated text.
  Future<void> stopListening() async {
    _shouldListen = false;
    try {
      await _stt.stop();
    } catch (_) {}
    final text = _buffer.toString().trim();
    _buffer.clear();
    if (text.isNotEmpty) {
      _onFinished?.call(text);
    }
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
