import 'dart:async';

import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/core/routing/app_router.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:autosense_ai/features/scanner/data/ble_obd_adapter.dart';
import 'package:autosense_ai/features/scanner/domain/obd_adapter.dart';
import 'package:autosense_ai/features/scanner/presentation/connected_scanner_screen.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Discovers nearby BLE devices and hands a verified adapter to
/// [ConnectedScannerScreen].
class BleScanScreen extends StatefulWidget {
  /// Creates the BLE discovery screen. Inject [adapter] in tests.
  const BleScanScreen(
      {super.key, required this.api, required this.onResult, this.adapter});

  /// Diagnostic API client.
  final ApiClient api;

  /// Records results in the session history.
  final ValueChanged<DiagnosticResult> onResult;

  /// Optional adapter override (tests / fakes).
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
        unawaited(AppRouter.replace<void>(
            context,
            AppRoutes.connectedScanner,
            ConnectedScannerScreen(
                adapter: _adapter,
                device: device,
                api: widget.api,
                onResult: widget.onResult)));
      });

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!_transferred) unawaited(_adapter.disconnect());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Connect your OBD adapter')),
      body: PageListView(children: [
        Row(children: [
          const HeaderIcon(Icons.bluetooth_searching),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
              child: Text('Select. Connect. Explore.',
                  style: theme.textTheme.headlineSmall)),
        ]),
        const SizedBox(height: AppSpacing.md),
        const Text(
            'Select your scanner and AutoSense will identify its supported Bluetooth serial profile automatically.'),
        const SizedBox(height: AppSpacing.sm),
        const StatusBanner('Experimental • compatibility unverified',
            tone: BannerTone.warning),
        if (!_supported)
          const StatusBanner(
              'Real BLE requires the native Android or iPhone app. This browser preview supports the demo only.',
              tone: BannerTone.error),
        CheckboxListTile(
            value: _parked,
            contentPadding: EdgeInsets.zero,
            onChanged: _busy
                ? null
                : (value) => setState(() => _parked = value ?? false),
            title: const Text(
                'The vehicle is parked and I can safely use the app.')),
        PrimaryActionButton(
            onPressed: _supported && _parked && !_busy ? _discover : null,
            icon: Icons.search,
            label: 'Discover devices'),
        const SizedBox(height: AppSpacing.md),
        if (_busy) const LinearProgressIndicator(),
        const SizedBox(height: AppSpacing.sm),
        Text(_status),
        const SizedBox(height: AppSpacing.sm),
        for (final device in _devices)
          Card(
              child: ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(device.name),
                  subtitle: const Text('Tap to connect'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: !_busy && _parked ? () => _connect(device) : null)),
        const SizedBox(height: AppSpacing.lg),
        ExpansionTile(title: const Text('Troubleshooting'), children: [
          const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
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
}
