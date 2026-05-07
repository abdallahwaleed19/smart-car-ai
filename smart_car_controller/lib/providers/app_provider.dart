// ============================================================
// app_provider.dart — Global state management (Provider)
// Smart AI Voice Car Controller
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prediction_model.dart';
import '../services/api_service.dart';
import '../services/voice_service.dart';
import '../utils/constants.dart';

// ─────────────────────────────────────────────────────────────
// App State Enums
// ─────────────────────────────────────────────────────────────
enum AppState { idle, listening, processing, error }

// Named ApiConnectionState to avoid conflict with Flutter's ConnectionState
enum ApiConnectionState { unknown, connected, disconnected, checking }

// ─────────────────────────────────────────────────────────────
// AppProvider
// ─────────────────────────────────────────────────────────────
class AppProvider extends ChangeNotifier {
  // ── Services ──────────────────────────────────────────────
  late ApiService _apiService;
  final VoiceService _voiceService = VoiceService();

  // ── Prefs ─────────────────────────────────────────────────
  late SharedPreferences _prefs;
  bool _prefsReady = false;

  // ── Settings ──────────────────────────────────────────────
  String _apiUrl = AppConstants.defaultApiUrl;
  bool _isDarkMode = true;
  String _selectedLocale = AppConstants.localeArabic;

  // ── App State ─────────────────────────────────────────────
  AppState _appState = AppState.idle;
  ApiConnectionState _connectionState = ApiConnectionState.unknown;

  // ── Voice ─────────────────────────────────────────────────
  String _recognizedText = '';
  String _partialText = '';
  bool _isListening = false;
  String _voiceError = '';

  // ── AI Result ─────────────────────────────────────────────
  PredictionResult? _lastPrediction;
  bool _isProcessing = false;
  String _apiError = '';

  // ── History ───────────────────────────────────────────────
  final List<CommandHistoryItem> _history = [];

  // ── Status ────────────────────────────────────────────────
  ApiStatus? _apiStatus;

  // ─────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────
  String get apiUrl => _apiUrl;
  bool get isDarkMode => _isDarkMode;
  String get selectedLocale => _selectedLocale;
  bool get isArabic => _selectedLocale == AppConstants.localeArabic;

  AppState get appState => _appState;
  ApiConnectionState get connectionState => _connectionState;

  String get recognizedText => _recognizedText;
  String get partialText => _partialText;
  bool get isListening => _isListening;
  String get voiceError => _voiceError;

  PredictionResult? get lastPrediction => _lastPrediction;
  bool get isProcessing => _isProcessing;
  String get apiError => _apiError;

  List<CommandHistoryItem> get history =>
      List.unmodifiable(_history.reversed.toList());
  ApiStatus? get apiStatus => _apiStatus;

  bool get isConnected => _connectionState == ApiConnectionState.connected;
  bool get isIdle => _appState == AppState.idle;

  // ─────────────────────────────────────────────────────────
  // Init
  // ─────────────────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _prefsReady = true;
    _loadPrefs();
    _initApiService();
    _initVoiceService();
    _loadHistory();
    notifyListeners();
  }

  void _loadPrefs() {
    _apiUrl = _prefs.getString(AppConstants.kApiUrl) ?? AppConstants.defaultApiUrl;
    _isDarkMode = _prefs.getBool(AppConstants.kDarkMode) ?? true;
    _selectedLocale = _prefs.getString(AppConstants.kLanguage) ?? AppConstants.localeArabic;
  }

  void _initApiService() {
    _apiService = ApiService(baseUrl: _apiUrl);
  }

  void _initVoiceService() {
    _voiceService.onResult = _onVoiceFinal;
    _voiceService.onPartialResult = _onVoicePartial;
    _voiceService.onStatusChange = _onVoiceStatus;
    _voiceService.onError = _onVoiceError;
  }

  void _loadHistory() {
    try {
      final raw = _prefs.getString(AppConstants.kCommandHistory);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      _history.clear();
      for (final item in list) {
        _history.add(CommandHistoryItem.fromJson(item as Map<String, dynamic>));
      }
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    if (!_prefsReady) return;
    final list = _history
        .take(AppConstants.maxHistoryItems)
        .map((e) => e.toJson())
        .toList();
    await _prefs.setString(AppConstants.kCommandHistory, jsonEncode(list));
  }

  // ─────────────────────────────────────────────────────────
  // Settings Actions
  // ─────────────────────────────────────────────────────────
  Future<void> updateApiUrl(String url) async {
    _apiUrl = url.trim();
    await _prefs.setString(AppConstants.kApiUrl, _apiUrl);
    _initApiService();
    _connectionState = ApiConnectionState.unknown;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(AppConstants.kDarkMode, _isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool dark) async {
    _isDarkMode = dark;
    await _prefs.setBool(AppConstants.kDarkMode, _isDarkMode);
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    _selectedLocale = locale;
    _voiceService.setLocale(locale);
    await _prefs.setString(AppConstants.kLanguage, locale);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Connection Check
  // ─────────────────────────────────────────────────────────
  Future<bool> checkConnection() async {
    _connectionState = ApiConnectionState.checking;
    _apiError = '';
    notifyListeners();

    try {
      _apiStatus = await _apiService.getStatus();
      _connectionState = ApiConnectionState.connected;
      notifyListeners();
      return true;
    } catch (e) {
      _connectionState = ApiConnectionState.disconnected;
      _apiError = e.toString().replaceAll(RegExp(r'^[A-Za-z]+Exception: '), '');
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Voice Control
  // ─────────────────────────────────────────────────────────
  Future<void> startListening() async {
    if (_isListening) return;

    _voiceError = '';
    _apiError = '';
    _partialText = '';
    _recognizedText = '';
    _appState = AppState.listening;
    _isListening = true;
    notifyListeners();

    final ok = await _voiceService.startListening(locale: _selectedLocale);
    if (!ok) {
      _isListening = false;
      _appState = AppState.error;
      _voiceError = 'Could not start voice recognition.';
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    await _voiceService.stopListening();
    _isListening = false;
    _appState = AppState.idle;
    _partialText = '';
    notifyListeners();
  }

  // ── Voice callbacks ───────────────────────────────────────
  void _onVoicePartial(String text) {
    _partialText = text;
    notifyListeners();
  }

  void _onVoiceFinal(String text) async {
    _recognizedText = text;
    _partialText = '';
    _isListening = false;
    notifyListeners();

    // Auto-send to AI
    await sendToAI(text);
  }

  void _onVoiceStatus(VoiceServiceStatus status) {
    switch (status) {
      case VoiceServiceStatus.idle:
        if (_appState == AppState.listening) {
          _isListening = false;
          _appState = AppState.idle;
          notifyListeners();
        }
        break;
      case VoiceServiceStatus.processing:
        _appState = AppState.processing;
        notifyListeners();
        break;
      default:
        break;
    }
  }

  void _onVoiceError(String error) {
    _voiceError = error;
    _isListening = false;
    _appState = AppState.error;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // AI Prediction
  // ─────────────────────────────────────────────────────────
  Future<void> sendToAI(String text) async {
    if (text.isEmpty) return;

    _isProcessing = true;
    _apiError = '';
    _appState = AppState.processing;
    notifyListeners();

    try {
      final result = await _apiService.predict(text);
      _lastPrediction = result;
      _connectionState = ApiConnectionState.connected;

      // Add to history
      final histItem = CommandHistoryItem.fromPrediction(result);
      _history.insert(0, histItem);
      if (_history.length > AppConstants.maxHistoryItems) {
        _history.removeLast();
      }
      await _saveHistory();
    } catch (e) {
      _apiError = e.toString().replaceAll(RegExp(r'^[A-Za-z]+Exception: '), '');
      _connectionState = ApiConnectionState.disconnected;
      _appState = AppState.error;
    } finally {
      _isProcessing = false;
      if (_appState != AppState.error) _appState = AppState.idle;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // Manual Commands
  // ─────────────────────────────────────────────────────────
  Future<void> sendManualCommand(String command) async {
    _isProcessing = true;
    _apiError = '';
    notifyListeners();

    try {
      final ok = await _apiService.sendManualCommand(command);
      if (ok) {
        _connectionState = ApiConnectionState.connected;
        // Create a synthetic result for display
        _lastPrediction = PredictionResult(
          input: '[Manual]',
          cleanText: '[Manual]',
          intent: command.toLowerCase(),
          command: command,
          confidence: 100.0,
          mqttSent: true,
        );
        final histItem = CommandHistoryItem(
          voiceText: '[Manual: $command]',
          command: command,
          intent: command.toLowerCase(),
          confidence: 100.0,
          success: true,
        );
        _history.insert(0, histItem);
        await _saveHistory();
      } else {
        _apiError = 'Manual command failed. Check API connection.';
      }
    } catch (e) {
      _apiError = e.toString().replaceAll(RegExp(r'^[A-Za-z]+Exception: '), '');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // History
  // ─────────────────────────────────────────────────────────
  Future<void> clearHistory() async {
    _history.clear();
    await _prefs.remove(AppConstants.kCommandHistory);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Clear errors
  // ─────────────────────────────────────────────────────────
  void clearErrors() {
    _voiceError = '';
    _apiError = '';
    if (_appState == AppState.error) _appState = AppState.idle;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Dispose
  // ─────────────────────────────────────────────────────────
  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
