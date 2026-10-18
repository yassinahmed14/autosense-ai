import 'dart:async';

import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/core/routing/app_router.dart';
import 'package:autosense_ai/core/theme/app_colors.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/features/dashboard/presentation/dashboard_screen.dart';
import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:autosense_ai/features/diagnostics/presentation/manual_screen.dart';
import 'package:autosense_ai/features/scanner/data/ble_obd_adapter.dart';
import 'package:autosense_ai/features/scanner/domain/obd_adapter.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Menu for a verified BLE adapter: live dashboard, diagnose, disconnect.
/// Keeps the Bluetooth session alive between actions.
class ConnectedScannerScreen extends StatefulWidget {
  /// Creates the connected-scanner menu.
  const ConnectedScannerScreen(
      {super.key,
      required this.adapter,
      required this.device,
      required this.api,
      required this.onResult});

  /// Connected BLE adapter (ownership transferred from discovery).
  final BleObdAdapter adapter;

  /// The selected device.
  final ObdDevice device;

  /// Diagnostic API client.
  final ApiClient api;

  /// Records results in the session history.
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
        await AppRouter.push<void>(
            context,
            AppRoutes.dashboard,
            DashboardScreen(
                adapter: widget.adapter,
                simulated: false,
                alreadyConnected: true,
                disconnectOnDispose: false));
        await widget.adapter.waitForReading();
      });

  Future<void> _diagnose() => _use(() async {
        final snapshot = await widget.adapter.readStoredCodes();
        if (!mounted) return;
        await AppRouter.push<void>(
            context,
            AppRoutes.manual,
            ManualScreen(
                api: widget.api,
                onResult: widget.onResult,
                initialCodes: snapshot.codes,
                source: 'ble_obd'));
      });

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateTimer?.cancel();
    unawaited(widget.adapter.disconnect());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connected = widget.adapter.state == AdapterState.connected;
    return Scaffold(
      appBar: AppBar(title: const Text('Your connected scanner')),
      body: PageListView(children: [
        Row(children: [
          HeaderIcon(connected ? Icons.check_circle : Icons.bluetooth_disabled,
              color: connected
                  ? AppColors.success
                  : theme.colorScheme.onTertiaryContainer,
              background: connected
                  ? AppColors.successContainer
                  : theme.colorScheme.tertiaryContainer),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(connected ? 'Adapter connected' : 'Adapter disconnected',
                    style: theme.textTheme.headlineSmall),
                Text(widget.device.name),
              ],
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Text(widget.adapter.ecuReady
            ? 'ECU communication verified'
            : 'ECU communication not yet verified'),
        const SizedBox(height: AppSpacing.sm),
        Text(
            'Choose what you want to do. Vehicle ECU access is checked when you read live data or stored codes.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.lg),
        PrimaryActionButton(
            onPressed: _busy ? null : _dashboard,
            icon: Icons.speed,
            label: 'Live dashboard'),
        const SizedBox(height: AppSpacing.md),
        PrimaryActionButton(
            onPressed: _busy ? null : _diagnose,
            icon: Icons.car_repair,
            label: 'Diagnose'),
        const SizedBox(height: AppSpacing.md),
        SecondaryActionButton(
            onPressed: _busy
                ? null
                : () async {
                    await widget.adapter.disconnect();
                    if (context.mounted) Navigator.of(context).pop();
                  },
            label: 'Disconnect'),
        if (_busy) ...[
          const SizedBox(height: AppSpacing.md),
          const LinearProgressIndicator(),
        ],
        if (_error != null)
          Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: StatusBanner(_error!, tone: BannerTone.error)),
        TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(
                  text:
                      '${_error ?? ''}\n${_report.isEmpty ? widget.adapter.diagnosticReport : _report}'));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Connection report copied')));
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy connection report')),
        const SizedBox(height: AppSpacing.md),
        const StatusBanner(
            'Experimental connection. Stored engine/emissions codes only. '
            'Possible causes need confirmation. Real code clearing is disabled.',
            tone: BannerTone.warning),
      ]),
    );
  }
}
