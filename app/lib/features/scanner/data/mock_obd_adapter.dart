import 'dart:math' as math;

import 'package:autosense_ai/features/dashboard/domain/telemetry_model.dart';
import 'package:autosense_ai/features/scanner/domain/obd_adapter.dart';

class MockObdAdapter implements LiveObdAdapter {
  MockObdAdapter(
      {this.delay = const Duration(milliseconds: 500),
      this.failConnection = false,
      List<String> codes = const ['P0300', 'P0171'],
      this.vehicle = const VehicleIdentity(
          make: 'Toyota', model: 'Corolla', year: 2020, simulated: true)})
      : _codes = List.of(codes);
  final Duration delay;
  final bool failConnection;
  final List<String> _codes;
  final VehicleIdentity? vehicle;
  AdapterState _state = AdapterState.disconnected;
  int _generation = 0;
  final _clock = Stopwatch();
  void beginDemoRun() => _clock
    ..reset()
    ..start();
  @override
  AdapterState get state => _state;
  @override
  Future<List<ObdDevice>> discover() async {
    await Future<void>.delayed(delay);
    return const [
      ObdDevice('mock-001', 'AutoSense demo adapter', simulated: true)
    ];
  }

  @override
  Future<void> connect(ObdDevice device) async {
    if (device.id != 'mock-001' || !device.simulated) {
      throw StateError('Mock adapter accepts only its simulated device.');
    }
    if (_state != AdapterState.disconnected) {
      throw StateError('Disconnect before starting another connection.');
    }
    final generation = ++_generation;
    _state = AdapterState.connecting;
    await Future<void>.delayed(delay);
    if (generation != _generation) throw StateError('Connection cancelled.');
    _state =
        failConnection ? AdapterState.disconnected : AdapterState.connected;
    if (failConnection) throw StateError('Simulated connection failure.');
    _clock
      ..reset()
      ..start();
  }

  @override
  Future<ObdSnapshot> readStoredCodes() async {
    if (_state != AdapterState.connected) throw StateError('Connect first.');
    final generation = _generation;
    await Future<void>.delayed(delay);
    if (_state != AdapterState.connected || generation != _generation) {
      throw StateError('Adapter disconnected during read.');
    }
    return ObdSnapshot(
        codes: List.unmodifiable(_codes),
        capturedAt: DateTime.now().toUtc(),
        simulated: true,
        vehicle: vehicle);
  }

  @override
  Future<TelemetrySample> readLiveData() async {
    if (_state != AdapterState.connected) throw StateError('Connect first.');
    final generation = _generation;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (generation != _generation || state != AdapterState.connected) {
      throw StateError('Demo disconnected.');
    }
    final seconds = _clock.elapsedMilliseconds / 1000;
    final speed = 20 + (seconds % 18) * 4;
    final now = DateTime.now().toUtc();
    return TelemetrySample(
        speedKph: speed,
        rpm: speed * 55,
        speedAt: now,
        rpmAt: now,
        coolantC: 88 + math.sin(seconds),
        throttlePercent: 85 + math.sin(seconds) * 5,
        simulated: true);
  }

  @override
  Future<void> clearStoredCodes() async {
    if (_state != AdapterState.connected) throw StateError('Connect first.');
    final generation = _generation;
    await Future<void>.delayed(delay);
    if (_state != AdapterState.connected || generation != _generation) {
      throw StateError('Adapter disconnected before clearing.');
    }
    _codes.clear();
  }

  @override
  Future<void> disconnect() async {
    ++_generation;
    _state = AdapterState.disconnected;
    _clock.stop();
  }
}
