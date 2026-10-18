import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/section_header.dart';
import 'package:autosense_ai/shared/widgets/status_banner.dart';
import 'package:flutter/material.dart';

/// Structured diagnostic guidance: urgency, reasons, codes, possible causes,
/// next steps and provenance.
class ResultScreen extends StatelessWidget {
  /// Creates the result screen for [result].
  const ResultScreen({super.key, required this.result});

  /// Guidance returned by the diagnostic API.
  final DiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic guidance')),
      body: PageListView(children: [
        if (result.simulated)
          const StatusBanner('SIMULATED DATA • Not a vehicle scan',
              tone: BannerTone.simulated, emphasize: true),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.urgency.replaceAll('_', ' ').toUpperCase(),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: theme.colorScheme.primary)),
                const SizedBox(height: AppSpacing.sm),
                Text(result.summary, style: theme.textTheme.bodyLarge),
                for (final reason in result.reasons)
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline),
                      title: Text(reason)),
              ],
            ),
          ),
        ),
        StatusBanner(result.safetyMessage,
            tone: BannerTone.warning, icon: Icons.health_and_safety_outlined),
        const SizedBox(height: AppSpacing.md),
        const SectionHeader('Reported codes'),
        if (result.dtcs.isEmpty)
          const Text('No codes supplied. This does not rule out a fault.'),
        for (final dtc in result.dtcs)
          Card(
            child: ListTile(
                title: Text('${dtc.code} • ${dtc.title ?? 'Unknown code'}'),
                subtitle: Text('${dtc.explanation ?? ''}\n${dtc.message}')),
          ),
        const SizedBox(height: AppSpacing.md),
        const SectionHeader('Possible causes • unconfirmed'),
        if (result.causes.isEmpty)
          const Text(
              'Insufficient catalog evidence. Ask for professional review.'),
        for (final cause in result.causes)
          Card(
            child: ListTile(
                title: Text(cause.title),
                subtitle: Text(
                    '${cause.certainty} • Evidence: ${cause.evidence.join(', ')}')),
          ),
        const SizedBox(height: AppSpacing.md),
        const SectionHeader('Next steps'),
        for (final step in result.nextSteps)
          ListTile(leading: const Icon(Icons.checklist), title: Text(step)),
        const SizedBox(height: AppSpacing.sm),
        ExpansionTile(
            title: const Text('Limitations and provenance'),
            children: [
              for (final limitation in result.limitations)
                ListTile(title: Text(limitation)),
              ListTile(
                  title: Text(
                      'Result ${result.id}\n${result.createdAt.toLocal()}')),
            ]),
      ]),
    );
  }
}
