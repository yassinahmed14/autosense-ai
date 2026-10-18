import 'package:autosense_ai/features/dashboard/domain/telemetry_model.dart';
import 'package:autosense_ai/features/scanner/data/elm_protocol.dart';
import 'package:autosense_ai/features/scanner/data/network_elm_link.dart';
import 'package:autosense_ai/features/scanner/data/wifi_link_stub.dart'
    if (dart.library.io) 'package:autosense_ai/features/scanner/data/wifi_link_io.dart'
    as network;
import 'package:autosense_ai/features/scanner/domain/obd_adapter.dart';
import 'package:flutter/foundation.dart';

/// ELM ASCII over vendor-documented TCP. Not UDP, HTTP, or a universal OBD driver.
class WifiObdAdapter implements LiveObdAdapter {
  WifiObdAdapter({required this.host, required this.port});
  final String host;
  final int port;
  NetworkElmLink? _link;
  ElmSession? _session;
  int _generation = 0;
  AdapterState _state = AdapterState.disconnected;
  static bool get supported => !kIsWeb;
  @override
  AdapterState get state => _state;
  @override
  Future<List<ObdDevice>> discover() async {
    if (!supported) throw UnsupportedError('Wi-Fi TCP requires a native app.');
    if (host.trim().isEmpty || port < 1 || port > 65535) {
      throw ArgumentError(
          'Enter the host and TCP port from your adapter manual.');
    }
    return [
      ObdDevice('$host:$port', 'Wi-Fi adapter • $host:$port', simulated: false)
    ];
  }

  @override
  Future<void> connect(ObdDevice device) async {
    final expected = (await discover()).single;
    if (device.id != expected.id || device.simulated) {
      throw ArgumentError('Unexpected Wi-Fi endpoint.');
    }
    await disconnect();
    final generation = _generation;
    _state = AdapterState.connecting;
    try {
      final link = await network.openWifiLink(host.trim(), port);
      if (generation != _generation) {
        await link.close();
        throw StateError('Wi-Fi connection cancelled.');
      }
      _link = link;
      _session = ElmSession(link);
      _state = AdapterState.connected;
    } catch (_) {
      if (generation == _generation) await disconnect();
      rethrow;
    }
  }

  ElmSession get _connected {
    if (state != AdapterState.connected || _session == null) {
      throw StateError('Connect to your Wi-Fi adapter first.');
    }
    return _session!;
  }

  @override
  Future<ObdSnapshot> readStoredCodes() async {
    final session = _connected;
    try {
      final codes = await session.readStoredCodes();
      return ObdSnapshot(
          codes: codes.expand((e) => e.codes).toSet().toList(),
          capturedAt: DateTime.now().toUtc(),
          simulated: false,
          codesByEcu: {for (final e in codes) e.ecu: e.codes},
          rawTranscript: List.unmodifiable(session.transcript));
    } catch (_) {
      await disconnect();
      rethrow;
    }
  }

  @override
  Future<TelemetrySample> readLiveData() async {
    try {
      return await _connected.readLiveData();
    } catch (_) {
      await disconnect();
      rethrow;
    }
  }

  @override
  Future<void> clearStoredCodes() async => throw UnsupportedError(
      'Physical code clearing is disabled pending validation.');
  @override
  Future<void> disconnect() async {
    _generation++;
    _state = AdapterState.disconnected;
    final session = _session;
    final link = _link;
    _session = null;
    _link = null;
    await session?.close();
    await link?.close();
  }
}
