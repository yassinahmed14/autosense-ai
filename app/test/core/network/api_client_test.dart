import 'dart:convert';
import 'dart:io';

import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/features/diagnostics/data/offline_diagnostic_engine.dart';
import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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
  test(
      'hybrid smart mode falls back to 56-code offline engine when API is unreachable',
      () async {
    final hybrid = ApiClient(
      baseUrl: 'http://localhost',
      offlineFallback: true,
      client: MockClient((_) async {
        throw http.ClientException('underground garage offline');
      }),
    );
    addTearDown(hybrid.close);
    final dtc = await hybrid.lookup('b0001');
    expect(dtc.found, isTrue);
    expect(dtc.code, 'B0001');
    expect(dtc.title, contains('Driver frontal stage 1'));

    final diag = await hybrid.diagnose(
      const DiagnosticInput(
        codes: ['P0300', 'C0031'],
        symptoms: ['rough_idle'],
        safetyCheckCompleted: true,
      ),
    );
    expect(diag.urgency, 'urgent');
    expect(diag.causes, isNotEmpty);
    expect(OfflineDiagnosticEngine.catalog.length, 56);
    expect(OfflineDiagnosticEngine.filterCatalog(system: 'C').length, 3);
    expect(OfflineDiagnosticEngine.filterCatalog(system: 'B').length, 2);
    expect(OfflineDiagnosticEngine.filterCatalog(system: 'U').length, 5);
  });
}
