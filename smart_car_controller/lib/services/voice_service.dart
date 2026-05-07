// ============================================================
// voice_service.dart — Speech recognition service
// Smart AI Voice Car Controller
// ============================================================

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../utils/constants.dart';

enum VoiceServiceStatus { idle, initializing, listening, processing, error }

class VoiceService {
  final SpeechToText _speech = SpeechToText();

  bool _initialized = false;
  String _currentLocale = AppConstants.localeArabic;

  // ── Callbacks ─────────────────────────────────────────────
  Function(String text)? onResult;
  Function(String text)? onPartialResult;
  Function(VoiceServiceStatus status)? onStatusChange;
  Function(String error)? onError;

  // ── State ─────────────────────────────────────────────────
  bool get isListening => _speech.isListening;
  bool get isAvailable => _initialized;
  String get currentLocale => _currentLocale;

  // ─────────────────────────────────────────────────────────
  /// Initialize the speech engine
  // ─────────────────────────────────────────────────────────
  Future<bool> initialize() async {
    if (_initialized) return true;

    onStatusChange?.call(VoiceServiceStatus.initializing);

    _initialized = await _speech.initialize(
      onError: _onError,
      onStatus: _onStatus,
      debugLogging: false,
    );

    return _initialized;
  }

  // ─────────────────────────────────────────────────────────
  /// Start listening
  // ─────────────────────────────────────────────────────────
  Future<bool> startListening({String? locale}) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) {
        onError?.call('Speech recognition not available on this device.');
        return false;
      }
    }

    if (_speech.isListening) await stopListening();

    _currentLocale = locale ?? _currentLocale;

    onStatusChange?.call(VoiceServiceStatus.listening);

    await _speech.listen(
      onResult: _onResult,
      localeId: _currentLocale,
      listenFor: const Duration(seconds: 30),
      pauseFor: Duration(seconds: AppConstants.voiceSilenceSec),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );

    return true;
  }

  // ─────────────────────────────────────────────────────────
  /// Stop listening
  // ─────────────────────────────────────────────────────────
  Future<void> stopListening() async {
    await _speech.stop();
    onStatusChange?.call(VoiceServiceStatus.idle);
  }

  // ─────────────────────────────────────────────────────────
  /// Cancel listening
  // ─────────────────────────────────────────────────────────
  Future<void> cancel() async {
    await _speech.cancel();
    onStatusChange?.call(VoiceServiceStatus.idle);
  }

  // ─────────────────────────────────────────────────────────
  /// Get available locales
  // ─────────────────────────────────────────────────────────
  Future<List<LocaleName>> getLocales() async {
    if (!_initialized) await initialize();
    return await _speech.locales();
  }

  // ── Set locale ────────────────────────────────────────────
  void setLocale(String locale) {
    _currentLocale = locale;
  }

  // ── Internal callbacks ────────────────────────────────────
  void _onResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords.trim();
    if (text.isEmpty) return;

    if (result.finalResult) {
      onStatusChange?.call(VoiceServiceStatus.processing);
      onResult?.call(text);
    } else {
      onPartialResult?.call(text);
    }
  }

  void _onError(SpeechRecognitionError error) {
    final msg = _friendlyError(error.errorMsg);
    onError?.call(msg);
    onStatusChange?.call(VoiceServiceStatus.error);
  }

  void _onStatus(String status) {
    if (status == 'notListening' || status == 'done') {
      onStatusChange?.call(VoiceServiceStatus.idle);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('permission')) {
      return 'Microphone permission denied. Please enable it in Settings.';
    }
    if (raw.contains('network')) {
      return 'Network error during recognition. Check your connection.';
    }
    if (raw.contains('no-speech') || raw.contains('no_speech')) {
      return 'No speech detected. Please speak clearly and try again.';
    }
    return 'Voice recognition error: $raw';
  }

  // ── Dispose ───────────────────────────────────────────────
  void dispose() {
    _speech.cancel();
  }
}
