import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/diagnostic.dart';
import '../services/api_client.dart';
import '../services/obd_adapter.dart';
import 'dashboard_screen.dart';
import 'manual_screen.dart';

class ConnectedScannerScreen extends StatefulWidget {
  const ConnectedScannerScreen(
      {super.key,
      required this.adapter,
      required this.device,
      required this.api,
      required this.onResult});
  final BleObdAdapter adapter;
  final ObdDevice device;
  final ApiClient api;
  final ValueChanged<DiagnosticResult> onResult;
  @override
  State<ConnectedScannerScreen> createState() => _ConnectedScannerScreenState();
}

class _ConnectedScannerScreenState extends State<ConnectedScannerScreen>
    with WidgetsBindingObserver {
  bool _busy = false;
  String? _error;
  String _report = '';
  Timer? _stateTimer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _stateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(widget.adapter.disconnect());
    }
  }

  Future<void> _use(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.adapter.waitForReading();
      if (!mounted) return;
      if (!widget.adapter.ready) await widget.adapter.connect(widget.device);
      if (!mounted) {
        await widget.adapter.disconnect();
        return;
      }
      await action();
    } catch (error) {
      _report = widget.adapter.diagnosticReport;
      if (mounted) {
        setState(() => _error =
            'ECU read failed: $error\nKeep the ignition on and other scanner apps closed. '
                'Bluetooth is kept connected when possible. Tap Diagnose to retry, '
                'or open Live dashboard again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _dashboard() => _use(() async {
        await Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => DashboardScreen(
                adapter: widget.adapter,
                simulated: false,
                alreadyConnected: true,
                disconnectOnDispose: false)));
        await widget.adapter.waitForReading();
      });
  Future<void> _diagnose() => _use(() async {
        final snapshot = await widget.adapter.readStoredCodes();
        if (!mounted) return;
        await Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => ManualScreen(
                api: widget.api,
                onResult: widget.onResult,
                initialCodes: snapshot.codes,
                source: 'ble_obd')));
      });
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateTimer?.cancel();
    unawaited(widget.adapter.disconnect());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Your connected scanner')),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Icon(
              widget.adapter.state == AdapterState.connected
                  ? Icons.check_circle
                  : Icons.bluetooth_disabled,
              size: 64,
              color: widget.adapter.state == AdapterState.connected
                  ? const Color(0xff4ce0b3)
                  : Colors.orange),
          const SizedBox(height: 16),
          Text(
              widget.adapter.state == AdapterState.connected
                  ? 'Adapter connected'
                  : 'Adapter disconnected',
              style: Theme.of(context).textTheme.headlineMedium),
          Text(widget.device.name),
          Text(widget.adapter.ecuReady
              ? 'ECU communication verified'
              : 'ECU communication not yet verified'),
          const SizedBox(height: 12),
          const Text(
              'Choose what you want to do. Vehicle ECU access is checked when you read live data or stored codes.'),
          const SizedBox(height: 24),
          FilledButton.icon(
              onPressed: _busy ? null : _dashboard,
              icon: const Icon(Icons.speed),
              label: const Text('Live dashboard')),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: _busy ? null : _diagnose,
              icon: const Icon(Icons.car_repair),
              label: const Text('Diagnose')),
          const SizedBox(height: 12),
          OutlinedButton(
              onPressed: _busy
                  ? null
                  : () async {
                      await widget.adapter.disconnect();
                      if (context.mounted) Navigator.of(context).pop();
                    },
              child: const Text('Disconnect')),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
                padding: const EdgeInsets.only(top: 16), child: Text(_error!)),
          TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(
                    text:
                        '${_error ?? ''}\n${_report.isEmpty ? widget.adapter.diagnosticReport : _report}'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Connection report copied')));
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy connection report')),
          const SizedBox(height: 20),
          const Text(
              'Experimental connection. Stored engine/emissions codes only. '
              'Possible causes need confirmation. Real code clearing is disabled.'),
        ]),
      );
}
