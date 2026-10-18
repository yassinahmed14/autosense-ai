import 'package:flutter_test/flutter_test.dart';
import 'package:autosense_ai/models/power_calculator.dart';

void main() {
  test('known torque yields shaft power and round trips at the same RPM', () {
    final power = PowerCalculation.fromTorque(torqueNm: 200, rpm: 3000);
    expect(power.kilowatts, closeTo(62.831853, 0.00001));
    expect(power.horsepower, closeTo(84.2588, 0.001));
    final reverse = PowerCalculation.fromHorsepower(
        horsepower: power.horsepower, rpm: 3000);
    expect(reverse.torqueNm, closeTo(200, 0.000001));
    expect(power.torquePoundFeet, closeTo(147.5124, 0.001));
  });
  test('zero torque is valid; zero RPM and nonfinite values are rejected', () {
    expect(PowerCalculation.fromTorque(torqueNm: 0, rpm: 1000).horsepower, 0);
    expect(() => PowerCalculation.fromTorque(torqueNm: 10, rpm: 0),
        throwsFormatException);
    expect(() => PowerCalculation.fromTorque(torqueNm: -10, rpm: 1000),
        throwsFormatException);
    expect(
        () =>
            PowerCalculation.fromHorsepower(horsepower: double.nan, rpm: 1000),
        throwsFormatException);
  });
}
