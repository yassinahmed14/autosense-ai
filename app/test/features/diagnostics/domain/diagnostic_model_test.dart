import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes codes and deduplicates without accepting malformed codes',
      () {
    expect(
        parseCodes('p0300, P0171; p0300\nU0100'), ['P0300', 'P0171', 'U0100']);
    expect(parseCodes('  '), isEmpty);
    expect(() => parseCodes('P9999'), throwsFormatException);
    expect(() => parseCodes('P0300 nonsense'), throwsFormatException);
  });
  test('request preserves safety flags and simulation source', () {
    final json = const DiagnosticInput(
            codes: ['P0300'],
            source: 'mock_obd',
            safetyFlags: ['flashing_mil'],
            safetyCheckCompleted: true)
        .toJson();
    expect(json['source'], 'mock_obd');
    expect(json['safety_flags'], ['flashing_mil']);
    expect(json['safety_check_completed'], true);
  });
}
