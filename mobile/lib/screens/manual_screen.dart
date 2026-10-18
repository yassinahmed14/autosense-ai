import 'package:flutter/material.dart';
import '../models/diagnostic.dart';
import '../models/vehicle_options.dart';
import '../services/api_client.dart';
import '../services/obd_adapter.dart';
import '../widgets/safety_notice.dart';
import 'result_screen.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen(
      {super.key,
      required this.api,
      required this.onResult,
      this.initialCodes = const [],
      this.initialVehicle,
      this.onDetectCar,
      this.source = 'manual'});
  final ApiClient api;
  final ValueChanged<DiagnosticResult> onResult;
  final List<String> initialCodes;
  final String source;
  final VehicleIdentity? initialVehicle;
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
      await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ResultScreen(result: result)));
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(widget.source == 'mock_obd'
                ? 'Review simulated scan'
                : (widget.source == 'ble_obd' || widget.source == 'wifi_obd')
                    ? 'Review adapter scan'
                    : 'Manual input')),
        body: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              const SafetyNotice(),
              if (widget.source == 'mock_obd')
                const Text(
                    'SIMULATED codes only. Your real vehicle has not been scanned.'),
              if (widget.source == 'ble_obd')
                const Text(
                    'Codes imported from an experimental BLE read. Review them; adapter compatibility and diagnoses remain unverified. Only stored engine/emissions codes were requested.'),
                if (widget.source != 'manual')
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SelectableText(widget.initialCodes.isEmpty
                        ? 'No stored codes reported by responding ECUs. This is not a complete vehicle health check.'
                          : 'Scanner codes: ${widget.initialCodes.join(', ')}')),
              if (widget.source == 'wifi_obd')
                const Text(
                    'Codes imported from an experimental Wi-Fi read. Compatibility remains unverified. Only stored engine/emissions codes were requested.'),
              Text('Vehicle (optional)',
                  style: Theme.of(context).textTheme.titleLarge),
              if (widget.onDetectCar != null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Auto-detect car (demo)'),
                  onPressed: _busy ? null : widget.onDetectCar,
                ),
              if (widget.initialVehicle != null)
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                            'Simulated car: ${widget.initialVehicle!.year} '
                            '${widget.initialVehicle!.make} ${widget.initialVehicle!.model}. '
                            'Review or change the selection. This is not your vehicle’s identity.'))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const ValueKey('vehicle-make'),
                initialValue: _make,
                isExpanded: true,
                menuMaxHeight: 320,
                decoration: const InputDecoration(labelText: 'Make'),
                hint: const Text('Select make'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Not specified')),
                  for (final make in [
                    ...vehicleModels.keys,
                    otherVehicleOption
                  ])
                    DropdownMenuItem(value: make, child: Text(make)),
                ],
                onChanged: (value) => setState(() {
                  _make = value;
                  _model = null;
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey('vehicle-model-$_make'),
                initialValue: _model,
                isExpanded: true,
                menuMaxHeight: 320,
                decoration: const InputDecoration(labelText: 'Model'),
                hint: Text(
                    _make == null ? 'Select a make first' : 'Select model'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Not specified')),
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
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: const ValueKey('vehicle-year'),
                initialValue: _year,
                isExpanded: true,
                menuMaxHeight: 320,
                decoration: const InputDecoration(labelText: 'Year'),
                hint: const Text('Select year'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Not specified')),
                  for (var year = DateTime.now().year + 1; year >= 1900; year--)
                    DropdownMenuItem(value: year, child: Text('$year')),
                ],
                onChanged: (value) => setState(() => _year = value),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                    'Model lists include common examples. Choose “Other / not listed” if yours is missing.'),
              ),
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
              Text('Symptoms', style: Theme.of(context).textTheme.titleLarge),
              Wrap(spacing: 8, children: [
                for (final item in symptoms.entries)
                  FilterChip(
                    label: Text(item.value),
                    selected: _symptoms.contains(item.key),
                    onSelected: (value) => setState(() {
                      value
                          ? _symptoms.add(item.key)
                          : _symptoms.remove(item.key);
                    }),
                  )
              ]),
              TextFormField(
                  controller: _notes,
                  maxLength: 2000,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Additional notes',
                      helperText:
                          'Sent with your guidance request. Avoid personal details; free text requires human review.')),
              Text('Safety checklist',
                  style: Theme.of(context).textTheme.titleLarge),
              const Text(
                  'Select any current concerns. Any selected concern takes priority.'),
              for (final item in flags.entries)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.value),
                  value: _flags.contains(item.key),
                  onChanged: (value) => setState(() {
                    value == true
                        ? _flags.add(item.key)
                        : _flags.remove(item.key);
                    _checked = false;
                  }),
                ),
              CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I reviewed every safety concern above'),
                  value: _checked,
                  onChanged: (value) =>
                      setState(() => _checked = value ?? false)),
              if (_flags.isNotEmpty)
                const Text(
                    'Reach a safe stopping place and seek assistance. Do not wait for this app’s result.',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const Text(
                  'Requesting guidance sends the selected vehicle, codes, symptoms, '
                  'safety selections and notes to the configured diagnostic service. '
                  'Do not include personal information in notes.'),
              const SizedBox(height: 8),
              FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(_busy
                      ? 'Preparing guidance…'
                      : 'Get preliminary guidance')),
              const SizedBox(height: 24),
            ])),
      );
}
