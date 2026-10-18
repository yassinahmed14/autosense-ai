import 'dart:math' as math;

import 'package:autosense_ai/core/utils/unit_conversions.dart';

export 'package:autosense_ai/core/utils/unit_conversions.dart';

/// Power/torque at a single RPM, derived from user inputs (never measured).
class PowerCalculation {
  const PowerCalculation._(this.rpm, this.torqueNm, this.watts);
  final double rpm, torqueNm, watts;
  double get horsepower => watts / wattsPerHorsepower;
  double get kilowatts => watts / 1000;
  double get torquePoundFeet => torqueNm / newtonMetresPerPoundFoot;

  static void _validate(double value, double rpm) {
    if (!value.isFinite || value < 0 || !rpm.isFinite || rpm <= 0) {
      throw const FormatException(
          'Enter a finite value of zero or more and an RPM above zero.');
    }
  }

  factory PowerCalculation.fromTorque(
      {required double torqueNm, required double rpm}) {
    _validate(torqueNm, rpm);
    final watts = torqueNm * (2 * math.pi * rpm / 60);
    if (!watts.isFinite) {
      throw const FormatException('Values are too large to calculate.');
    }
    return PowerCalculation._(rpm, torqueNm, watts);
  }

  factory PowerCalculation.fromHorsepower(
      {required double horsepower, required double rpm}) {
    _validate(horsepower, rpm);
    final watts = horsepower * wattsPerHorsepower;
    final torque = watts / (2 * math.pi * rpm / 60);
    if (!watts.isFinite || !torque.isFinite) {
      throw const FormatException('Values are too large to calculate.');
    }
    return PowerCalculation._(rpm, torque, watts);
  }
}
