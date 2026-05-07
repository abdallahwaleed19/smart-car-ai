// ============================================================
// constants.dart — App-wide constants
// Smart AI Voice Car Controller
// ============================================================

class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────
  static const String appName = 'Smart Car AI';
  static const String appVersion = 'v1.0.0';
  static const String appTagline = 'Voice-Powered Smart Control';

  // ── SharedPreferences Keys ────────────────────────────────
  static const String kApiUrl = 'api_url';
  static const String kDarkMode = 'dark_mode';
  static const String kLanguage = 'language';
  static const String kCommandHistory = 'command_history';

  // ── Default Backend URL ───────────────────────────────────
  static const String defaultApiUrl =
      'https://YOUR-NGROK-URL.ngrok-free.app';

  // ── API Endpoints ─────────────────────────────────────────
  static const String predictEndpoint = '/predict';
  static const String statusEndpoint = '/status';
  static const String testEndpoint = '/test';

  // ── HTTP ──────────────────────────────────────────────────
  static const Duration httpTimeout = Duration(seconds: 15);

  // ── Voice ─────────────────────────────────────────────────
  static const String localeArabic = 'ar-EG';
  static const String localeEnglish = 'en-US';
  static const int voiceSilenceSec = 3;
  static const int maxHistoryItems = 50;

  // ── Commands ──────────────────────────────────────────────
  static const Map<String, String> commandIcons = {
    'FORWARD': '⬆',
    'BACKWARD': '⬇',
    'LEFT': '⬅',
    'RIGHT': '➡',
    'STOP': '⏹',
  };

  static const Map<String, String> commandLabels = {
    'FORWARD': 'Forward',
    'BACKWARD': 'Backward',
    'LEFT': 'Left',
    'RIGHT': 'Right',
    'STOP': 'Stop',
  };

  static const Map<String, String> commandArabicLabels = {
    'FORWARD': 'قدام',
    'BACKWARD': 'ورا',
    'LEFT': 'شمال',
    'RIGHT': 'يمين',
    'STOP': 'وقف',
  };
}
