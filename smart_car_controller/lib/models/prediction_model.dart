// ============================================================
// prediction_model.dart — API response data model
// Smart AI Voice Car Controller
// ============================================================

class PredictionResult {
  final String input;
  final String cleanText;
  final String intent;
  final String command;
  final double? confidence;
  final bool lowConfidence;
  final bool mqttSent;
  final DateTime timestamp;

  PredictionResult({
    required this.input,
    required this.cleanText,
    required this.intent,
    required this.command,
    this.confidence,
    this.lowConfidence = false,
    this.mqttSent = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Parse from JSON response
  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      input: json['input']?.toString() ?? '',
      cleanText: json['clean_text']?.toString() ?? '',
      intent: json['intent']?.toString() ?? 'unknown',
      command: json['command']?.toString() ?? 'STOP',
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
      lowConfidence: json['low_confidence'] as bool? ?? false,
      mqttSent: json['mqtt_sent'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'input': input,
        'clean_text': cleanText,
        'intent': intent,
        'command': command,
        'confidence': confidence,
        'low_confidence': lowConfidence,
        'mqtt_sent': mqttSent,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Confidence as display string
  String get confidenceDisplay =>
      confidence != null ? '${confidence!.toStringAsFixed(1)}%' : 'N/A';

  /// True if confidence >= 60%
  bool get isHighConfidence => (confidence ?? 0) >= 60.0;

  @override
  String toString() =>
      'PredictionResult(command: $command, intent: $intent, confidence: $confidenceDisplay)';
}

// ─────────────────────────────────────────────────────────────
// ApiStatus — backend health model
// ─────────────────────────────────────────────────────────────
class ApiStatus {
  final bool modelLoaded;
  final bool mqttConnected;
  final String? modelError;
  final double threshold;
  final MqttStats? mqttStats;

  ApiStatus({
    required this.modelLoaded,
    required this.mqttConnected,
    this.modelError,
    this.threshold = 60.0,
    this.mqttStats,
  });

  factory ApiStatus.fromJson(Map<String, dynamic> json) {
    return ApiStatus(
      modelLoaded: json['model_loaded'] as bool? ?? false,
      mqttConnected: json['mqtt_connected'] as bool? ?? false,
      modelError: json['model_error']?.toString(),
      threshold: (json['threshold'] as num?)?.toDouble() ?? 60.0,
      mqttStats: json['mqtt_stats'] != null
          ? MqttStats.fromJson(json['mqtt_stats'])
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MqttStats
// ─────────────────────────────────────────────────────────────
class MqttStats {
  final int sent;
  final int failed;
  final String? last;
  final String? lastTime;

  MqttStats({
    required this.sent,
    required this.failed,
    this.last,
    this.lastTime,
  });

  factory MqttStats.fromJson(Map<String, dynamic> json) {
    return MqttStats(
      sent: (json['sent'] as num?)?.toInt() ?? 0,
      failed: (json['failed'] as num?)?.toInt() ?? 0,
      last: json['last']?.toString(),
      lastTime: json['last_time']?.toString(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CommandHistoryItem
// ─────────────────────────────────────────────────────────────
class CommandHistoryItem {
  final String voiceText;
  final String command;
  final String intent;
  final double? confidence;
  final bool success;
  final DateTime timestamp;

  CommandHistoryItem({
    required this.voiceText,
    required this.command,
    required this.intent,
    this.confidence,
    required this.success,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory CommandHistoryItem.fromPrediction(PredictionResult result) {
    return CommandHistoryItem(
      voiceText: result.input,
      command: result.command,
      intent: result.intent,
      confidence: result.confidence,
      success: result.mqttSent,
    );
  }

  Map<String, dynamic> toJson() => {
        'voiceText': voiceText,
        'command': command,
        'intent': intent,
        'confidence': confidence,
        'success': success,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CommandHistoryItem.fromJson(Map<String, dynamic> json) {
    return CommandHistoryItem(
      voiceText: json['voiceText']?.toString() ?? '',
      command: json['command']?.toString() ?? '',
      intent: json['intent']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble(),
      success: json['success'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}
