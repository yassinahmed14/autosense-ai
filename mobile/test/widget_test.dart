import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:autosense_ai/main.dart';
import 'package:autosense_ai/services/api_client.dart';
import 'package:autosense_ai/screens/scan_screen.dart';
import 'package:autosense_ai/screens/power_screen.dart';
import 'package:autosense_ai/screens/ble_scan_screen.dart';
import 'package:autosense_ai/services/mock_obd_adapter.dart';

class RecordingMockAdapter extends MockObdAdapter {
  RecordingMockAdapter() : super(delay: Duration.zero);
  int clearCalls = 0;
  @override
  Future<void> clearStoredCodes() async {
    clearCalls++;
    await super.clearStoredCodes();
  }
}

void main() {
  testWidgets(
      'BLE screen explains native-only connection and disables discovery on desktop',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final api = ApiClient(baseUrl: 'http://localhost');
    addTearDown(api.close);
    await tester.pumpWidget(
        MaterialApp(home: BleScanScreen(api: api, onResult: (_) {})));
    expect(
        find.text('Experimental • compatibility unverified'), findsOneWidget);
    expect(find.textContaining('Real BLE requires the native'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Discover devices'), 150,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Discover devices'))
            .onPressed,
        isNull);
    debugDefaultTargetPlatformOverride = null;
  });
  testWidgets('calculator switches directions and uses the supplied RPM',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PowerScreen()));
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Torque (N·m)'), '200');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Rotational speed (RPM)'), '3000');
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('Calculate result'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculate result'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('84.3 hp (mechanical)'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(find.text('84.3 hp (mechanical)'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byType(DropdownButtonFormField<bool>), -200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<bool>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Torque from horsepower').last);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Mechanical horsepower (hp)'),
        findsOneWidget);
    expect(find.text('84.3 hp (mechanical)'), findsNothing);
  });
  testWidgets('demo clearing requires confirmation and supports cancelling',
      (tester) async {
    final adapter = RecordingMockAdapter();
    final api = ApiClient(baseUrl: 'http://localhost');
    addTearDown(api.close);
    await tester.pumpWidget(MaterialApp(
        home: ScanScreen(adapter: adapter, api: api, onResult: (_) {})));
    await tester.tap(find.text('Discover mock adapter'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Clear codes (demo)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear codes (demo)'));
    await tester.pumpAndSettle();
    expect(find.text('Clear demo codes?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(adapter.clearCalls, 0);
    await tester.tap(find.text('Clear codes (demo)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear demo codes'));
    await tester.pumpAndSettle();
    expect(find.text('Demo codes cleared. No vehicle was changed.'),
        findsOneWidget);
    expect(adapter.clearCalls, 1);
  });
  testWidgets(
      'manual submission displays structured result and session history',
      (tester) async {
    final api = ApiClient(
        baseUrl: 'http://localhost',
        client: MockClient((_) async => http.Response(
            File('test/fixtures/result.json').readAsStringSync(), 200)));
    addTearDown(api.close);
    await tester.pumpWidget(AutoSenseApp(api: api));
    expect(find.text('AutoSense AI'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Enter codes or symptoms'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enter codes or symptoms'));
    await tester.pumpAndSettle();
    final codes = find.widgetWithText(TextFormField, 'DTC codes');
    await tester.scrollUntilVisible(codes, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.enterText(codes, 'P0300');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final submit = find.text('Get preliminary guidance');
    await tester.scrollUntilVisible(submit, 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Diagnostic guidance'), findsOneWidget);
    expect(find.text('SIMULATED DATA • Not a vehicle scan'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Clear'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(find.text('Clear'), findsOneWidget);
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('No guidance results yet.'), findsOneWidget);
  });
  testWidgets('mock screen explains physical BLE status', (tester) async {
    await tester.pumpWidget(const AutoSenseApp());
    await tester.scrollUntilVisible(find.text('Try mock OBD scan'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try mock OBD scan'));
    await tester.pumpAndSettle();
    expect(find.text('MOCK MODE'), findsOneWidget);
    await tester.tap(find.text('Discover mock adapter'));
    await tester.pumpAndSettle();
    expect(find.text('AutoSense demo adapter'), findsOneWidget);
    await tester.tap(find.text('AutoSense demo adapter'));
    await tester.pumpAndSettle();
    expect(find.text('Review simulated scan'), findsOneWidget);
    expect(
        find.text(
            'SIMULATED codes only. Your real vehicle has not been scanned.'),
        findsOneWidget);
    expect(find.textContaining('Simulated car: 2020 Toyota Corolla.'),
        findsOneWidget);
    final makeMenu = find.byKey(const ValueKey('vehicle-make'));
    expect(
        tester.widget<DropdownButtonFormField<String>>(makeMenu).initialValue,
        'Toyota');
    expect(
        tester
            .widget<DropdownButtonFormField<String>>(
                find.byKey(const ValueKey('vehicle-model-Toyota')))
            .initialValue,
        'Corolla');
    await tester.ensureVisible(makeMenu);
    await tester.pumpAndSettle();
    await tester.tap(makeMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volkswagen').last);
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<DropdownButtonFormField<String>>(
                find.byKey(const ValueKey('vehicle-model-Volkswagen')))
            .initialValue,
        isNull);
  });
}
