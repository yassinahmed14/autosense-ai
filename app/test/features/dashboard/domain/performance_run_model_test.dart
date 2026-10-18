import 'package:autosense_ai/features/calculator/domain/power_calculator_model.dart';
import 'package:autosense_ai/features/dashboard/domain/performance_run_model.dart';
import 'package:autosense_ai/features/dashboard/domain/telemetry_model.dart';
import 'package:flutter_test/flutter_test.dart';

List<TelemetrySample> samples({double step = 0.2, int count = 51}) =>
    List.generate(count, (i) {
      final time = DateTime.utc(2026, 10, 12)
          .add(Duration(microseconds: (i * step * 1e6).round()));
      return TelemetrySample(
          speedKph: 36 + i * step * 3.6,
          rpm: 3000 + i * 40,
          speedAt: time,
          rpmAt: time,
          simulated: true);
    });

void main() {
  test('run derives net acceleration power from mass and captured speeds', () {
    final result = estimateRun(samples(), 1000);
    // 10 to 20 m/s over 10 s: delta kinetic energy = 150 kJ.
    expect(result.averageHp, closeTo(15000 / wattsPerHorsepower, 1e-8));
    expect(result.peakWindowHp, greaterThan(result.averageHp));
    expect(result.equivalentTorqueNm, greaterThan(0));
    expect(result.simulated, isTrue);
    expect(result.samples, 51);
  });
  test('mass changes estimate proportionally', () {
    expect(estimateRun(samples(), 2000).averageHp,
        closeTo(estimateRun(samples(), 1000).averageHp * 2, 1e-8));
  });
  test('reject insufficient, slow, short and invalid recordings', () {
    for (final input in [
      samples(count: 10),
      samples(step: 1.1, count: 21),
      samples(count: 25),
      samples(step: 0.01)
    ]) {
      expect(() => estimateRun(input, 1000), throwsFormatException);
    }
    for (final mass in [double.nan, double.infinity, 0.0, 7000.0]) {
      expect(() => estimateRun(samples(), mass), throwsFormatException);
    }
  });
  test(
      'mixed provenance, stale RPM, nonmonotonic time and speed spikes are refused',
      () {
    final original = samples();
    final s = original[10];
    for (final bad in [
      TelemetrySample(
          speedKph: s.speedKph,
          rpm: s.rpm,
          speedAt: s.speedAt,
          rpmAt: s.rpmAt,
          simulated: false),
      TelemetrySample(
          speedKph: s.speedKph,
          rpm: s.rpm,
          speedAt: s.speedAt,
          rpmAt: s.rpmAt.add(const Duration(seconds: 2)),
          simulated: true),
      TelemetrySample(
          speedKph: s.speedKph,
          rpm: s.rpm,
          speedAt: original[9].speedAt,
          rpmAt: original[9].rpmAt,
          simulated: true),
      TelemetrySample(
          speedKph: 200,
          rpm: s.rpm,
          speedAt: s.speedAt,
          rpmAt: s.rpmAt,
          simulated: true),
    ]) {
      final changed = List<TelemetrySample>.of(original)..[10] = bad;
      expect(() => estimateRun(changed, 1000), throwsFormatException);
    }
  });
}
