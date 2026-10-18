import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/features/calculator/domain/power_calculator_model.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/status_banner.dart';
import 'package:flutter/material.dart';

/// Horsepower ⇄ torque calculator for user-supplied values at one RPM.
class PowerScreen extends StatefulWidget {
  /// Creates the calculator screen.
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Scaffold(
      appBar: AppBar(title: const Text('HP & torque calculator')),
      body: Form(
        key: _form,
        child: PageListView(children: [
          const StatusBanner(
              'Calculate power from known torque and RPM, or torque from known horsepower '
              'and RPM. This calculator does not measure your car or read engine performance from OBD.',
              icon: Icons.calculate_outlined),
          const SizedBox(height: AppSpacing.lg),
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
          const SizedBox(height: AppSpacing.lg),
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
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
              controller: _rpm,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Rotational speed (RPM)'),
              validator: (value) => _validate(value, positive: true),
              onChanged: (_) => setState(() => _result = null)),
          const SizedBox(height: AppSpacing.md),
          Text(
              'Use power/torque at the same RPM and measurement point '
              '(engine shaft or wheels). Peak torque and peak HP may occur at different RPM. '
              'No drivetrain-loss correction is applied.',
              style: caption),
          const SizedBox(height: AppSpacing.lg),
          PrimaryActionButton(onPressed: _calculate, label: 'Calculate result'),
          if (_error != null) StatusBanner(_error!, tone: BannerTone.error),
          if (_result != null) ...[
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calculated at ${_result!.rpm.toStringAsFixed(0)} RPM',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                        '${_result!.horsepower.toStringAsFixed(1)} hp (mechanical)',
                        style: theme.textTheme.titleMedium),
                    Text('${_result!.kilowatts.toStringAsFixed(1)} kW'),
                    Text('${_result!.torqueNm.toStringAsFixed(1)} N·m'),
                    Text(
                        '${_result!.torquePoundFeet.toStringAsFixed(1)} lb·ft'),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                        'Calculated from your inputs • not measured performance',
                        style: caption),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
              'Formula: power (W) = torque (N·m) × 2π × RPM ÷ 60. '
              'Mechanical hp = W ÷ 745.6999. This is not metric horsepower (PS).',
              style: caption),
        ]),
      ),
    );
  }
}
