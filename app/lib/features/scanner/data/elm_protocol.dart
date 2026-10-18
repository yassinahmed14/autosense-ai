import 'dart:async';
import 'dart:convert';
import 'package:autosense_ai/features/dashboard/domain/telemetry_model.dart';

/// A connected serial characteristic pair. Tests inject a scripted link.
abstract interface class ElmLink {
  Stream<List<int>> get notifications;
  Future<void> write(List<int> bytes);
}

class EcuCodes {
  const EcuCodes(this.ecu, this.codes);
  final String ecu;
  final List<String> codes;
}

/// Strict subset: ELM headers on, spaces on, CAN ISO-TP frames only.
/// Unknown, negative, empty and incomplete replies always fail closed.
Map<String, List<int>> parseCanMessages(String reply,
    {required bool extended}) {
  final messages = <String, List<int>>{};
  final expected = <String, int>{};
  final sequences = <String, int>{};
  for (var line in reply.toUpperCase().split(RegExp(r'[\r\n>]+'))) {
    line = line.trim();
    if (line.isEmpty ||
        line == '03' ||
        RegExp(r'^01[0-9A-F]{2}$').hasMatch(line) ||
        line == 'SEARCHING...') {
      continue;
    }
    final parts = line.split(RegExp(r'\s+'));
    String ecu;
    if (extended) {
      if (parts.length < 6 ||
          parts.take(4).any((p) => !RegExp(r'^[0-9A-F]{2}$').hasMatch(p))) {
        throw const FormatException('Unsupported 29-bit CAN reply format.');
      }
      ecu = parts.take(4).join();
      parts.removeRange(0, 4);
      if (int.parse(ecu, radix: 16) > 0x1fffffff) {
        throw const FormatException('Invalid CAN identifier.');
      }
    } else {
      if (parts.length < 3 || !RegExp(r'^[0-9A-F]{3}$').hasMatch(parts.first)) {
        throw FormatException('No valid CAN code reply: $line');
      }
      ecu = parts.removeAt(0);
      if (int.parse(ecu, radix: 16) > 0x7ff) {
        throw const FormatException('Invalid CAN identifier.');
      }
    }
    if (parts.length > 8 ||
        parts.any((p) => !RegExp(r'^[0-9A-F]{2}$').hasMatch(p))) {
      throw const FormatException('Malformed CAN frame.');
    }
    final bytes = parts.map((p) => int.parse(p, radix: 16)).toList();
    final kind = bytes.first >> 4;
    if (kind == 0) {
      final count = bytes.first & 15;
      if (count < 1 ||
          count > 7 ||
          bytes.length < count + 1 ||
          messages.containsKey(ecu)) {
        throw const FormatException('Invalid or duplicate single frame.');
      }
      expected[ecu] = count;
      messages[ecu] = bytes.sublist(1, count + 1);
    } else if (kind == 1) {
      final count = ((bytes.first & 15) << 8) | bytes[1];
      if (bytes.length != 8 ||
          count <= 7 ||
          count > 512 ||
          messages.containsKey(ecu)) {
        throw const FormatException('Invalid first frame.');
      }
      expected[ecu] = count;
      sequences[ecu] = 1;
      messages[ecu] = bytes.sublist(2);
    } else if (kind == 2) {
      final data = messages[ecu];
      final count = expected[ecu];
      if (data == null ||
          count == null ||
          data.length >= count ||
          (bytes.first & 15) != sequences[ecu] ||
          bytes.length != 8) {
        throw const FormatException('Missing or out-of-order CAN frame.');
      }
      data.addAll(bytes.skip(1).take(count - data.length));
      sequences[ecu] = (sequences[ecu]! + 1) & 15;
    } else {
      throw const FormatException('Unsupported CAN frame type.');
    }
  }
  if (messages.isEmpty) {
    throw const FormatException('No ECU response; status unknown.');
  }
  for (final entry in messages.entries) {
    if (entry.value.length != expected[entry.key]) {
      throw const FormatException('Incomplete CAN message.');
    }
  }
  return messages;
}

List<EcuCodes> parseStoredCodes(String reply, {required bool extended}) {
  return parseCanMessages(reply, extended: extended).entries.map((entry) {
    final data = entry.value;
    if (data.first != 0x43 || data.length < 2) {
      throw const FormatException('Incomplete or negative Mode 03 response.');
    }
    final codes = <String>{};
    // CAN Mode 03 includes a DTC count after the response service byte.
    final codeEnd = 2 + data[1] * 2;
    if (codeEnd > data.length || data.skip(codeEnd).any((b) => b != 0)) {
      throw const FormatException('CAN DTC count does not match the payload.');
    }
    for (var i = 2; i < codeEnd; i += 2) {
      final value = (data[i] << 8) | data[i + 1];
      if (value == 0) {
        throw const FormatException('Zero DTC within the reported count.');
      }
      final system = 'PCBU'[data[i] >> 6];
      final number =
          (value & 0x3fff).toRadixString(16).padLeft(4, '0').toUpperCase();
      codes.add('$system$number');
    }
    return EcuCodes(entry.key, List.unmodifiable(codes));
  }).toList(growable: false);
}

class ElmSession {
  ElmSession(this.link, {this.timeout = const Duration(seconds: 20)}) {
    _subscription = link.notifications.listen(_receive,
        onError: (Object error) => _fail(error),
        onDone: () => _fail(StateError('Adapter disconnected.')));
  }
  final ElmLink link;
  final Duration timeout;
  late final StreamSubscription<List<int>> _subscription;
  Completer<String>? _pending;
  String _buffer = '';
  bool _closed = false;
  bool get usable => !_closed;
  bool get ecuReady => _initialized;
  String adapterIdentity = '';
  String protocol = '';
  bool _initialized = false;
  String? _liveEcu;
  int _pidMask = 0;
  bool get _extended => protocol.endsWith('7') || protocol.endsWith('9');
  final transcript = <String>[];
  static const _commands = {
    'ATI',
    'ATE0',
    'ATL0',
    'ATS1',
    'ATH1',
    'ATSP0',
    'ATCAF1',
    'ATCFC1',
    'ATD0',
    '0100',
    'ATDPN',
    '03',
    '010C',
    '010D',
    '0105',
    '0111',
  };

  void _fail(Object error) {
    _closed = true;
    final pending = _pending;
    if (pending != null && !pending.isCompleted) pending.completeError(error);
  }

  void _receive(List<int> bytes) {
    if (_pending == null || _pending!.isCompleted) return;
    if (bytes.any((b) => b > 127 || b < 0)) {
      _fail(const FormatException('Adapter did not return ELM ASCII.'));
      return;
    }
    _buffer += ascii.decode(bytes);
    if (_buffer.length > 16384) {
      _fail(const FormatException('Adapter response too large.'));
    } else if (_buffer.contains('>')) {
      _pending!.complete(_buffer.substring(0, _buffer.indexOf('>')));
    }
  }

  Future<String> command(String command,
      {bool allowUnsupported = false}) async {
    if (!_commands.contains(command)) {
      throw UnsupportedError('Command not permitted.');
    }
    if (_closed) throw StateError('Reconnect before sending another command.');
    if (_pending != null) throw StateError('A command is already in progress.');
    _buffer = '';
    final pending = Completer<String>();
    _pending = pending;
    // Attach the timeout listener before writing; notifications may be synchronous.
    final response = pending.future.timeout(command == '0100'
        ? (timeout < const Duration(seconds: 20)
            ? timeout
            : const Duration(seconds: 45))
        : timeout);
    var completeReply = false;
    try {
      unawaited(
          link.write(ascii.encode('$command\r')).catchError((Object error) {
        _fail(error);
      }));
      final raw = await response;
      completeReply = true;
      transcript.add('$command\n$raw>');
      if (transcript.length > 100) transcript.removeAt(0);
      final lines = raw
          .toUpperCase()
          .split(RegExp(r'[\r\n]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s != command);
      final cleaned = lines.join('\n');
      if (allowUnsupported && cleaned == '?') return cleaned;
      if (cleaned.contains('?') ||
          RegExp(r'ERROR|UNABLE|STOPPED|NO DATA|BUFFER FULL|BUS INIT')
              .hasMatch(cleaned)) {
        throw FormatException('Adapter could not complete $command: $cleaned');
      }
      return cleaned;
    } catch (error) {
      // A prompt-terminated NO DATA / '?' reply leaves the serial link in sync.
      // Transport failures/timeouts poison it so late bytes cannot satisfy retry.
      if (!completeReply) _closed = true;
      if (!completeReply) {
        transcript.add('$command\nINCOMPLETE: $_buffer\n$error');
        if (transcript.length > 100) transcript.removeAt(0);
      }
      rethrow;
    } finally {
      _pending = null;
    }
  }

  Future<String> identifyAdapter() async {
    if (adapterIdentity.isNotEmpty) return adapterIdentity;
    final identity = await command('ATI');
    if (!RegExp(r'\b(?:ELM327|STN\d+|OBDLINK)\b', caseSensitive: false)
        .hasMatch(identity)) {
      throw const FormatException(
          'The Bluetooth device did not identify as an ELM-compatible scanner.');
    }
    adapterIdentity = identity;
    return identity;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    await identifyAdapter();
    for (final setting in [
      'ATE0',
      'ATL0',
      'ATS1',
      'ATH1',
      'ATSP0',
      'ATCAF1',
      'ATCFC1'
    ]) {
      if (!_acknowledged(await command(setting))) {
        throw FormatException('$setting was not acknowledged.');
      }
    }
    // Older ELM-compatible firmware may omit D0 (DLC display defaults off).
    // Continue only for an explicit '?' and still validate every CAN frame.
    final dlc = await command('ATD0', allowUnsupported: true);
    if (!_acknowledged(dlc) && dlc != '?') {
      throw const FormatException('ATD0 was not acknowledged.');
    }
    final supported =
        await command('0100'); // Wake the ECU and resolve auto protocol.
    if (!RegExp(r'\b41 00\b').hasMatch(supported)) {
      throw const FormatException('No valid ECU initialization response.');
    }
    protocol = await command('ATDPN');
    if (!RegExp(r'^A?[6789]$').hasMatch(protocol)) {
      throw UnsupportedError(
          'This experimental reader supports ISO 15765-4 CAN only (ELM protocols 6–9).');
    }
    final messages = parseCanMessages(supported, extended: _extended);
    for (final entry in messages.entries) {
      final bytes = entry.value;
      if (bytes.length != 6 || bytes[0] != 0x41 || bytes[1] != 0) continue;
      final mask =
          (bytes[2] << 24) | (bytes[3] << 16) | (bytes[4] << 8) | bytes[5];
      if ((mask & (1 << 20)) != 0 && (mask & (1 << 19)) != 0) {
        _liveEcu = entry.key;
        _pidMask = mask;
        break;
      }
    }
    _initialized = true;
  }

  // Some adapters include a search status before the final acknowledgement.
  // Require exactly one OK; arbitrary text or repeated acknowledgements fail.
  static bool _acknowledged(String reply) =>
      RegExp(r'^(?:SEARCHING\.\.\.\n)?OK$').hasMatch(reply);

  Future<List<EcuCodes>> readStoredCodes() async {
    await initialize();
    final reply = await command('03');
    return parseStoredCodes(reply, extended: _extended);
  }

  Future<List<int>> _pid(int pid, int length) async {
    final hex = pid.toRadixString(16).padLeft(2, '0').toUpperCase();
    final messages =
        parseCanMessages(await command('01$hex'), extended: _extended);
    final data = messages[_liveEcu];
    if (data == null ||
        data.length != length + 2 ||
        data[0] != 0x41 ||
        data[1] != pid) {
      throw const FormatException(
          'Missing or malformed PID response from selected ECU.');
    }
    return data.sublist(2);
  }

  Future<TelemetrySample> readLiveData() async {
    await initialize();
    if (_liveEcu == null) {
      throw UnsupportedError(
          'No single responding ECU advertises both speed and RPM.');
    }
    final speed = (await _pid(0x0d, 1))[0].toDouble();
    final speedAt = DateTime.now().toUtc();
    final rpmBytes = await _pid(0x0c, 2);
    final rpmAt = DateTime.now().toUtc();
    final rpm = (rpmBytes[0] * 256 + rpmBytes[1]) / 4;
    double? coolant, throttle;
    if ((_pidMask & (1 << 27)) != 0) coolant = (await _pid(5, 1))[0] - 40.0;
    if ((_pidMask & (1 << 15)) != 0) {
      throttle = (await _pid(0x11, 1))[0] * 100 / 255;
    }
    return TelemetrySample(
        speedKph: speed,
        rpm: rpm,
        speedAt: speedAt,
        rpmAt: rpmAt,
        coolantC: coolant,
        throttlePercent: throttle,
        simulated: false);
  }

  Future<void> close() async {
    _fail(StateError('Session closed.'));
    await _subscription.cancel();
  }
}
