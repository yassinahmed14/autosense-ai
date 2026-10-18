import 'package:flutter/material.dart';

/// Stable route names. Used for analytics-free route identification in tests
/// and for `RouteSettings.name`, so navigation stays inspectable.
abstract final class AppRoutes {
  /// Home / launcher screen.
  static const home = '/';

  /// Live dashboard (demo or connected adapter).
  static const dashboard = '/dashboard';

  /// Scanner connection hub.
  static const connection = '/scanner';

  /// Bluetooth LE adapter discovery.
  static const bleScan = '/scanner/ble';

  /// Connected BLE scanner menu.
  static const connectedScanner = '/scanner/ble/connected';

  /// Wi-Fi ELM adapter connection.
  static const wifi = '/scanner/wifi';

  /// Mock OBD scan demo.
  static const mockScan = '/scanner/mock';

  /// Manual code / symptom entry.
  static const manual = '/diagnostics/manual';

  /// Diagnostic guidance result.
  static const result = '/diagnostics/result';

  /// DTC lookup library.
  static const lookup = '/diagnostics/lookup';

  /// HP & torque calculator.
  static const calculator = '/calculator';

  /// Membership / subscription plans.
  static const subscription = '/subscription';

  /// Privacy and app information.
  static const privacy = '/privacy';

  /// Configuration / settings.
  static const settings = '/settings';
}

/// Tiny navigation helper. Screens take constructor arguments (API client,
/// callbacks, adapters), so routes are built from widgets rather than a
/// string-keyed table. Every push carries an [AppRoutes] name.
abstract final class AppRouter {
  /// Builds a named [MaterialPageRoute] for [screen].
  static MaterialPageRoute<T> route<T>(String name, Widget screen) =>
      MaterialPageRoute<T>(
          settings: RouteSettings(name: name), builder: (_) => screen);

  /// Pushes [screen] under [name].
  static Future<T?> push<T>(BuildContext context, String name, Widget screen) =>
      Navigator.of(context).push<T>(route<T>(name, screen));

  /// Replaces the current route with [screen] under [name].
  static Future<T?> replace<T>(
          BuildContext context, String name, Widget screen) =>
      Navigator.of(context).pushReplacement<T, void>(route<T>(name, screen));
}
