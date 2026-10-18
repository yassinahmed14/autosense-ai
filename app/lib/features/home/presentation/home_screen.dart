import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/core/routing/app_router.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/core/utils/formatters.dart';
import 'package:autosense_ai/features/calculator/presentation/power_screen.dart';
import 'package:autosense_ai/features/dashboard/presentation/dashboard_screen.dart';
import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:autosense_ai/features/diagnostics/presentation/lookup_screen.dart';
import 'package:autosense_ai/features/diagnostics/presentation/manual_screen.dart';
import 'package:autosense_ai/features/diagnostics/presentation/result_screen.dart';
import 'package:autosense_ai/features/home/presentation/widgets/home_hero_card.dart';
import 'package:autosense_ai/features/privacy/presentation/privacy_screen.dart';
import 'package:autosense_ai/features/scanner/data/mock_obd_adapter.dart';
import 'package:autosense_ai/features/scanner/presentation/connection_screen.dart';
import 'package:autosense_ai/features/scanner/presentation/scan_screen.dart';
import 'package:autosense_ai/features/settings/presentation/settings_screen.dart';
import 'package:autosense_ai/features/subscription/data/subscription_controller.dart';
import 'package:autosense_ai/features/subscription/presentation/subscription_screen.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:autosense_ai/shared/widgets/empty_state.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/safety_notice.dart';
import 'package:autosense_ai/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// Launcher screen: hero, scanner entry, diagnostics tools and the
/// in-memory session history.
class HomeScreen extends StatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key, required this.api, this.subscription});

  /// Diagnostic API client shared with child screens.
  final ApiClient api;

  /// Subscription controller; when null the membership action is hidden.
  final SubscriptionController? subscription;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _history = <DiagnosticResult>[];

  void _record(DiagnosticResult result) =>
      setState(() => _history.insert(0, result));

  void _open(String route, Widget screen) =>
      AppRouter.push<void>(context, route, screen);

  void _openMockScan() => _open(
      AppRoutes.mockScan,
      ScanScreen(
          adapter: MockObdAdapter(), api: widget.api, onResult: _record));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('AutoSense AI'), actions: [
        if (widget.subscription != null)
          IconButton(
              tooltip: 'Membership plans',
              icon: const Icon(Icons.workspace_premium_outlined),
              onPressed: () => _open(AppRoutes.subscription,
                  SubscriptionScreen(controller: widget.subscription!))),
        IconButton(
            tooltip: 'Privacy & app information',
            icon: const Icon(Icons.privacy_tip_outlined),
            onPressed: () => _open(AppRoutes.privacy, const PrivacyScreen())),
        IconButton(
            tooltip: 'Configuration',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _open(AppRoutes.settings,
                SettingsScreen(apiBaseUrl: widget.api.baseUrl))),
        const SizedBox(width: AppSpacing.xs),
      ]),
      body: PageListView(children: [
        HomeHeroCard(
          onOpenDashboard: () => _open(AppRoutes.dashboard,
              DashboardScreen(adapter: MockObdAdapter(), simulated: true)),
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryActionButton(
          icon: Icons.cable,
          label: 'Connect a scanner • Bluetooth / Wi-Fi',
          onPressed: () => _open(AppRoutes.connection,
              ConnectionScreen(api: widget.api, onResult: _record)),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const SectionHeader('Understand a warning',
            large: true,
            subtitle: 'Preliminary guidance. A technician confirms the cause.'),
        const SizedBox(height: AppSpacing.sm),
        PrimaryActionButton(
          icon: Icons.edit_note,
          label: 'Enter codes or symptoms',
          onPressed: () => _open(
              AppRoutes.manual,
              ManualScreen(
                  api: widget.api,
                  onResult: _record,
                  onDetectCar: _openMockScan)),
        ),
        const SizedBox(height: AppSpacing.sm),
        SecondaryActionButton(
          icon: Icons.bluetooth,
          label: 'Try mock OBD scan',
          onPressed: _openMockScan,
        ),
        const SizedBox(height: AppSpacing.sm),
        SecondaryActionButton(
          icon: Icons.menu_book_outlined,
          label: 'DTC library',
          onPressed: () =>
              _open(AppRoutes.lookup, LookupScreen(api: widget.api)),
        ),
        const SizedBox(height: AppSpacing.sm),
        SecondaryActionButton(
          icon: Icons.speed,
          label: 'HP & torque calculator',
          onPressed: () => _open(AppRoutes.calculator, const PowerScreen()),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const ExpansionTile(
            leading: Icon(Icons.health_and_safety_outlined),
            title: Text('Safety and use'),
            children: [SafetyNotice()]),
        const SizedBox(height: AppSpacing.sm),
        SectionHeader(
          'Session history',
          subtitle: 'Temporary • disappears when the app restarts.',
          trailing: _history.isEmpty
              ? null
              : TextButton(
                  onPressed: () => setState(_history.clear),
                  child: const Text('Clear')),
        ),
        if (_history.isEmpty)
          const EmptyState(
              icon: Icons.history, title: 'No guidance results yet.'),
        for (final result in _history)
          Card(
            child: ListTile(
              leading: Icon(
                  result.simulated
                      ? Icons.science_outlined
                      : Icons.fact_check_outlined,
                  color: result.simulated
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.primary),
              title: Text(
                  '${result.simulated ? 'SIMULATED • ' : ''}${formatUrgency(result.urgency)}'),
              subtitle: Text(
                  '${result.dtcs.map((d) => d.code).join(', ')}\n${result.createdAt.toLocal()}'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  _open(AppRoutes.result, ResultScreen(result: result)),
            ),
          ),
        const SizedBox(height: AppSpacing.xxl),
      ]),
    );
  }
}
