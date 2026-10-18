import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/diagnostic.dart';
import '../services/api_client.dart';
import '../services/obd_adapter.dart';
import 'connected_scanner_screen.dart';

class BleScanScreen extends StatefulWidget {
  const BleScanScreen(
      {super.key, required this.api, required this.onResult, this.adapter});
  final ApiClient api;
  final ValueChanged<DiagnosticResult> onResult;
  final BleObdAdapter? adapter;
  @override
  State<BleScanScreen> createState() => _BleScanScreenState();
}

class _BleScanScreenState extends State<BleScanScreen>
    with WidgetsBindingObserver {
  late final BleObdAdapter _adapter = widget.adapter ?? BleObdAdapter();
  bool _busy = false, _parked = false, _transferred = false;
  String _status = 'Choose your OBD adapter to connect automatically.';
  List<ObdDevice> _devices = [];
  bool get _supported => widget.adapter != null || BleObdAdapter.supported;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_adapter.disconnect());
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      await _adapter.disconnect();
      if (mounted) setState(() => _status = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _discover() => _run(() async {
        setState(() {
          _devices = [];
          _status = 'Searching for nearby adapters…';
        });
        final devices = await _adapter.discover();
        if (mounted) {
          setState(() {
            _devices = devices;
            _status = devices.isEmpty
                ? 'No devices found. Check Bluetooth and adapter power.'
                : 'Tap your OBD adapter. AutoSense will set up the connection.';
          });
        }
      });

  Future<void> _connect(ObdDevice device) => _run(() async {
        setState(() => _status =
            'Connecting to ${device.name} and verifying the scanner…');
        await _adapter.connect(device);
        if (!mounted) {
          await _adapter.disconnect();
          return;
        }
        if (!_adapter.ready) {
          throw StateError('The scanner connection could not be verified.');
        }
        _transferred = true;
        unawaited(Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
            builder: (_) => ConnectedScannerScreen(
                adapter: _adapter,
                device: device,
                api: widget.api,
                onResult: widget.onResult))));
      });

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!_transferred) unawaited(_adapter.disconnect());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Connect your OBD adapter')),
        body: ListView(padding: const EdgeInsets.all(22), children: [
          const Icon(Icons.bluetooth_searching,
              size: 60, color: Color(0xff4ce0b3)),
          const SizedBox(height: 16),
          Text('Select. Connect. Explore.',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          const Text(
              'Select your scanner and AutoSense will identify its supported Bluetooth serial profile automatically.'),
          const SizedBox(height: 12),
          const Text('Experimental • compatibility unverified'),
          if (!_supported)
            const Text(
                'Real BLE requires the native Android or iPhone app. This browser preview supports the demo only.'),
          CheckboxListTile(
              value: _parked,
              contentPadding: EdgeInsets.zero,
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _parked = value ?? false),
              title: const Text(
                  'The vehicle is parked and I can safely use the app.')),
          FilledButton.icon(
              onPressed: _supported && _parked && !_busy ? _discover : null,
              icon: const Icon(Icons.search),
              label: const Text('Discover devices')),
          const SizedBox(height: 16),
          if (_busy) const LinearProgressIndicator(),
          const SizedBox(height: 12),
          Text(_status),
          for (final device in _devices)
            Card(
                child: ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(device.name),
                    subtitle: const Text('Tap to connect'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: !_busy && _parked ? () => _connect(device) : null)),
          const SizedBox(height: 16),
          ExpansionTile(title: const Text('Troubleshooting'), children: [
            const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                    'Keep the adapter powered and close other scanner apps. Only recognized BLE UART profiles are tried. '
                    'A successful adapter handshake does not confirm vehicle ECU access. '
                    'If automatic setup fails, copy the report so the correct profile can be added.')),
            if (_adapter.connectionReport.isNotEmpty) ...[
              SelectableText(_adapter.connectionReport),
              TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(
                        text: '$_status\n${_adapter.connectionReport}'));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Connection report copied.')));
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy connection report')),
            ],
          ]),
        ]),
      );
}
