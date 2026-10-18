import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// Read-only configuration summary (API address and starter capabilities).
class SettingsScreen extends StatelessWidget {
  /// Creates the configuration screen for the given [apiBaseUrl].
  const SettingsScreen({super.key, required this.apiBaseUrl});

  /// Active diagnostic API base URL.
  final String apiBaseUrl;

  /// Capability summary shown under the API address.
  static const details = 'Change API_BASE_URL at launch; see README.\n\n'
      'Diagnostic engine: transparent demo rules\nAdapter: demo + experimental BLE / Wi-Fi ELM reader\n'
      'History: memory only, cleared when the app restarts\n'
      'Supabase: schema supplied, connection not enabled\n\n'
      'No account, VIN, analytics, or cloud history in this starter.';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Configuration')),
        body: PageListView(children: [
          const SectionHeader('Connection'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dns_outlined),
              title: Text('API: $apiBaseUrl'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader('About this build'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: SelectionArea(child: Text(details)),
            ),
          ),
        ]),
      );
}
