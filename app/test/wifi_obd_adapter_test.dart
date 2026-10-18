import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:autosense_ai/services/wifi_obd_adapter.dart';
import 'package:autosense_ai/services/obd_adapter.dart';

void main() {
  test('loopback TCP ELM fixture exercises native Wi-Fi connection and read',
      () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final sockets = <Socket>[];
    final received = <String>[];
    final subscription = server.listen((socket) {
      sockets.add(socket);
      var buffer = '';
      socket.listen((bytes) {
        buffer += ascii.decode(bytes);
        while (buffer.contains('\r')) {
          final index = buffer.indexOf('\r');
          final cmd = buffer.substring(0, index);
          buffer = buffer.substring(index + 1);
          received.add(cmd);
          final reply = switch (cmd) {
            'ATI' => 'ELM327 loopback fixture\r>',
            '0100' => '7E8 06 41 00 BE 3E B8 13\r>',
            'ATDPN' => 'A6\r>',
            '03' => '7E8 04 43 01 03 00 00 00 00\r>',
            _ => 'OK\r>',
          };
          socket.add(ascii.encode(reply));
        }
      });
    });
    final adapter = WifiObdAdapter(host: '127.0.0.1', port: server.port);
    addTearDown(() async {
      await adapter.disconnect();
      for (final s in sockets) {
        s.destroy();
      }
      await subscription.cancel();
      await server.close();
    });
    await adapter.connect((await adapter.discover()).single);
    expect(adapter.state, AdapterState.connected);
    final result = await adapter.readStoredCodes();
    expect(result.codes, ['P0300']);
    expect(result.codesByEcu['7E8'], ['P0300']);
    expect(result.simulated,
        isFalse); // Physical transport provenance, fixture server.
    await expectLater(adapter.clearStoredCodes(), throwsUnsupportedError);
    expect(received, isNot(contains('04')));
    await adapter.disconnect();
    await expectLater(adapter.readLiveData(), throwsStateError);
  });
  test('invalid TCP endpoint fails explicitly', () async {
    await expectLater(
        WifiObdAdapter(host: '', port: 0).discover(), throwsArgumentError);
  });
}
