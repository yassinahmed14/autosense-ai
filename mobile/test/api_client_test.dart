import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:autosense_ai/models/diagnostic.dart';
import 'package:autosense_ai/services/api_client.dart';

void main() {
  test('parses the real backend contract fixture', () async {
    final fixture = File('test/fixtures/result.json').readAsStringSync();
    final api = ApiClient(
        baseUrl: 'http://localhost:8000/',
        client: MockClient((request) async {
          expect(request.url.path, '/v1/diagnostics');
          expect(jsonDecode(request.body)['source'], 'mock_obd');
          return http.Response(fixture, 200);
        }));
    addTearDown(api.close);
    final result = await api
        .diagnose(const DiagnosticInput(codes: ['P0300'], source: 'mock_obd'));
    expect(result.simulated, isTrue);
    expect(result.causes, isNotEmpty);
    expect(result.dtcs.first.code, 'P0300');
  });
  test('lookup unknown code preserves missing coverage', () async {
    final api = ApiClient(
        baseUrl: 'http://localhost:8000',
        client: MockClient((request) async {
          expect(request.url.path, '/v1/dtc/P1234');
          return http.Response(
              jsonEncode({
                'code': 'P1234',
                'found': false,
                'entry': null,
                'message': 'Not in catalog'
              }),
              200);
        }));
    addTearDown(api.close);
    expect((await api.lookup('p1234')).found, isFalse);
  });
  test('network and validation failures are useful errors', () async {
    final api = ApiClient(
        baseUrl: 'http://localhost',
        client: MockClient((_) async => http.Response('{}', 422)));
    addTearDown(api.close);
    await expectLater(api.lookup('P0300'), throwsA(isA<ApiException>()));
    final offline = ApiClient(
        baseUrl: 'http://localhost',
        client: MockClient((_) async {
          throw http.ClientException('offline');
        }));
    addTearDown(offline.close);
    await expectLater(offline.lookup('P0300'), throwsA(isA<ApiException>()));
  });
  test('malformed successful response is rejected', () async {
    final api = ApiClient(
        baseUrl: 'http://localhost',
        client: MockClient((_) async => http.Response('{}', 200)));
    addTearDown(api.close);
    await expectLater(api.diagnose(const DiagnosticInput(codes: ['P0300'])),
        throwsA(isA<ApiException>()));
  });
}
