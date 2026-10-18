import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/features/dashboard/domain/telemetry_model.dart';
import 'package:autosense_ai/features/scanner/data/ble_obd_adapter.dart';
import 'package:autosense_ai/features/scanner/domain/obd_adapter.dart';
import 'package:autosense_ai/features/scanner/presentation/ble_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SerialChannel c(String service, String uuid,
        {bool write = false, bool notify = false}) =>
    SerialChannel(service, uuid,
        write: write, writeWithoutResponse: false, notify: notify);

class FakeAutoBle extends BleObdAdapter {
  FakeAutoBle({this.fail = false});
  final bool fail;
  bool connected = false;
  int reads = 0;
  bool failRead = false;
  Future<void>? pendingRead;
  static const device = ObdDevice('fake-device', 'OBDII', simulated: false);
  @override
  bool get ready => connected;
  @override
  AdapterState get state =>
      connected ? AdapterState.connected : AdapterState.disconnected;
  @override
  Future<List<ObdDevice>> discover() async => [device];
  @override
  Future<void> connect(ObdDevice device) async {
    if (fail) throw StateError('Unrecognized adapter profile');
    connected = true;
  }

  @override
  Future<void> disconnect() async {
    connected = false;
  }

  @override
  Future<void> waitForReading() async {
    await pendingRead;
  }

  @override
  Future<TelemetrySample> readLiveData() async {
    if (failRead) throw const FormatException('NO DATA');
    pendingRead = Future<void>.delayed(const Duration(milliseconds: 30));
    await pendingRead;
    pendingRead = null;
    return TelemetrySample(
        speedKph: 0,
        rpm: 800,
        speedAt: DateTime.now().toUtc(),
        rpmAt: DateTime.now().toUtc(),
        simulated: false);
  }

  @override
  Future<ObdSnapshot> readStoredCodes() async {
    reads++;
    if (failRead) throw const FormatException('NO DATA');
    return ObdSnapshot(
        codes: const ['P0300'],
        capturedAt: DateTime.now().toUtc(),
        simulated: false);
  }
}

Future<void> chooseDevice(WidgetTester tester, FakeAutoBle adapter) async {
  final api = ApiClient(baseUrl: 'http://localhost');
  addTearDown(api.close);
  await tester.pumpWidget(MaterialApp(
      home: BleScanScreen(adapter: adapter, api: api, onResult: (_) {})));
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pump();
  await tester.tap(find.text('Discover devices'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text('OBDII'), 150);
  await tester.tap(find.text('OBDII'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ECU read failure keeps Bluetooth connected and allows retry',
      (tester) async {
    final adapter = FakeAutoBle()..failRead = true;
    await chooseDevice(tester, adapter);
    await tester.tap(find.text('Diagnose'));
    await tester.pumpAndSettle();
    expect(adapter.connected, isTrue);
    expect(find.textContaining('ECU read failed'), findsOneWidget);
    expect(find.text('Copy connection report'), findsOneWidget);
    adapter.failRead = false;
    await tester.tap(find.text('Diagnose'));
    await tester.pumpAndSettle();
    expect(adapter.reads, 2);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('live read failure and returning to menu preserves Bluetooth',
      (tester) async {
    final adapter = FakeAutoBle()..failRead = true;
    await chooseDevice(tester, adapter);
    await tester.tap(find.text('Live dashboard'));
    await tester.pumpAndSettle();
    expect(adapter.connected, isTrue);
    expect(find.textContaining('ECU read stopped'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(adapter.connected, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
  test('ELM UART chooses documented directions independent of discovery order',
      () {
    final profile = detectBleSerialProfile([
      c('fff0', 'fff1', notify: true),
      c('180a', '2a29'),
      c('fff0', 'fff2', write: true),
    ]);
    expect(profile.tx.characteristic, 'fff2');
    expect(profile.rx.characteristic, 'fff1');
  });
  test('HM-10 combined UART and Nordic UART are recognized by UUID/properties',
      () {
    final combined = c('0000ffe0-0000-1000-8000-00805f9b34fb', 'FFE1',
        write: true, notify: true);
    expect(detectBleSerialProfile([combined]).tx, same(combined));
    expect(
        detectBleSerialProfile([
          c('6e400001-b5a3-f393-e0a9-e50e24dcca9e',
              '6e400003-b5a3-f393-e0a9-e50e24dcca9e',
              notify: true),
          c('6e400001-b5a3-f393-e0a9-e50e24dcca9e',
              '6e400002-b5a3-f393-e0a9-e50e24dcca9e',
              write: true),
        ]).name,
        'Nordic UART');
  });
  test('unknown, ambiguous, duplicate and incorrect capabilities are rejected',
      () {
    for (final channels in [
      [c('1234', '5678', write: true, notify: true)],
      [c('fff0', 'fff1', notify: true), c('fff0', 'fff2')],
      [
        c('ffe0', 'ffe1', write: true, notify: true),
        c('fff0', 'fff1', notify: true),
        c('fff0', 'fff2', write: true)
      ],
      [
        c('ffe0', 'ffe1', write: true, notify: true),
        c('ffe0', 'ffe1', write: true, notify: true)
      ],
    ]) {
      expect(() => detectBleSerialProfile(channels), throwsUnsupportedError);
    }
  });
  testWidgets(
      'selecting OBD opens connected menu without RX/TX and Diagnose imports codes',
      (tester) async {
    final adapter = FakeAutoBle();
    await chooseDevice(tester, adapter);
    expect(find.text('Adapter connected'), findsOneWidget);
    expect(find.text('Live dashboard'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<SerialChannel>), findsNothing);
    expect(adapter.connected, isTrue);
    await tester.tap(find.text('Diagnose'));
    await tester.pumpAndSettle();
    expect(adapter.reads, 1);
    expect(
        find.text(
            'Codes imported from an experimental BLE read. Review them; adapter compatibility and diagnoses remain unverified. Only stored engine/emissions codes were requested.'),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('failed automatic setup never displays connected menu',
      (tester) async {
    await chooseDevice(tester, FakeAutoBle(fail: true));
    expect(find.text('Adapter connected'), findsNothing);
    expect(find.textContaining('Unrecognized adapter profile'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('returning from live dashboard keeps the menu session connected',
      (tester) async {
    final adapter = FakeAutoBle();
    await chooseDevice(tester, adapter);
    await tester.tap(find.text('Live dashboard'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(adapter.connected, isTrue);
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Adapter connected'), findsOneWidget);
    expect(adapter.connected, isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    expect(adapter.connected, isFalse);
  });
}
