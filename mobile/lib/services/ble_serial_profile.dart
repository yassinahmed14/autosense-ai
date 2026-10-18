class SerialChannel {
  const SerialChannel(this.service, this.characteristic,
      {required this.write,
      required this.writeWithoutResponse,
      required this.notify});
  final String service, characteristic;
  final bool write, writeWithoutResponse, notify;
  String get key => '$service/$characteristic';
}

class BleSerialProfile {
  const BleSerialProfile(this.name, this.tx, this.rx);
  final String name;
  final SerialChannel tx, rx;
}

String _uuid(String value) {
  final text = value.toLowerCase();
  return text.length == 4 ? '0000$text-0000-1000-8000-00805f9b34fb' : text;
}

/// Match documented UART layouts only, then require an ELM identity handshake.
BleSerialProfile detectBleSerialProfile(List<SerialChannel> channels) {
  if (channels
          .map((c) => '${_uuid(c.service)}/${_uuid(c.characteristic)}')
          .toSet()
          .length !=
      channels.length) {
    throw UnsupportedError(
        'Duplicate Bluetooth identifiers need a dedicated adapter profile.');
  }
  final matches = <BleSerialProfile>[];
  const layouts = [
    ('ELM UART', 'fff0', 'fff2', 'fff1'),
    ('HM-10 UART', 'ffe0', 'ffe1', 'ffe1'),
    (
      'Nordic UART',
      '6e400001-b5a3-f393-e0a9-e50e24dcca9e',
      '6e400002-b5a3-f393-e0a9-e50e24dcca9e',
      '6e400003-b5a3-f393-e0a9-e50e24dcca9e'
    ),
  ];
  for (final layout in layouts) {
    final tx = channels.where((c) =>
        _uuid(c.service) == _uuid(layout.$2) &&
        _uuid(c.characteristic) == _uuid(layout.$3) &&
        (c.write || c.writeWithoutResponse));
    final rx = channels.where((c) =>
        _uuid(c.service) == _uuid(layout.$2) &&
        _uuid(c.characteristic) == _uuid(layout.$4) &&
        c.notify);
    if (tx.length == 1 && rx.length == 1) {
      matches.add(BleSerialProfile(layout.$1, tx.single, rx.single));
    }
  }
  if (matches.length != 1) {
    throw UnsupportedError(matches.isEmpty
        ? 'This adapter uses a Bluetooth profile AutoSense cannot identify yet. Open troubleshooting and copy the connection report.'
        : 'This adapter exposes multiple serial profiles. A dedicated profile is needed; no connection was guessed.');
  }
  return matches.single;
}
