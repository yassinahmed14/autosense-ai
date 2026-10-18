import 'package:autosense_ai/core/config/app_config.dart';
import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/core/theme/app_theme.dart';
import 'package:autosense_ai/features/home/presentation/home_screen.dart';
import 'package:autosense_ai/features/subscription/data/subscription_controller.dart';
import 'package:autosense_ai/features/subscription/presentation/subscription_screen.dart';
import 'package:flutter/material.dart';

/// Root widget: owns the [ApiClient] and [SubscriptionController], applies
/// the light theme and, in billing-enabled builds, overlays the membership
/// gate until a subscription is verified.
class AutoSenseApp extends StatefulWidget {
  /// Creates the app. Inject [api] in tests to stub the backend.
  const AutoSenseApp({super.key, this.api});

  /// Optional API client; when null the app creates and disposes its own.
  final ApiClient? api;

  @override
  State<AutoSenseApp> createState() => _AutoSenseAppState();
}

class _AutoSenseAppState extends State<AutoSenseApp>
    with WidgetsBindingObserver {
  late final ApiClient api =
      widget.api ?? ApiClient(baseUrl: AppConfig.apiBaseUrl);
  late final SubscriptionController subscription =
      SubscriptionController(api.baseUrl);
  final ThemeData _theme = AppTheme.light();

  bool get _locked => SubscriptionController.enabled && !subscription.active;

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
        theme: _theme,
        themeMode: ThemeMode.light,
        builder: (context, child) => AnimatedBuilder(
          animation: subscription,
          builder: (context, _) => Stack(children: [
            ExcludeSemantics(
              excluding: _locked,
              child: IgnorePointer(ignoring: _locked, child: child),
            ),
            if (_locked)
              Positioned.fill(
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: _theme,
                  themeMode: ThemeMode.light,
                  home: SubscriptionScreen(controller: subscription),
                ),
              ),
          ]),
        ),
        home: HomeScreen(api: api, subscription: subscription),
      );
}
