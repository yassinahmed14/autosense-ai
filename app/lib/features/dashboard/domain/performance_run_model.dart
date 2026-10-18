import 'dart:math' as math;

import 'package:autosense_ai/core/utils/unit_conversions.dart';
import 'package:autosense_ai/features/dashboard/domain/telemetry_model.dart';

class RunEstimate {
  const RunEstimate(
      {required this.averageHp,
      required this.peakWindowHp,
      required this.equivalentTorqueNm,
      required this.samples,
      required this.simulated});
  final double averageHp, peakWindowHp, equivalentTorqueNm;
  final int samples;
  final bool simulated;
}

/// Net translational kinetic-energy rate, not engine or total wheel output.
/// No guessed drivetrain efficiency, aerodynamic drag or rolling resistance.
RunEstimate estimateRun(List<TelemetrySample> samples, double massKg) {
  if (!massKg.isFinite || massKg < 300 || massKg > 6000) {
    throw const FormatException(
        'Enter total vehicle + occupant mass (300–6000 kg).');
  }
  if (samples.length < 20) {
    throw const FormatException(
        'Insufficient sample rate: at least 20 valid readings are required.');
  }
  final simulated = samples.first.simulated;
  for (var i = 0; i < samples.length; i++) {
    final s = samples[i];
    if (s.simulated != simulated ||
        !s.speedKph.isFinite ||
        !s.rpm.isFinite ||
        s.speedKph < 0 ||
        s.speedKph > 255 ||
        s.rpm <= 0 ||
        s.rpm > 16383.75 ||
        s.rpmAt.difference(s.speedAt).inMilliseconds.abs() > 750) {
      throw const FormatException(
          'Invalid, mixed-source or poorly synchronized readings.');
    }
    if (i > 0) {
      final dt =
          s.speedAt.difference(samples[i - 1].speedAt).inMicroseconds / 1e6;
      if (dt <= 0 || dt > 1.0) {
        throw const FormatException(
            'Data has gaps or invalid timestamps. Repeat with a faster connection.');
      }
      final dv = (s.speedKph - samples[i - 1].speedKph) / 3.6;
      if (dv < -1.5 || dv / dt > 12) {
        throw const FormatException(
            'Braking, a speed discontinuity or wheel slip invalidated this run.');
      }
    }
  }
  final duration =
      samples.last.speedAt.difference(samples.first.speedAt).inMicroseconds /
          1e6;
  if (duration < 8 ||
      duration > 12 ||
      samples.last.speedKph - samples.first.speedKph < 10) {
    throw const FormatException(
        'Need 8–12 seconds of data with at least 10 km/h net speed gain.');
  }
  double energy(double kph) => 0.5 * massKg * math.pow(kph / 3.6, 2);
  final averageWatts =
      (energy(samples.last.speedKph) - energy(samples.first.speedKph)) /
          duration;
  double peakWatts = 0, equivalentTorque = 0;
  // Use >=1 s windows to reduce the effect of 1 km/h OBD speed quantization.
  for (var i = 0; i < samples.length; i++) {
    for (var j = i + 1; j < samples.length; j++) {
      final dt =
          samples[j].speedAt.difference(samples[i].speedAt).inMicroseconds /
              1e6;
      if (dt < 1) continue;
      final watts =
          (energy(samples[j].speedKph) - energy(samples[i].speedKph)) / dt;
      if (watts > peakWatts) {
        peakWatts = watts;
        final rpm = (samples[i].rpm + samples[j].rpm) / 2;
        equivalentTorque = watts / (rpm * 2 * math.pi / 60);
      }
      break;
    }
  }
  if (!peakWatts.isFinite || !equivalentTorque.isFinite) {
    throw const FormatException('Invalid estimate.');
  }
  return RunEstimate(
      averageHp: averageWatts / wattsPerHorsepower,
      peakWindowHp: peakWatts / wattsPerHorsepower,
      equivalentTorqueNm: equivalentTorque,
      samples: samples.length,
      simulated: simulated);
}
