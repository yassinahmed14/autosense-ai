import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/diagnostic.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({required String baseUrl, http.Client? client})
      : baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _client = client ?? http.Client();
  final String baseUrl;
  final http.Client _client;

  Future<Map<String, dynamic>> _request(String path,
      {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await (body == null
              ? _client.get(uri)
              : _client.post(uri,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(body)))
          .timeout(const Duration(seconds: 15));
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
    final json = await _request('/v1/diagnostics', body: input.toJson());
    try {
      return DiagnosticResult.fromJson(json);
    } on TypeError {
      throw const ApiException(
          'The server returned an invalid diagnostic result.');
    } on FormatException {
      throw const ApiException(
          'The server returned an invalid diagnostic result.');
    }
  }

  Future<DtcLookup> lookup(String code) async {
    final json = await _request(
        '/v1/dtc/${Uri.encodeComponent(code.trim().toUpperCase())}');
    try {
      return DtcLookup.fromJson(json);
    } on TypeError {
      throw const ApiException('The server returned an invalid DTC result.');
    }
  }

  void close() => _client.close();
}
