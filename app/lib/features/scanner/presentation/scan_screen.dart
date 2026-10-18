import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/core/routing/app_router.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:autosense_ai/features/diagnostics/presentation/manual_screen.dart';
import 'package:autosense_ai/features/scanner/domain/obd_adapter.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/safety_notice.dart';
import 'package:autosense_ai/shared/widgets/status_banner.dart';
import 'package:flutter/material.dart';

/// Mock OBD scan demo: discover the simulated adapter, read demo codes and a
/// simulated vehicle, or clear demo codes after confirmation.
class ScanScreen extends StatefulWidget {
  /// Creates the mock scan screen.
  const ScanScreen(
      {super.key,
      required this.adapter,
      required this.api,
      required this.onResult});

  /// Adapter to use (the mock adapter in production).
  final ObdAdapter adapter;

  /// Diagnostic API client.
  final ApiClient api;

  /// Records results in the session history.
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
      await AppRouter.push<void>(
          context,
          AppRoutes.manual,
          ManualScreen(
              api: widget.api,
              onResult: widget.onResult,
              initialCodes: snapshot.codes,
              initialVehicle: snapshot.vehicle,
              source: 'mock_obd'));
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
              icon: const Icon(Icons.delete_sweep_outlined),
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('OBD adapter demo')),
      body: PageListView(children: [
        const SafetyNotice(),
        const SizedBox(height: AppSpacing.sm),
        Text('MOCK MODE', style: theme.textTheme.headlineSmall),
        const StatusBanner(
            'This demo does not use Bluetooth or connect to a vehicle. Experimental '
            'BLE and Wi-Fi connections are available separately, with no validated adapter compatibility.',
            tone: BannerTone.simulated),
        Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
                'Auto-detect car demo: selecting the adapter fills in a simulated '
                '2020 Toyota Corolla and reads demo codes. Real car identification is not connected yet.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
        const SizedBox(height: AppSpacing.md),
        Text(_status),
        if (_busy) const LinearProgressIndicator(),
        const SizedBox(height: AppSpacing.sm),
        PrimaryActionButton(
            onPressed: _busy ? null : _discover,
            label: 'Discover mock adapter'),
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
}
