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

  /// Guard against recursive _startSession calls.
  bool _starting = false;

  /// Accumulates recognised words across auto-restart cycles.
  final StringBuffer _buffer = StringBuffer();

  /// Called with the final accumulated text when listening stops.
  void Function(String text)? _onFinished;

  /// Visible status text for on-screen debug indicator.
  String _statusText = 'STT: not initialized';
  String get statusText => _statusText;

  /// Called whenever status text changes, so UI can update.
  void Function(String status)? onStatusChanged;

  /// Last error received from STT engine (for debug display).
  String _lastError = '';
  String get lastError => _lastError;

  bool get isAvailable => _available;
  bool get isListening => _shouldListen;

  void _setStatus(String text) {
    _statusText = text;
    onStatusChanged?.call(text);
    debugPrint(text);
  }

  /// Initialize the STT engine. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    try {
      _setStatus('STT: initializing...');
      _available = await _stt.initialize(
        onStatus: _onStatusChange,
        onError: (error) {
          _lastError = 'Error: ${error.errorMsg} (permanent: ${error.permanent})';
          _setStatus('STT error: ${error.errorMsg}');
          debugPrint('STT onError: msg=${error.errorMsg}, permanent=${error.permanent}');
        },
      );
      // List supported locales for debugging
      final locales = await _stt.locales();
      debugPrint('STT supported locales: ${locales.map((l) => l.localeId).join(", ")}');
      _setStatus(_available
          ? 'STT: ready (locale: $_localeId)'
          : 'STT: NOT available');
      _initialized = true;
    } catch (e) {
      _setStatus('STT init failed: $e');
      _lastError = 'Init exception: $e';
      _available = false;
    }
  }

  /// Called on every STT status change.
  void _onStatusChange(String status) {
    debugPrint('STT status: $status (shouldListen=$_shouldListen, starting=$_starting)');
    if (status == 'listening') {
      _setStatus('STT: listening...');
    } else if (status == 'notListening' && _shouldListen && !_starting) {
      _setStatus('STT: restarting...');
      // The engine paused — auto-restart after a short delay.
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_shouldListen && !_starting) {
          _startSession();
        }
      });
    }
  }

  /// Internal: start a single STT listen session.
  Future<void> _startSession() async {
    if (!_shouldListen || !_available || _starting) {
      debugPrint('STT _startSession skipped: shouldListen=$_shouldListen, available=$_available, starting=$_starting');
      return;
    }
    _starting = true;
    try {
      debugPrint('STT _startSession: calling listen() with locale=$_localeId');
      await _stt.listen(
        onResult: (SpeechRecognitionResult result) {
          debugPrint('STT result: final=${result.finalResult}, words="${result.recognizedWords}"');
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            if (_buffer.isNotEmpty) _buffer.write(' ');
            _buffer.write(result.recognizedWords);
            _setStatus('STT: heard "${result.recognizedWords}"');
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
      debugPrint('STT listen() returned successfully');
    } catch (e) {
      _setStatus('STT listen error: $e');
      _lastError = 'Listen exception: $e';
      debugPrint('STT listen session error: $e');
    } finally {
      _starting = false;
    }
    // If listen() blocked until session ended, restart now.
    if (_shouldListen && _available) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_shouldListen && !_starting) _startSession();
      });
    }
  }

  /// Start continuous listening. The mic stays active until [stopListening].
  /// [onFinished] is called with the accumulated recognised text when
  /// the user taps stop.
  Future<void> startListening({
    required void Function(String text) onFinished,
  }) async {
    if (!_available) {
      _setStatus('STT: not available — cannot start');
      return;
    }
    _onFinished = onFinished;
    _buffer.clear();
    _shouldListen = true;
    _starting = false;
    _setStatus('STT: starting...');
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
    _setStatus('STT: stopped (heard ${text.length} chars)');
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
    _setStatus('STT: ready (locale: $_localeId)');
  }
}
