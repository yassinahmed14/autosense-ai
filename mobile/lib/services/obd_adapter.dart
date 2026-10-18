export 'ble_obd_adapter.dart';
import '../models/telemetry.dart';

/// Shared boundary for simulated and experimental physical transports.
enum AdapterState { disconnected, connecting, connected }

class ObdDevice {
  const ObdDevice(this.id, this.name, {required this.simulated});
  final String id, name;
  final bool simulated;
}

class ObdSnapshot {
  const ObdSnapshot(
      {required this.codes,
      required this.capturedAt,
      required this.simulated,
      this.vehicle,
      this.codesByEcu = const {},
      this.rawTranscript = const []});
  final List<String> codes;
  final DateTime capturedAt;
  final bool simulated;

  /// Null means identification is unavailable; never infer a car from its DTCs.
  final VehicleIdentity? vehicle;
  final Map<String, List<String>> codesByEcu;
  final List<String> rawTranscript;
}

class VehicleIdentity {
  const VehicleIdentity(
      {required this.make,
      required this.model,
      required this.year,
      required this.simulated});
  final String make, model;
  final int year;
  final bool simulated;
}

abstract interface class ObdAdapter {
  AdapterState get state;
  Future<List<ObdDevice>> discover();
  Future<void> connect(ObdDevice device);
  Future<ObdSnapshot> readStoredCodes();
  Future<void> clearStoredCodes();
  Future<void> disconnect();
}

/// Implement a separate driver for each documented scanner protocol/transport.
abstract interface class LiveObdAdapter implements ObdAdapter {
  Future<TelemetrySample> readLiveData();
}
