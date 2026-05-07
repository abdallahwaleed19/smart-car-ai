// ============================================================
// api_service.dart — Full REST API service layer
// Smart AI Voice Car Controller
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/prediction_model.dart';
import '../utils/constants.dart';

// ─────────────────────────────────────────────────────────────
// Custom Exceptions
// ─────────────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'ApiException($statusCode): $message'
      : 'ApiException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

// ─────────────────────────────────────────────────────────────
// ApiService
// ─────────────────────────────────────────────────────────────
class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // ── Headers ───────────────────────────────────────────────
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true', // skip ngrok browser warning
      };

  // ── Sanitize base URL ─────────────────────────────────────
  String get _base => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  // ─────────────────────────────────────────────────────────
  /// POST /predict — send voice text, get intent + command
  // ─────────────────────────────────────────────────────────
  Future<PredictionResult> predict(String text) async {
    final uri = Uri.parse('$_base${AppConstants.predictEndpoint}');

    try {
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({'text': text}),
          )
          .timeout(AppConstants.httpTimeout);

      return _handlePredictResponse(response);
    } on SocketException {
      throw NetworkException(
          'No internet connection. Check your network settings.');
    } on HttpException {
      throw NetworkException('Failed to reach the server. Is the URL correct?');
    } on FormatException {
      throw ApiException('Invalid response format from server.');
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw NetworkException(
            'Request timed out. The server may be offline or unreachable.');
      }
      throw ApiException('Unexpected error: $e');
    }
  }

  PredictionResult _handlePredictResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PredictionResult.fromJson(json);
      } catch (_) {
        throw ApiException('Failed to parse server response.');
      }
    } else if (response.statusCode == 400) {
      throw ApiException('Bad request: no text provided.', statusCode: 400);
    } else if (response.statusCode == 500) {
      throw ApiException('Server error: AI model may not be loaded.',
          statusCode: 500);
    } else {
      throw ApiException(
        'Unexpected status code: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  /// GET /status — health check
  // ─────────────────────────────────────────────────────────
  Future<ApiStatus> getStatus() async {
    final uri = Uri.parse('$_base${AppConstants.statusEndpoint}');

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiStatus.fromJson(json);
      } else {
        throw ApiException('Status check failed: ${response.statusCode}',
            statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException('Cannot reach backend server.');
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw NetworkException('Status check timed out.');
      }
      throw ApiException('Status check error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  /// POST /test — send a manual command directly
  // ─────────────────────────────────────────────────────────
  Future<bool> sendManualCommand(String command) async {
    final uri = Uri.parse('$_base${AppConstants.testEndpoint}');

    try {
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({'command': command}),
          )
          .timeout(AppConstants.httpTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['sent'] as bool? ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  /// Ping — simple connectivity check
  // ─────────────────────────────────────────────────────────
  Future<bool> ping() async {
    try {
      await getStatus();
      return true;
    } catch (_) {
      return false;
    }
  }
}
