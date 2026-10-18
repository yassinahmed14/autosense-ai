import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/core/routing/app_router.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:autosense_ai/features/diagnostics/domain/vehicle_options_model.dart';
import 'package:autosense_ai/features/diagnostics/presentation/result_screen.dart';
import 'package:autosense_ai/features/scanner/domain/obd_adapter.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/safety_notice.dart';
import 'package:autosense_ai/shared/widgets/section_header.dart';
import 'package:autosense_ai/shared/widgets/status_banner.dart';
import 'package:flutter/material.dart';

/// Manual entry of vehicle, DTCs, symptoms and safety concerns; also reviews
/// codes imported from mock, BLE or Wi-Fi scans before requesting guidance.
class ManualScreen extends StatefulWidget {
  /// Creates the manual/review screen.
  const ManualScreen(
      {super.key,
      required this.api,
      required this.onResult,
      this.initialCodes = const [],
      this.initialVehicle,
      this.onDetectCar,
      this.source = 'manual'});

  /// Diagnostic API client.
  final ApiClient api;

  /// Called with each successful result (records session history).
  final ValueChanged<DiagnosticResult> onResult;

  /// Codes pre-filled from a scan.
  final List<String> initialCodes;

  /// Input source: `manual`, `mock_obd`, `ble_obd` or `wifi_obd`.
  final String source;

  /// Simulated vehicle identity from the mock adapter, if any.
  final VehicleIdentity? initialVehicle;

  /// Opens the demo auto-detect flow; hidden when null.
  final VoidCallback? onDetectCar;

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  final _form = GlobalKey<FormState>();
  final _codes = TextEditingController();
  final _notes = TextEditingController();
  String? _make, _model;
  int? _year;
  final _symptoms = <String>{};
  final _flags = <String>{};
  bool _checked = false, _busy = false;
  String? _error;
  static const symptoms = {
    'rough_idle': 'Rough idle',
    'hard_start': 'Hard starting',
    'reduced_power': 'Reduced power',
    'poor_fuel_economy': 'Poor fuel economy',
    'unusual_noise': 'Unusual noise',
  };
  static const flags = {
    'flashing_mil': 'Flashing check-engine light',
    'overheating': 'Overheating',
    'oil_pressure_warning': 'Oil-pressure warning',
    'brake_or_steering_issue': 'Braking or steering trouble',
    'smoke_or_fuel_smell': 'Smoke or strong fuel smell',
  };

  @override
  void initState() {
    super.initState();
    _codes.text = widget.initialCodes.join(', ');
    final vehicle = widget.initialVehicle;
    if (vehicle != null) {
      _make = vehicleModels.containsKey(vehicle.make)
          ? vehicle.make
          : otherVehicleOption;
      _model = vehicleModels[_make]?.contains(vehicle.model) == true
          ? vehicle.model
          : otherVehicleOption;
      final latestYear = DateTime.now().year + 1;
      _year = vehicle.year >= 1900 && vehicle.year <= latestYear
          ? vehicle.year
          : null;
    }
  }

  @override
  void dispose() {
    for (final controller in [_codes, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final codes = parseCodes(_codes.text);
    if (codes.isEmpty &&
        _symptoms.isEmpty &&
        _notes.text.trim().isEmpty &&
        _flags.isEmpty) {
      setState(
          () => _error = 'Enter a code, symptom, note, or safety concern.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.api.diagnose(DiagnosticInput(
        codes: codes,
        symptoms: _symptoms.toList(),
        notes: _notes.text.trim(),
        safetyFlags: _flags.toList(),
        safetyCheckCompleted: _checked,
        source: widget.source,
        make: _make == otherVehicleOption ? '' : (_make ?? ''),
        model: _model == otherVehicleOption ? '' : (_model ?? ''),
        year: _year,
      ));
      if (!mounted) return;
      widget.onResult(result);
      await AppRouter.push<void>(
          context, AppRoutes.result, ResultScreen(result: result));
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _title => widget.source == 'mock_obd'
      ? 'Review simulated scan'
      : (widget.source == 'ble_obd' || widget.source == 'wifi_obd')
          ? 'Review adapter scan'
          : 'Manual input';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Form(
        key: _form,
        child: PageListView(children: [
          const SafetyNotice(),
          if (widget.source == 'mock_obd')
            const StatusBanner(
                'SIMULATED codes only. Your real vehicle has not been scanned.',
                tone: BannerTone.simulated),
          if (widget.source == 'ble_obd')
            const StatusBanner(
                'Codes imported from an experimental BLE read. Review them; adapter compatibility and diagnoses remain unverified. Only stored engine/emissions codes were requested.',
                tone: BannerTone.warning),
          if (widget.source != 'manual')
            Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: SelectableText(widget.initialCodes.isEmpty
                    ? 'No stored codes reported by responding ECUs. This is not a complete vehicle health check.'
                    : 'Scanner codes: ${widget.initialCodes.join(', ')}')),
          if (widget.source == 'wifi_obd')
            const StatusBanner(
                'Codes imported from an experimental Wi-Fi read. Compatibility remains unverified. Only stored engine/emissions codes were requested.',
                tone: BannerTone.warning),
          const SizedBox(height: AppSpacing.sm),
          const SectionHeader('Vehicle (optional)'),
          if (widget.onDetectCar != null)
            SecondaryActionButton(
              icon: Icons.auto_awesome,
              label: 'Auto-detect car (demo)',
              onPressed: _busy ? null : widget.onDetectCar,
            ),
          if (widget.initialVehicle != null)
            StatusBanner(
                'Simulated car: ${widget.initialVehicle!.year} '
                '${widget.initialVehicle!.make} ${widget.initialVehicle!.model}. '
                'Review or change the selection. This is not your vehicle’s identity.',
                tone: BannerTone.simulated),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            key: const ValueKey('vehicle-make'),
            initialValue: _make,
            isExpanded: true,
            menuMaxHeight: 320,
            decoration: const InputDecoration(labelText: 'Make'),
            hint: const Text('Select make'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Not specified')),
              for (final make in [...vehicleModels.keys, otherVehicleOption])
                DropdownMenuItem(value: make, child: Text(make)),
            ],
            onChanged: (value) => setState(() {
              _make = value;
              _model = null;
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            key: ValueKey('vehicle-model-$_make'),
            initialValue: _model,
            isExpanded: true,
            menuMaxHeight: 320,
            decoration: const InputDecoration(labelText: 'Model'),
            hint: Text(_make == null ? 'Select a make first' : 'Select model'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Not specified')),
              for (final model in [
                ...?vehicleModels[_make],
                otherVehicleOption
              ])
                DropdownMenuItem(value: model, child: Text(model)),
            ],
            onChanged: _make == null
                ? null
                : (value) => setState(() => _model = value),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<int>(
            key: const ValueKey('vehicle-year'),
            initialValue: _year,
            isExpanded: true,
            menuMaxHeight: 320,
            decoration: const InputDecoration(labelText: 'Year'),
            hint: const Text('Select year'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Not specified')),
              for (var year = DateTime.now().year + 1; year >= 1900; year--)
                DropdownMenuItem(value: year, child: Text('$year')),
            ],
            onChanged: (value) => setState(() => _year = value),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
                'Model lists include common examples. Choose “Other / not listed” if yours is missing.',
                style: caption),
          ),
          const SectionHeader('Codes'),
          TextFormField(
              controller: _codes,
              maxLength: 120,
              decoration: const InputDecoration(
                  labelText: 'DTC codes', hintText: 'P0300, P0171'),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                try {
                  parseCodes(value ?? '');
                  return null;
                } on FormatException catch (error) {
                  return error.message;
                }
              }),
          const SectionHeader('Symptoms'),
          Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
            for (final item in symptoms.entries)
              FilterChip(
                label: Text(item.value),
                selected: _symptoms.contains(item.key),
                onSelected: (value) => setState(() {
                  value ? _symptoms.add(item.key) : _symptoms.remove(item.key);
                }),
              )
          ]),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
              controller: _notes,
              maxLength: 2000,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Additional notes',
                  helperText:
                      'Sent with your guidance request. Avoid personal details; free text requires human review.')),
          const SectionHeader('Safety checklist',
              subtitle:
                  'Select any current concerns. Any selected concern takes priority.'),
          for (final item in flags.entries)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.value),
              value: _flags.contains(item.key),
              onChanged: (value) => setState(() {
                value == true ? _flags.add(item.key) : _flags.remove(item.key);
                _checked = false;
              }),
            ),
          CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('I reviewed every safety concern above'),
              value: _checked,
              onChanged: (value) => setState(() => _checked = value ?? false)),
          if (_flags.isNotEmpty)
            const StatusBanner(
                'Reach a safe stopping place and seek assistance. Do not wait for this app’s result.',
                tone: BannerTone.error,
                emphasize: true),
          if (_error != null) StatusBanner(_error!, tone: BannerTone.error),
          const SizedBox(height: AppSpacing.sm),
          Text(
              'Requesting guidance sends the selected vehicle, codes, symptoms, '
              'safety selections and notes to the configured diagnostic service. '
              'Do not include personal information in notes.',
              style: caption),
          const SizedBox(height: AppSpacing.md),
          PrimaryActionButton(
              onPressed: _busy ? null : _submit,
              label:
                  _busy ? 'Preparing guidance…' : 'Get preliminary guidance'),
          const SizedBox(height: AppSpacing.xxl),
        ]),
      ),
    );
  }
}
