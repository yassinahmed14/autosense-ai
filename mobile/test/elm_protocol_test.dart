import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:autosense_ai/services/elm_protocol.dart';

/// Synthetic frames exercising the protocol subset, never hardware evidence.
class ScriptedLink implements ElmLink {
  final controller = StreamController<List<int>>(sync: true);
  final commands = <String>[];
  String protocol = 'A6';
  String codes = '7E8 06 43 02 03 00 01 71 00\r>';
  String? errorCommand;
  bool silent = false;
  bool unsupportedDlc = false;
  String flowControlReply = 'OK';
  @override
  Stream<List<int>> get notifications => controller.stream;
  String identity = 'ELM327 v1.5';
  @override
  Future<void> write(List<int> bytes) async {
    final command = ascii.decode(bytes).trim();
    commands.add(command);
    if (silent) return;
    final reply = command == errorCommand
        ? 'NO DATA\r>'
        : switch (command) {
            'ATI' => 'ATI\r$identity\r>',
            'ATD0' => unsupportedDlc ? '?\r>' : 'OK\r>',
            'ATCFC1' => '$flowControlReply\r>',
            '0100' => 'SEARCHING...\r7E8 06 41 00 BE 3E B8 13\r>',
            'ATDPN' => '$protocol\r>',
            '03' => codes,
            '010D' => '7E8 03 41 0D 48\r>',
            '010C' => '7E8 04 41 0C 2E E0\r>',
            '0105' => '7E8 03 41 05 82\r>',
            '0111' => '7E8 03 41 11 FF\r>',
            _ => 'OK\r>',
          };
    // Deliberately fragment notifications across arbitrary byte boundaries.
    for (var i = 0; i < reply.length; i += 3) {
      controller.add(ascii.encode(
          reply.substring(i, i + 3 > reply.length ? reply.length : i + 3)));
    }
  }
}

void main() {
  test('reported adapter SEARCHING then OK proceeds to ECU request', () async {
    final link = ScriptedLink()..flowControlReply = 'SEARCHING...\rOK';
    final session = ElmSession(link);
    addTearDown(() async {
      await session.close();
      await link.controller.close();
    });
    expect((await session.readLiveData()).rpm, 3000);
    expect(
        link.commands, containsAllInOrder(['ATCFC1', 'ATD0', '0100', 'ATDPN']));
    expect(session.ecuReady, isTrue);
  });
  for (final reply in ['SEARCHING...', 'JUNK\rOK', 'OK\rOK', 'NO DATA\rOK']) {
    test('setup rejects non-acknowledgement $reply', () async {
      final link = ScriptedLink()..flowControlReply = reply;
      final session = ElmSession(link);
      addTearDown(() async {
        await session.close();
        await link.controller.close();
      });
      await expectLater(session.readStoredCodes(), throwsFormatException);
      expect(link.commands, isNot(contains('0100')));
      expect(session.ecuReady, isFalse);
    });
  }
  test('explicit unsupported DLC display setting does not abort ECU setup',
      () async {
    final link = ScriptedLink()..unsupportedDlc = true;
    final session = ElmSession(link);
    addTearDown(() async {
      await session.close();
      await link.controller.close();
    });
    expect((await session.readLiveData()).rpm, 3000);
    expect(session.ecuReady, isTrue);
  });
  test(
      'complete NO DATA preserves synchronization and permits ignition-on retry',
      () async {
    final link = ScriptedLink()..errorCommand = '0100';
    final session = ElmSession(link);
    addTearDown(() async {
      await session.close();
      await link.controller.close();
    });
    await expectLater(session.readStoredCodes(), throwsFormatException);
    expect(session.usable, isTrue);
    expect(session.ecuReady, isFalse);
    link.errorCommand = null;
    expect((await session.readStoredCodes()).single.codes, ['P0300', 'P0171']);
  });
  test('adapter identity handshake is read-only and cached before ECU reads',
      () async {
    final link = ScriptedLink();
    final session = ElmSession(link);
    addTearDown(() async {
      await session.close();
      await link.controller.close();
    });
    expect(await session.identifyAdapter(), 'ELM327 V1.5');
    expect(link.commands, ['ATI']);
    await session.readStoredCodes();
    expect(link.commands.where((command) => command == 'ATI').length, 1);
    expect(link.commands, isNot(contains('04')));
  });
  test('UART notifications from a non-ELM device do not establish readiness',
      () async {
    final link = ScriptedLink()..identity = 'Battery sensor';
    final session = ElmSession(link);
    addTearDown(() async {
      await session.close();
      await link.controller.close();
    });
    await expectLater(session.identifyAdapter(), throwsFormatException);
    expect(session.adapterIdentity, isEmpty);
    expect(link.commands, ['ATI']);
  });
  test('live PIDs decode from the same ECU with timestamped speed/RPM',
      () async {
    final link = ScriptedLink();
    final session = ElmSession(link);
    addTearDown(() async {
      await session.close();
      await link.controller.close();
    });
    final sample = await session.readLiveData();
    expect(sample.speedKph, 72);
    expect(sample.rpm, 3000);
    expect(sample.coolantC, 90);
    expect(sample.throttlePercent, 100);
    expect(sample.simulated, isFalse);
    expect(sample.rpmAt.isBefore(sample.speedAt), isFalse);
  });
  test('CAN count, ECU provenance and all four DTC systems', () {
    final result = parseStoredCodes(
        '03\r7E8 06 43 02 03 00 01 71 00\r7E9 06 43 02 41 23 C1 00 00\r7EA 04 43 01 81 23 00 00 00>',
        extended: false);
    expect(result.map((e) => e.ecu), ['7E8', '7E9', '7EA']);
    expect(result[0].codes, ['P0300', 'P0171']);
    expect(result[1].codes, ['C0123', 'U0100']);
    expect(result[2].codes, ['B0123']);
  });
  test('29-bit header and affirmative zero-code response', () {
    final result = parseStoredCodes('18 DA F1 10 02 43 00 00 00 00 00 00>',
        extended: true);
    expect(result.single.ecu, '18DAF110');
    expect(result.single.codes, isEmpty);
  });
  test('interleaved multi-ECU ISO-TP frames preserve distinct messages', () {
    final result = parseStoredCodes(
        '7E8 10 0A 43 04 03 00 01 71\r7E9 02 43 00 00 00 00 00 00\r7E8 21 04 20 C1 00 00 00 00>',
        extended: false);
    expect(result.first.codes, ['P0300', 'P0171', 'P0420', 'U0100']);
    expect(result.last.codes, isEmpty);
  });
  for (final reply in [
    '', 'NO DATA', 'CAN ERROR', '7E8 03 7F 03 11',
    '7E8 04 43 02 03 00', // count exceeds payload
    '7E8 04 43 00 03 00', // unreported nonzero bytes
    '7E8 04 43 01 00 00', // zero DTC inside count
    '7E8 10 0A 43 04 03 00 01 71', // missing continuation
    '7E8 10 0A 43 04 03 00 01 71\r7E8 22 04 20 C1 00 00 00 00',
    '7E8 02 43 00\r7E8 02 43 00', // duplicate
    '0: 43 01 03 00', '7E8 04 43 GG 03 00',
  ]) {
    test('reject ambiguous/error reply: $reply', () {
      expect(() => parseStoredCodes(reply, extended: false),
          throwsFormatException);
    });
  }
  test('fragmented ELM session initializes, reads and never sends Mode 04',
      () async {
    final link = ScriptedLink();
    final session = ElmSession(link);
    addTearDown(() async {
      await session.close();
      await link.controller.close();
    });
    final result = await session.readStoredCodes();
    expect(result.single.codes, ['P0300', 'P0171']);
    expect(link.commands, [
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
      '03'
    ]);
    expect(session.transcript, hasLength(12));
    await expectLater(session.command('04'), throwsUnsupportedError);
    expect(link.commands, isNot(contains('04')));
  });
  test('non-CAN protocols fail before requesting codes', () async {
    final link = ScriptedLink()..protocol = 'A3';
    final session = ElmSession(link);
    addTearDown(() async {
      await session.close();
      await link.controller.close();
    });
    await expectLater(session.readStoredCodes(), throwsUnsupportedError);
    expect(link.commands, isNot(contains('03')));
  });
  test('NO DATA is an error, never an empty code list', () async {
    final link = ScriptedLink()..errorCommand = '03';
    final session = ElmSession(link);
    addTearDown(() async {
      await session.close();
      await link.controller.close();
    });
    await expectLater(session.readStoredCodes(), throwsFormatException);
  });
  test('timeout poisons session; late response cannot satisfy next command',
      () async {
    final link = ScriptedLink()..silent = true;
    final session = ElmSession(link, timeout: const Duration(milliseconds: 5));
    addTearDown(() async {
      await session.close();
      await link.controller.close();
    });
    await expectLater(session.command('ATI'), throwsA(isA<TimeoutException>()));
    link.controller.add(ascii.encode('ELM327\r>'));
    await expectLater(session.command('ATI'), throwsStateError);
  });
  test('disconnect and concurrent commands fail explicitly', () async {
    final link = ScriptedLink()..silent = true;
    final session = ElmSession(link);
    addTearDown(link.controller.close);
    final first = session.command('ATI');
    final assertion = expectLater(first, throwsStateError);
    await expectLater(session.command('03'), throwsStateError);
    await session.close();
    await assertion;
  });
}
