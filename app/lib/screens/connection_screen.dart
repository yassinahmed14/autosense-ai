import 'package:flutter/material.dart';
import '../models/diagnostic.dart';
import '../services/api_client.dart';
import '../services/mock_obd_adapter.dart';
import 'dashboard_screen.dart';
import 'ble_scan_screen.dart';
import 'wifi_screen.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen(
      {super.key, required this.api, required this.onResult});
  final ApiClient api;
  final ValueChanged<DiagnosticResult> onResult;
  @override
  Widget build(BuildContext context) {
    void open(Widget screen) => Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
    Widget option(IconData icon, String title, String description,
            VoidCallback tap) =>
        Card(
            child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: Icon(icon, color: const Color(0xff4ce0b3), size: 30),
                title: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(description),
                trailing: const Icon(Icons.arrow_forward),
                onTap: tap));
    return Scaffold(
        appBar: AppBar(title: const Text('Choose your connection')),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(padding: const EdgeInsets.all(20), children: [
                  const Text('Your car. Your dashboard.',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'Choose how your scanner communicates. Connector shape, vehicle protocol and phone connection are separate compatibility requirements.'),
                  const SizedBox(height: 18),
                  option(
                      Icons.play_circle_outline,
                      'Try live demo',
                      'Animated RPM, speed, temperature and a simulated 10-second performance run.',
                      () => open(DashboardScreen(
                          adapter: MockObdAdapter(), simulated: true))),
                  option(
                      Icons.bluetooth,
                      'Bluetooth LE',
                      'Select your OBD adapter, connect automatically, then choose live data or diagnostics.',
                      () => open(BleScanScreen(api: api, onResult: onResult))),
                  option(
                      Icons.wifi,
                      'Wi-Fi',
                      'Experimental ELM ASCII over TCP • join the adapter network, then enter its host and port.',
                      () => open(WifiScreen(api: api, onResult: onResult))),
                  const SizedBox(height: 18),
                  const Text('Other scanner types',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text(
                      'The app has a driver interface for additional hardware. Bluetooth Classic, USB, OBD-I and proprietary scanners need their own documented driver and validation. They are not currently supported. ELM-compatible CAN devices are the current experimental subset; no universal compatibility is claimed.'),
                ]))));
  }
}
