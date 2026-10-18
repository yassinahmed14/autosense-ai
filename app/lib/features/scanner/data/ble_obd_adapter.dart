import 'dart:async';

import 'package:autosense_ai/features/dashboard/domain/telemetry_model.dart';
import 'package:autosense_ai/features/scanner/data/ble_serial_profile.dart';
import 'package:autosense_ai/features/scanner/data/elm_protocol.dart';
import 'package:autosense_ai/features/scanner/domain/obd_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

export 'package:autosense_ai/features/scanner/data/ble_serial_profile.dart';

/// Experimental transport: documented UART detection plus an ELM handshake.
class BleObdAdapter implements LiveObdAdapter {
  FlutterReactiveBle? _plugin;
  FlutterReactiveBle get _ble => _plugin ??= FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scan;
  StreamSubscription<ConnectionStateUpdate>? _connection;
  Completer<void>? _connecting, _scanning;
  ElmSession? _session;
  String? _deviceId;
  int _generation = 0;
  AdapterState _state = AdapterState.disconnected;
  @override
  AdapterState get state => _state;
  List<SerialChannel> channels = const [];
  String connectionReport = '';
  String profileName = '';
  String get adapterIdentity => _session?.adapterIdentity ?? '';
  bool get ready =>
      state == AdapterState.connected &&
      adapterIdentity.isNotEmpty &&
      (_session?.usable ?? false);
  bool get ecuReady => _session?.ecuReady ?? false;
  String get diagnosticReport =>
      'Profile: $profileName\nAdapter: $adapterIdentity\n'
      'Bluetooth: ${state.name}\nECU verified: $ecuReady\n'
      '${_session?.transcript.join('\n\n') ?? ''}\n\n$connectionReport';
  Future<TelemetrySample>? _liveReading;

  Future<void> waitForReading() async {
    try {
      await _liveReading;
    } catch (_) {/* Dashboard reports read failures. */}
  }

  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _ready() async {
    if (!supported) {
      throw UnsupportedError(
          'Real BLE requires the native Android or iPhone app. This browser preview supports the demo only.');
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final sdk = await const MethodChannel('autosense/platform')
          .invokeMethod<int>('sdkInt');
      if (sdk == null) {
        throw StateError(
            'Could not determine Android permission requirements.');
      }
      final permissions = sdk >= 31
          ? [Permission.bluetoothScan, Permission.bluetoothConnect]
          : [Permission.locationWhenInUse];
      final results = await permissions.request();
      if (results.values.any((p) => !p.isGranted)) {
        throw StateError(
            'Bluetooth permission denied. Allow Nearby devices (or Location on older Android) in phone settings, then retry.');
      }
    }
    final status = await _ble.statusStream
        .firstWhere((s) => s != BleStatus.unknown)
        .timeout(const Duration(seconds: 15));
    if (status != BleStatus.ready) {
      throw StateError(
          'Bluetooth is ${status.name}. Enable Bluetooth, allow access, and on older Android enable Location services.');
    }
  }

  @override
  Future<List<ObdDevice>> discover() async {
    await disconnect();
    final generation = _generation;
    await _ready();
    if (generation != _generation) throw StateError('Discovery cancelled.');
    final devices = <String, ObdDevice>{};
    final done = Completer<void>();
    _scanning = done;
    final timer = Timer(const Duration(seconds: 8), () {
      if (!done.isCompleted) done.complete();
    });
    _scan = _ble.scanForDevices(
        withServices: [], scanMode: ScanMode.lowLatency).listen((d) {
      devices[d.id] = ObdDevice(
          d.id, d.name.isEmpty ? 'Unnamed BLE device' : d.name,
          simulated: false);
    }, onError: (Object error) {
      if (!done.isCompleted) done.completeError(error);
    });
    try {
      await done.future;
      if (generation != _generation) throw StateError('Discovery cancelled.');
      return devices.values.toList()
        ..sort((a, b) {
          final aObd = a.name.toUpperCase().contains('OBD') ? 0 : 1;
          final bObd = b.name.toUpperCase().contains('OBD') ? 0 : 1;
          return aObd != bObd ? aObd.compareTo(bObd) : a.name.compareTo(b.name);
        });
    } finally {
      timer.cancel();
      await _scan?.cancel();
      _scan = null;
      _scanning = null;
    }
  }

  @override
  Future<void> connect(ObdDevice device) async {
    if (device.simulated) {
      throw ArgumentError('A physical BLE device is required.');
    }
    await disconnect();
    connectionReport = '';
    profileName = '';
    final generation = _generation;
    await _ready();
    if (generation != _generation) throw StateError('Connection cancelled.');
    _state = AdapterState.connecting;
    _deviceId = device.id;
    final connected = Completer<void>();
    _connecting = connected;
    _connection = _ble
        .connectToDevice(
            id: device.id, connectionTimeout: const Duration(seconds: 15))
        .listen((update) {
      if (generation != _generation) return;
      if (update.connectionState == DeviceConnectionState.connected) {
        _state = AdapterState.connected;
        if (!connected.isCompleted) connected.complete();
      } else if (update.connectionState == DeviceConnectionState.disconnected) {
        _state = AdapterState.disconnected;
        if (!connected.isCompleted) {
          connected.completeError(StateError('Adapter disconnected.'));
        }
        unawaited(_session?.close());
      }
    }, onError: (Object error) {
      _state = AdapterState.disconnected;
      if (!connected.isCompleted) connected.completeError(error);
      unawaited(_session?.close());
    });
    try {
      await connected.future.timeout(const Duration(seconds: 18));
      await _ble
          .discoverAllServices(device.id)
          .timeout(const Duration(seconds: 15));
      final services = await _ble
          .getDiscoveredServices(device.id)
          .timeout(const Duration(seconds: 15));
      if (generation != _generation || state != AdapterState.connected) {
        throw StateError('Connection lost.');
      }
      channels = [
        for (final s in services)
          for (final c in s.characteristics)
            SerialChannel(s.id.toString(), c.id.toString(),
                write: c.isWritableWithResponse,
                writeWithoutResponse: c.isWritableWithoutResponse,
                notify: c.isNotifiable || c.isIndicatable)
      ];
      if (channels.map((c) => c.key).toSet().length != channels.length) {
        throw UnsupportedError(
            'Duplicate Bluetooth service identifiers need a dedicated adapter profile.');
      }
      connectionReport = channels
          .map((c) =>
              '${c.key} write=${c.write} writeWithoutResponse=${c.writeWithoutResponse} notify=${c.notify}')
          .join('\n');
      final profile = detectBleSerialProfile(channels);
      profileName = profile.name;
      configure(profile.tx, profile.rx);
      await _session!.identifyAdapter();
      if (generation != _generation || !ready) {
        throw StateError('Connection lost during adapter verification.');
      }
    } catch (_) {
      await disconnect();
      rethrow;
    } finally {
      _connecting = null;
    }
  }

  void configure(SerialChannel tx, SerialChannel rx) {
    if (state != AdapterState.connected || _session != null) {
      throw StateError('Connect again before configuring.');
    }
    if (!channels.contains(tx) ||
        !channels.contains(rx) ||
        tx.service != rx.service ||
        !(tx.write || tx.writeWithoutResponse) ||
        !rx.notify) {
      throw ArgumentError(
          'Select a writable and notifying characteristic from the documented serial service.');
    }
    _session = ElmSession(_BleLink(_ble, _deviceId!, tx, rx));
  }

  @override
  Future<ObdSnapshot> readStoredCodes() async {
    if (state != AdapterState.connected || _session == null) {
      throw StateError('Connect and configure the serial service first.');
    }
    final session = _session!;
    final ecuCodes = await session.readStoredCodes();
    if (state != AdapterState.connected) {
      throw StateError('Connection lost; results discarded.');
    }
    return ObdSnapshot(
        codes: ecuCodes.expand((e) => e.codes).toSet().toList(),
        codesByEcu: {for (final e in ecuCodes) e.ecu: e.codes},
        rawTranscript: List.unmodifiable(session.transcript),
        capturedAt: DateTime.now().toUtc(),
        simulated: false);
  }

  @override
  Future<TelemetrySample> readLiveData() {
    if (state != AdapterState.connected || _session == null) {
      throw StateError('Connect and configure the serial service first.');
    }
    final reading = _session!.readLiveData();
    _liveReading = reading;
    return reading.whenComplete(() {
      if (identical(_liveReading, reading)) _liveReading = null;
    });
  }

  @override
  Future<void> clearStoredCodes() async => throw UnsupportedError(
      'Real code clearing remains disabled pending hardware validation.');

  @override
  Future<void> disconnect() async {
    _generation++;
    _state = AdapterState.disconnected;
    final scanning = _scanning;
    if (scanning != null && !scanning.isCompleted) scanning.complete();
    final connecting = _connecting;
    if (connecting != null && !connecting.isCompleted) {
      connecting.completeError(StateError('Connection cancelled.'));
    }
    final scan = _scan;
    final session = _session;
    final connection = _connection;
    _scan = null;
    _session = null;
    _connection = null;
    _deviceId = null;
    channels = const [];
    await scan?.cancel();
    await session?.close();
    await connection?.cancel();
  }
}

class _BleLink implements ElmLink {
  _BleLink(this.ble, this.device, this.tx, this.rx);
  final FlutterReactiveBle ble;
  final String device;
  final SerialChannel tx, rx;
  QualifiedCharacteristic _qualified(SerialChannel c) =>
      QualifiedCharacteristic(
          serviceId: Uuid.parse(c.service),
          characteristicId: Uuid.parse(c.characteristic),
          deviceId: device);
  @override
  Stream<List<int>> get notifications =>
      ble.subscribeToCharacteristic(_qualified(rx));
  @override
  Future<void> write(List<int> bytes) => tx.write
      ? ble.writeCharacteristicWithResponse(_qualified(tx), value: bytes)
      : ble.writeCharacteristicWithoutResponse(_qualified(tx), value: bytes);
}
