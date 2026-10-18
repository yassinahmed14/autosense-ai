import 'package:flutter/material.dart';
import '../models/diagnostic.dart';
import '../services/api_client.dart';
import '../services/obd_adapter.dart';
import '../widgets/safety_notice.dart';
import 'manual_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen(
      {super.key,
      required this.adapter,
      required this.api,
      required this.onResult});
  final ObdAdapter adapter;
  final ApiClient api;
  final ValueChanged<DiagnosticResult> onResult;
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _busy = false;
  String _status = 'Disconnected';
  List<ObdDevice> _devices = [];
  Future<void> _discover() async {
    setState(() {
      _busy = true;
      _status = 'Discovering simulated devices…';
    });
    try {
      final devices = await widget.adapter.discover();
      if (mounted) {
        setState(() {
          _devices = devices;
          _status = 'Select a demo device';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _status = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _scan(ObdDevice device) async {
    setState(() {
      _busy = true;
      _status = 'Connecting to mock adapter…';
    });
    try {
      await widget.adapter.disconnect();
      await widget.adapter.connect(device);
      if (mounted) setState(() => _status = 'Reading simulated codes…');
      final snapshot = await widget.adapter.readStoredCodes();
      if (!snapshot.simulated || snapshot.vehicle?.simulated == false) {
        throw StateError('This screen supports mock scans only.');
      }
      if (!mounted) return;
      setState(() =>
          _status = 'Simulated scan complete (${snapshot.codes.length} codes)');
      await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ManualScreen(
              api: widget.api,
              onResult: widget.onResult,
              initialCodes: snapshot.codes,
              initialVehicle: snapshot.vehicle,
              source: 'mock_obd')));
    } catch (error) {
      if (mounted) setState(() => _status = error.toString());
    } finally {
      await widget.adapter.disconnect();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    widget.adapter.disconnect();
    super.dispose();
  }

  Future<void> _clear(ObdDevice device) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Clear demo codes?'),
              content: const Text(
                  'This clears only the simulated adapter’s stored codes. '
                  'It does not repair a fault or change your real check-engine light. '
                  'Real code clearing can erase freeze-frame evidence and reset emissions '
                  'readiness monitors. Save diagnostic information before clearing.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Clear demo codes')),
              ],
            ));
    if (confirmed != true || !mounted) return;
    if (!device.simulated) {
      setState(() => _status = 'Physical code clearing is not implemented.');
      return;
    }
    setState(() {
      _busy = true;
      _status = 'Clearing simulated codes…';
    });
    try {
      await widget.adapter.disconnect();
      await widget.adapter.connect(device);
      await widget.adapter.clearStoredCodes();
      if (mounted) {
        setState(() => _status = 'Demo codes cleared. No vehicle was changed.');
      }
    } catch (error) {
      if (mounted) setState(() => _status = error.toString());
    } finally {
      await widget.adapter.disconnect();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('OBD adapter demo')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const SafetyNotice(),
          const Text('MOCK MODE',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text(
              'This demo does not use Bluetooth or connect to a vehicle. Experimental '
              'BLE and Wi-Fi connections are available separately, with no validated adapter compatibility.'),
          const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                  'Auto-detect car demo: selecting the adapter fills in a simulated '
                  '2020 Toyota Corolla and reads demo codes. Real car identification is not connected yet.')),
          const SizedBox(height: 20),
          Text(_status),
          if (_busy) const LinearProgressIndicator(),
          FilledButton(
              onPressed: _busy ? null : _discover,
              child: const Text('Discover mock adapter')),
          for (final device in _devices)
            Card(
                child: Column(children: [
              ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(device.name),
                  subtitle: const Text(
                      'Simulated • Tap to detect demo car and read codes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _busy ? null : () => _scan(device)),
              TextButton.icon(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Clear codes (demo)'),
                  onPressed: _busy ? null : () => _clear(device)),
            ])),
        ]),
      );
}
