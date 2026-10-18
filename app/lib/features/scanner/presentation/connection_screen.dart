import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/core/routing/app_router.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/features/dashboard/presentation/dashboard_screen.dart';
import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:autosense_ai/features/scanner/data/mock_obd_adapter.dart';
import 'package:autosense_ai/features/scanner/presentation/ble_scan_screen.dart';
import 'package:autosense_ai/features/scanner/presentation/wifi_screen.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// Connection hub: live demo, Bluetooth LE or Wi-Fi scanner, plus multi-protocol
/// SAE J1979 and emissions readiness monitor reference.
class ConnectionScreen extends StatelessWidget {
  /// Creates the connection hub.
  const ConnectionScreen(
      {super.key, required this.api, required this.onResult});

  /// Diagnostic API client forwarded to scanner flows.
  final ApiClient api;

  /// Records results in the session history.
  final ValueChanged<DiagnosticResult> onResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    void open(String route, Widget screen) =>
        AppRouter.push<void>(context, route, screen);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your connection')),
      body: PageListView(maxWidth: 760, children: [
        Text('Your car. Your dashboard.',
            style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
            'Choose how your scanner communicates. Connector shape, vehicle protocol and phone connection are separate compatibility requirements.',
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.xl),
        NavigationCard(
            icon: Icons.play_circle_outline,
            title: 'Try live demo',
            description:
                'Animated RPM, speed, temperature and a simulated 10-second performance run.',
            onTap: () => open(AppRoutes.dashboard,
                DashboardScreen(adapter: MockObdAdapter(), simulated: true))),
        NavigationCard(
            icon: Icons.bluetooth,
            title: 'Bluetooth LE',
            description:
                'Select your OBD adapter, connect automatically, then choose live data or diagnostics.',
            onTap: () => open(AppRoutes.bleScan,
                BleScanScreen(api: api, onResult: onResult))),
        NavigationCard(
            icon: Icons.wifi,
            title: 'Wi-Fi',
            description:
                'Experimental ELM ASCII over TCP • join the adapter network, then enter its host and port.',
            onTap: () =>
                open(AppRoutes.wifi, WifiScreen(api: api, onResult: onResult))),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(
          'Standard OBD-II protocols & readiness monitors',
          eyebrow: 'ALL-VEHICLE SAE J1979 REFERENCE',
          subtitle:
              'OBD-II compliant vehicles (1996+ US, 2001+ EU petrol, 2004+ EU diesel) use a standard 16-pin J1962 port. AutoSense AI initializes ELM327 CAN (ISO 15765-4 11/29-bit) and preserves offline diagnostic capability when connected to Wi-Fi adapters.',
        ),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pre-Inspection & Emissions Readiness Checklist:',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '• Continuous Monitors: Misfire, Fuel System, Comprehensive Components\n'
                  '• Non-Continuous (Gasoline): Catalyst, Heated Catalyst, EVAP, Secondary Air, O2 Sensor, O2 Sensor Heater, EGR/VVT\n'
                  '• Non-Continuous (Diesel): NMHC Catalyst, NOx/SCR Aftertreatment, Boost Pressure, Exhaust Gas Sensor, PM Filter, EGR/VVT\n'
                  '• Note: Clearing codes resets readiness monitors to Incomplete until a drive cycle finishes.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader('Other scanner types',
            subtitle:
                'The app has a driver interface for additional hardware. Bluetooth Classic, USB, OBD-I and proprietary scanners need their own documented driver and validation. They are not currently supported. ELM-compatible CAN devices are the current experimental subset; no universal compatibility is claimed.'),
      ]),
    );
  }
}
