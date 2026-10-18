import 'network_elm_link.dart';

Future<NetworkElmLink> openWifiLink(String host, int port) async =>
    throw UnsupportedError(
        'Wi-Fi TCP adapters require a native app; browser sockets are unavailable.');
