import 'package:flutter/material.dart';
import 'models/diagnostic.dart';
import 'screens/lookup_screen.dart';
import 'screens/manual_screen.dart';
import 'screens/power_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/subscription_screen.dart';
import 'services/subscription_controller.dart';
import 'screens/result_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/connection_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/api_client.dart';
import 'services/mock_obd_adapter.dart';
import 'widgets/safety_notice.dart';

void main() => runApp(const AutoSenseApp());

class AutoSenseApp extends StatefulWidget {
  const AutoSenseApp({super.key, this.api});
  final ApiClient? api;
  @override
  State<AutoSenseApp> createState() => _AutoSenseAppState();
}

class _AutoSenseAppState extends State<AutoSenseApp>
    with WidgetsBindingObserver {
  late final ApiClient api = widget.api ??
      ApiClient(
          baseUrl: const String.fromEnvironment('API_BASE_URL',
              defaultValue: 'http://10.0.2.2:8000'));
  late final SubscriptionController subscription =
      SubscriptionController(api.baseUrl);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    subscription.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!SubscriptionController.enabled) return;
    if (state == AppLifecycleState.resumed) {
      subscription.resume();
    } else {
      subscription.suspend();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    subscription.dispose();
    if (widget.api == null) api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AutoSense AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xff0b1420),
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff4ce0b3),
                brightness: Brightness.dark,
                surface: const Color(0xff111e2d)),
            cardTheme: CardThemeData(
                color: const Color(0xff152334),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22))),
            filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)))),
            outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)))),
            inputDecorationTheme:
                const InputDecorationTheme(border: OutlineInputBorder())),
        builder: (context, child) => AnimatedBuilder(
            animation: subscription,
            builder: (context, _) => Stack(children: [
                  ExcludeSemantics(
                    excluding:
                        SubscriptionController.enabled && !subscription.active,
                    child: IgnorePointer(
                      ignoring: SubscriptionController.enabled &&
                          !subscription.active,
                      child: child!,
                    ),
                  ),
                  if (SubscriptionController.enabled && !subscription.active)
                    Positioned.fill(
                        child: MaterialApp(
                      debugShowCheckedModeBanner: false,
                      theme: ThemeData(
                          brightness: Brightness.dark, useMaterial3: true),
                      home: SubscriptionScreen(controller: subscription),
                    )),
                ])),
        home: HomeScreen(api: api, subscription: subscription),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, this.subscription});
  final ApiClient api;
  final SubscriptionController? subscription;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _history = <DiagnosticResult>[];
  void _record(DiagnosticResult result) =>
      setState(() => _history.insert(0, result));
  void _open(Widget screen) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => screen));
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('AutoSense AI'), actions: [
          if (widget.subscription != null)
            IconButton(
                tooltip: 'Membership plans',
                icon: const Icon(Icons.workspace_premium_outlined),
                onPressed: () => _open(
                    SubscriptionScreen(controller: widget.subscription!))),
          IconButton(
              tooltip: 'Privacy & app information',
              icon: const Icon(Icons.privacy_tip_outlined),
              onPressed: () => _open(const PrivacyScreen())),
          IconButton(
              tooltip: 'Configuration',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => _open(Scaffold(
                  appBar: AppBar(title: const Text('Configuration')),
                  body: ListView(padding: const EdgeInsets.all(20), children: [
                    Text('API: ${widget.api.baseUrl}'),
                    const Text('Change API_BASE_URL at launch; see README.\n\n'
                        'Diagnostic engine: transparent demo rules\nAdapter: demo + experimental BLE / Wi-Fi ELM reader\n'
                        'History: memory only, cleared when the app restarts\n'
                        'Supabase: schema supplied, connection not enabled\n\n'
                        'No account, VIN, analytics, or cloud history in this starter.'),
                  ])))),
        ]),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: ListView(padding: const EdgeInsets.all(22), children: [
                  Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                              colors: [Color(0xff143e46), Color(0xff202c53)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AUTOSENSE / DRIVE INSIGHT',
                                style: TextStyle(
                                    color: Color(0xff4ce0b3),
                                    letterSpacing: 2)),
                            const SizedBox(height: 18),
                            const Text('Your car,\nat a glance.',
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1)),
                            const SizedBox(height: 14),
                            const Text(
                                'Live gauges. Clear choices.\nRecord a run and explore your data.',
                                style: TextStyle(
                                    color: Color(0xffbfd0e4), fontSize: 17)),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                                icon: const Icon(Icons.speed),
                                label: const Text('Open live dashboard'),
                                onPressed: () => _open(DashboardScreen(
                                    adapter: MockObdAdapter(),
                                    simulated: true))),
                            const SizedBox(height: 8),
                            const Text(
                                'Preview with simulated data • no car connection',
                                style: TextStyle(
                                    color: Color(0xffbfd0e4), fontSize: 12)),
                          ])),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                      icon: const Icon(Icons.cable),
                      label:
                          const Text('Connect a scanner • Bluetooth / Wi-Fi'),
                      onPressed: () => _open(ConnectionScreen(
                          api: widget.api, onResult: _record))),
                  const SizedBox(height: 20),
                  const Text('Understand a warning',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text(
                      'Preliminary guidance. A technician confirms the cause.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Enter codes or symptoms'),
                      onPressed: () => _open(ManualScreen(
                          api: widget.api,
                          onResult: _record,
                          onDetectCar: () => _open(ScanScreen(
                              adapter: MockObdAdapter(),
                              api: widget.api,
                              onResult: _record))))),
                  OutlinedButton.icon(
                      icon: const Icon(Icons.bluetooth),
                      label: const Text('Try mock OBD scan'),
                      onPressed: () => _open(ScanScreen(
                          adapter: MockObdAdapter(),
                          api: widget.api,
                          onResult: _record))),
                  OutlinedButton.icon(
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('DTC library'),
                      onPressed: () => _open(LookupScreen(api: widget.api))),
                  OutlinedButton.icon(
                      icon: const Icon(Icons.speed),
                      label: const Text('HP & torque calculator'),
                      onPressed: () => _open(const PowerScreen())),
                  const SizedBox(height: 24),
                  const ExpansionTile(
                      title: Text('Safety and use'),
                      children: [SafetyNotice()]),
                  Row(children: [
                    Expanded(
                        child: Text('Session history',
                            style: Theme.of(context).textTheme.titleLarge)),
                    if (_history.isNotEmpty)
                      TextButton(
                          onPressed: () => setState(_history.clear),
                          child: const Text('Clear'))
                  ]),
                  const Text('Temporary • disappears when the app restarts.'),
                  if (_history.isEmpty)
                    const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No guidance results yet.')),
                  for (final result in _history)
                    Card(
                        child: ListTile(
                            title: Text(
                                '${result.simulated ? 'SIMULATED • ' : ''}${result.urgency.replaceAll('_', ' ')}'),
                            subtitle: Text(
                                '${result.dtcs.map((d) => d.code).join(', ')}\n${result.createdAt.toLocal()}'),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _open(ResultScreen(result: result)))),
                ]))),
      );
}
