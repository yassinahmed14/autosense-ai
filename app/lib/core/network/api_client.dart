import 'dart:async';
import 'dart:convert';

import 'package:autosense_ai/features/diagnostics/data/offline_diagnostic_engine.dart';
import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    required String baseUrl,
    http.Client? client,
    bool? offlineFallback,
  })  : baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _client = client ?? http.Client(),
        offlineFallback = offlineFallback ?? (client == null);

  final String baseUrl;
  final http.Client _client;

  /// When true (default in production builds), network/timeout errors
  /// automatically fall back to the built-in 56-code [OfflineDiagnosticEngine]
  /// so the app works in underground garages or while connected to a Wi-Fi
  /// OBD-II adapter without internet.
  final bool offlineFallback;

  Future<Map<String, dynamic>> _request(String path,
      {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final timeout = offlineFallback
          ? const Duration(seconds: 4)
          : const Duration(seconds: 15);
      final response = await (body == null
              ? _client.get(uri)
              : _client.post(uri,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(body)))
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode == 422
            ? 'The API rejected the input. Check codes and symptom selections.'
            : 'API error (${response.statusCode}). Try again.');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw const ApiException(
          'Request timed out. Check your API address and connection.');
    } on http.ClientException {
      throw const ApiException(
          'Cannot reach the API. Check that the server is running.');
    } on FormatException {
      throw const ApiException('The server returned an invalid response.');
    } on TypeError {
      throw const ApiException('The server returned an invalid response.');
    }
  }

  Future<DiagnosticResult> diagnose(DiagnosticInput input) async {
    try {
      final json = await _request('/v1/diagnostics', body: input.toJson());
      return DiagnosticResult.fromJson(json);
    } on ApiException catch (error) {
      if (offlineFallback &&
          (error.message.startsWith('Cannot reach the API') ||
              error.message.startsWith('Request timed out'))) {
        return OfflineDiagnosticEngine.diagnose(input);
      }
      rethrow;
    } on TypeError {
      throw const ApiException(
          'The server returned an invalid diagnostic result.');
    } on FormatException {
      throw const ApiException(
          'The server returned an invalid diagnostic result.');
    }
  }

  Future<DtcLookup> lookup(String code) async {
    final normalized = code.trim().toUpperCase();
    try {
      final json = await _request('/v1/dtc/${Uri.encodeComponent(normalized)}');
      return DtcLookup.fromJson(json);
    } on ApiException catch (error) {
      if (offlineFallback &&
          (error.message.startsWith('Cannot reach the API') ||
              error.message.startsWith('Request timed out'))) {
        return OfflineDiagnosticEngine.lookup(normalized);
      }
      rethrow;
    } on TypeError {
      throw const ApiException('The server returned an invalid DTC result.');
    }
  }

  void close() => _client.close();
}
