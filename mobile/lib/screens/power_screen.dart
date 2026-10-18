import 'package:flutter/material.dart';
import '../models/power_calculator.dart';

class PowerScreen extends StatefulWidget {
  const PowerScreen({super.key});
  @override
  State<PowerScreen> createState() => _PowerScreenState();
}

class _PowerScreenState extends State<PowerScreen> {
  final _form = GlobalKey<FormState>();
  final _value = TextEditingController();
  final _rpm = TextEditingController();
  bool _fromTorque = true;
  PowerCalculation? _result;
  String? _error;
  @override
  void dispose() {
    _value.dispose();
    _rpm.dispose();
    super.dispose();
  }

  String? _validate(String? text, {bool positive = false}) {
    final value = double.tryParse((text ?? '').trim());
    if (value == null ||
        !value.isFinite ||
        (positive ? value <= 0 : value < 0)) {
      return positive
          ? 'Enter RPM above zero'
          : 'Enter a value of zero or more';
    }
    return null;
  }

  void _calculate() {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      try {
        final value = double.parse(_value.text.trim());
        final rpm = double.parse(_rpm.text.trim());
        _result = _fromTorque
            ? PowerCalculation.fromTorque(torqueNm: value, rpm: rpm)
            : PowerCalculation.fromHorsepower(horsepower: value, rpm: rpm);
      } on FormatException catch (error) {
        _result = null;
        _error = error.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('HP & torque calculator')),
        body: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              const Card(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                          'Calculate power from known torque and RPM, or torque from known horsepower '
                          'and RPM. This calculator does not measure your car or read engine performance from OBD.'))),
              DropdownButtonFormField<bool>(
                initialValue: _fromTorque,
                decoration: const InputDecoration(labelText: 'Calculate'),
                items: const [
                  DropdownMenuItem(
                      value: true, child: Text('Horsepower from torque')),
                  DropdownMenuItem(
                      value: false, child: Text('Torque from horsepower')),
                ],
                onChanged: (value) => setState(() {
                  _fromTorque = value ?? true;
                  _result = null;
                  _error = null;
                  _value.clear();
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _value,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: _fromTorque
                          ? 'Torque (N·m)'
                          : 'Mechanical horsepower (hp)'),
                  validator: _validate,
                  onChanged: (_) => setState(() => _result = null)),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _rpm,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Rotational speed (RPM)'),
                  validator: (value) => _validate(value, positive: true),
                  onChanged: (_) => setState(() => _result = null)),
              const SizedBox(height: 16),
              const Text(
                  'Use power/torque at the same RPM and measurement point '
                  '(engine shaft or wheels). Peak torque and peak HP may occur at different RPM. '
                  'No drivetrain-loss correction is applied.'),
              FilledButton(
                  onPressed: _calculate, child: const Text('Calculate result')),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_result != null)
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Calculated at ${_result!.rpm.toStringAsFixed(0)} RPM',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              Text(
                                  '${_result!.horsepower.toStringAsFixed(1)} hp (mechanical)'),
                              Text(
                                  '${_result!.kilowatts.toStringAsFixed(1)} kW'),
                              Text(
                                  '${_result!.torqueNm.toStringAsFixed(1)} N·m'),
                              Text(
                                  '${_result!.torquePoundFeet.toStringAsFixed(1)} lb·ft'),
                              const Text(
                                  'Calculated from your inputs • not measured performance'),
                            ]))),
              const SizedBox(height: 16),
              const Text('Formula: power (W) = torque (N·m) × 2π × RPM ÷ 60. '
                  'Mechanical hp = W ÷ 745.6999. This is not metric horsepower (PS).'),
            ])),
      );
}
