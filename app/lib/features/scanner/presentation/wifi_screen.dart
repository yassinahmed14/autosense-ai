import 'dart:async';

import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/core/routing/app_router.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/features/dashboard/presentation/dashboard_screen.dart';
import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:autosense_ai/features/diagnostics/presentation/manual_screen.dart';
import 'package:autosense_ai/features/scanner/data/wifi_obd_adapter.dart';
import 'package:autosense_ai/features/scanner/domain/obd_adapter.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/status_banner.dart';
import 'package:flutter/material.dart';

/// Connects to an ELM-over-TCP Wi-Fi adapter for live data or stored codes.
class WifiScreen extends StatefulWidget {
  /// Creates the Wi-Fi connection screen.
  const WifiScreen({super.key, required this.api, required this.onResult});

  /// Diagnostic API client.
  final ApiClient api;

  /// Records results in the session history.
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
        await AppRouter.push<void>(
            context,
            AppRoutes.dashboard,
            DashboardScreen(
                adapter: adapter, simulated: false, alreadyConnected: true));
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

  bool get _canConnect =>
      !_busy && _parked && _documented && WifiObdAdapter.supported;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Scaffold(
      appBar: AppBar(title: const Text('Connect with Wi-Fi')),
      body: PageListView(children: [
        Row(children: [
          const HeaderIcon(Icons.wifi),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
              child: Text('ELM serial over Wi-Fi',
                  style: theme.textTheme.headlineSmall)),
        ]),
        const SizedBox(height: AppSpacing.md),
        const StatusBanner(
            'Experimental • no physical adapter tested. Join the adapter’s Wi-Fi in phone settings first. Use the host and TCP port from its manual; AutoSense does not assume an address or port. UDP/HTTP and proprietary Wi-Fi protocols need a different driver.',
            tone: BannerTone.warning),
        if (!WifiObdAdapter.supported)
          const StatusBanner(
              'This browser cannot open a raw TCP connection. Use the native Android/iPhone app, or explore the live demo.',
              tone: BannerTone.error),
        const SizedBox(height: AppSpacing.lg),
        TextField(
            controller: _host,
            enabled: !_busy,
            autocorrect: false,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: 'Adapter host / IP')),
        const SizedBox(height: AppSpacing.md),
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
        const SizedBox(height: AppSpacing.sm),
        Text(_status),
        if (_busy) ...[
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(),
        ],
        const SizedBox(height: AppSpacing.md),
        PrimaryActionButton(
            icon: Icons.speed,
            label: 'Connect and open dashboard',
            onPressed: _canConnect ? () => _connect(dashboard: true) : null),
        const SizedBox(height: AppSpacing.sm),
        SecondaryActionButton(
            onPressed: _canConnect ? () => _connect(dashboard: false) : null,
            label: 'Read stored codes'),
        if (_busy)
          TextButton(
              onPressed: () => _adapter?.disconnect(),
              child: const Text('Cancel connection')),
        if (_snapshot != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_snapshot!.codes.isEmpty
                      ? 'No stored codes reported by responding ECUs. This does not mean no fault.'
                      : 'Stored codes: ${_snapshot!.codes.join(', ')}'),
                  for (final e in _snapshot!.codesByEcu.entries)
                    Text('ECU ${e.key}: ${e.value.join(', ')}', style: caption),
                  const SizedBox(height: AppSpacing.md),
                  SecondaryActionButton(
                      onPressed: () => AppRouter.push<void>(
                          context,
                          AppRoutes.manual,
                          ManualScreen(
                              api: widget.api,
                              onResult: widget.onResult,
                              initialCodes: _snapshot!.codes,
                              source: 'wifi_obd')),
                      label: 'Review codes and symptoms'),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
            'Stored engine/emissions codes and selected live PIDs over CAN only. Real clearing and automatic vehicle identification remain unavailable. A Wi-Fi network without internet may also prevent access to your diagnostic API; readings stay local.',
            style: caption),
      ]),
    );
  }
}
