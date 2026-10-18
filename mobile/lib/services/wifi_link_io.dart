import 'dart:io';
import 'network_elm_link.dart';

Future<NetworkElmLink> openWifiLink(String host, int port) async {
  final socket =
      await Socket.connect(host, port, timeout: const Duration(seconds: 10));
  socket.setOption(SocketOption.tcpNoDelay, true);
  return _SocketLink(socket);
}

class _SocketLink implements NetworkElmLink {
  _SocketLink(this.socket);
  final Socket socket;
  @override
  Stream<List<int>> get notifications => socket;
  @override
  Future<void> write(List<int> bytes) async {
    socket.add(bytes);
    await socket.flush();
  }

  @override
  Future<void> close() async => socket.destroy();
}
