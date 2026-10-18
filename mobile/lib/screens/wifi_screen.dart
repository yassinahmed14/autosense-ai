import 'dart:async';
import 'package:flutter/material.dart';
import '../models/diagnostic.dart';
import '../services/api_client.dart';
import '../services/obd_adapter.dart';
import '../services/wifi_obd_adapter.dart';
import 'dashboard_screen.dart';
import 'manual_screen.dart';

class WifiScreen extends StatefulWidget {
  const WifiScreen({super.key, required this.api, required this.onResult});
  final ApiClient api;
  final ValueChanged<DiagnosticResult> onResult;
  @override
  State<WifiScreen> createState() => _WifiScreenState();
}

class _WifiScreenState extends State<WifiScreen> {
  final _host = TextEditingController(), _port = TextEditingController();
  WifiObdAdapter? _adapter;
  bool _busy = false, _parked = false, _documented = false;
  String _status = 'Not connected';
  ObdSnapshot? _snapshot;
  Future<void> _connect({required bool dashboard}) async {
    final port = int.tryParse(_port.text.trim());
    if (_host.text.trim().isEmpty || port == null || port < 1 || port > 65535) {
      setState(() =>
          _status = 'Enter the host/IP and TCP port from your adapter manual.');
      return;
    }
    setState(() {
      _busy = true;
      _snapshot = null;
      _status = 'Connecting to Wi-Fi adapter…';
    });
    final adapter = WifiObdAdapter(host: _host.text.trim(), port: port);
    _adapter = adapter;
    try {
      await adapter.connect((await adapter.discover()).single);
      if (!mounted) return;
      if (dashboard) {
        await Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => DashboardScreen(
                adapter: adapter, simulated: false, alreadyConnected: true)));
        if (mounted) {
          setState(() => _status = 'Dashboard closed; disconnected.');
        }
      } else {
        final snapshot = await adapter.readStoredCodes();
        if (mounted) {
          setState(() {
            _snapshot = snapshot;
            _status =
                'Stored-code read complete. Connection compatibility remains unverified.';
          });
        }
      }
    } catch (error) {
      if (mounted) setState(() => _status = error.toString());
    } finally {
      await adapter.disconnect();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    unawaited(_adapter?.disconnect());
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Connect with Wi-Fi')),
      body: ListView(padding: const EdgeInsets.all(22), children: [
        const Icon(Icons.wifi, size: 54, color: Color(0xff4ce0b3)),
        const Text('ELM serial over Wi-Fi',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const Text(
            'Experimental • no physical adapter tested. Join the adapter’s Wi-Fi in phone settings first. Use the host and TCP port from its manual; AutoSense does not assume an address or port. UDP/HTTP and proprietary Wi-Fi protocols need a different driver.'),
        if (!WifiObdAdapter.supported)
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                  'This browser cannot open a raw TCP connection. Use the native Android/iPhone app, or explore the live demo.')),
        const SizedBox(height: 18),
        TextField(
            controller: _host,
            enabled: !_busy,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Adapter host / IP')),
        const SizedBox(height: 12),
        TextField(
            controller: _port,
            enabled: !_busy,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'TCP port')),
        CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _parked,
            onChanged:
                _busy ? null : (v) => setState(() => _parked = v ?? false),
            title: const Text(
                'I am parked and following the vehicle/adapter instructions.')),
        CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _documented,
            onChanged:
                _busy ? null : (v) => setState(() => _documented = v ?? false),
            title:
                const Text('My adapter documents ELM ASCII serial over TCP.')),
        Text(_status),
        if (_busy) const LinearProgressIndicator(),
        FilledButton.icon(
            icon: const Icon(Icons.speed),
            label: const Text('Connect and open dashboard'),
            onPressed:
                !_busy && _parked && _documented && WifiObdAdapter.supported
                    ? () => _connect(dashboard: true)
                    : null),
        OutlinedButton(
            onPressed:
                !_busy && _parked && _documented && WifiObdAdapter.supported
                    ? () => _connect(dashboard: false)
                    : null,
            child: const Text('Read stored codes')),
        if (_busy)
          TextButton(
              onPressed: () => _adapter?.disconnect(),
              child: const Text('Cancel connection')),
        if (_snapshot != null) ...[
          const SizedBox(height: 16),
          Text(_snapshot!.codes.isEmpty
              ? 'No stored codes reported by responding ECUs. This does not mean no fault.'
              : 'Stored codes: ${_snapshot!.codes.join(', ')}'),
          for (final e in _snapshot!.codesByEcu.entries)
            Text('ECU ${e.key}: ${e.value.join(', ')}'),
          OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => ManualScreen(
                          api: widget.api,
                          onResult: widget.onResult,
                          initialCodes: _snapshot!.codes,
                          source: 'wifi_obd'))),
              child: const Text('Review codes and symptoms')),
        ],
        const SizedBox(height: 16),
        const Text(
            'Stored engine/emissions codes and selected live PIDs over CAN only. Real clearing and automatic vehicle identification remain unavailable. A Wi-Fi network without internet may also prevent access to your diagnostic API; readings stay local.'),
      ]));
}
