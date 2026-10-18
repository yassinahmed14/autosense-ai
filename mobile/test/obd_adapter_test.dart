import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:autosense_ai/services/mock_obd_adapter.dart';
import 'package:autosense_ai/services/obd_adapter.dart';

void main() {
  test('mock lifecycle and provenance; disconnected read is forbidden',
      () async {
    final adapter = MockObdAdapter(delay: Duration.zero);
    await expectLater(adapter.readStoredCodes(), throwsStateError);
    final devices = await adapter.discover();
    expect(devices.single.simulated, isTrue);
    await adapter.connect(devices.single);
    expect(adapter.state, AdapterState.connected);
    final scan = await adapter.readStoredCodes();
    expect(scan.simulated, isTrue);
    expect(scan.codes, ['P0300', 'P0171']);
    expect(scan.vehicle!.make, 'Toyota');
    expect(scan.vehicle!.simulated, isTrue);
    await adapter.clearStoredCodes();
    expect((await adapter.readStoredCodes()).codes, isEmpty);
    await adapter.disconnect();
    expect(adapter.state, AdapterState.disconnected);
    await expectLater(adapter.readStoredCodes(), throwsStateError);
    await expectLater(adapter.clearStoredCodes(), throwsStateError);
  });
  test('mock failure restores disconnected state', () async {
    final adapter = MockObdAdapter(delay: Duration.zero, failConnection: true);
    final devices = await adapter.discover();
    await expectLater(adapter.connect(devices.single), throwsStateError);
    expect(adapter.state, AdapterState.disconnected);
  });
  test('disconnect cancels pending connection', () async {
    final adapter = MockObdAdapter(delay: const Duration(milliseconds: 10));
    final device = (await adapter.discover()).single;
    final connection = adapter.connect(device);
    final assertion = expectLater(connection, throwsStateError);
    await adapter.disconnect();
    await assertion;
    expect(adapter.state, AdapterState.disconnected);
  });
  test('real BLE fails explicitly', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final adapter = BleObdAdapter();
    await expectLater(adapter.discover(), throwsUnsupportedError);
    await expectLater(adapter.clearStoredCodes(), throwsUnsupportedError);
  });
}
