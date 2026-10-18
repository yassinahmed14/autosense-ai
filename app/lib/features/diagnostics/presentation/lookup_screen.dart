import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/core/theme/app_colors.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/features/diagnostics/data/offline_diagnostic_engine.dart';
import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/section_header.dart';
import 'package:autosense_ai/shared/widgets/status_banner.dart';
import 'package:flutter/material.dart';

/// Looks up generic SAE J2012 DTC definitions from the API or the built-in
/// 56-code offline catalog, with interactive system filter chips.
class LookupScreen extends StatefulWidget {
  /// Creates the DTC library screen.
  const LookupScreen({super.key, required this.api});

  /// Diagnostic API client.
  final ApiClient api;

  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> {
  final _code = TextEditingController();
  DtcLookup? _result;
  OfflineDtcRecord? _offlineDetail;
  String? _error;
  bool _busy = false;
  String _systemFilter = 'ALL';

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _lookup([String? overrideCode]) async {
    if (overrideCode != null) {
      _code.text = overrideCode;
    }
    setState(() {
      _error = null;
      _result = null;
      _offlineDetail = null;
    });
    try {
      final codes = parseCodes(_code.text);
      if (codes.length != 1) {
        throw const FormatException('Enter exactly one DTC.');
      }
      final single = codes.single;
      setState(() => _busy = true);
      final result = await widget.api.lookup(single);
      if (mounted) {
        setState(() {
          _result = result;
          _offlineDetail = OfflineDiagnosticEngine.catalog[single];
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredCatalog = OfflineDiagnosticEngine.filterCatalog(
      system: _systemFilter,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('DTC library')),
      body: PageListView(children: [
        const StatusBanner(
            '56 built-in generic SAE J2012 definitions (Powertrain, Chassis/ABS, Body/SRS, Network) with instant offline access. OEM details may differ. A code alone does not identify a failed part.'),
        const SizedBox(height: AppSpacing.lg),
        TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _busy ? null : _lookup(),
            decoration: const InputDecoration(
                labelText: 'DTC',
                hintText: 'P0420',
                prefixIcon: Icon(Icons.search))),
        const SizedBox(height: AppSpacing.md),
        PrimaryActionButton(
            onPressed: _busy ? null : () => _lookup(),
            label: _busy ? 'Looking up…' : 'Look up code'),
        if (_busy) ...[
          const SizedBox(height: AppSpacing.md),
          const LinearProgressIndicator(),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          StatusBanner(_error!, tone: BannerTone.error),
        ],
        if (_result != null) ...[
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${_result!.code}: ${_result!.title ?? 'Not in catalog'}',
                      style: theme.textTheme.titleLarge),
                  if (_result!.explanation != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(_result!.explanation!),
                  ],
                  if (_offlineDetail != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text('Common possibilities (unconfirmed):',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    for (final cause in _offlineDetail!.causes)
                      Text('• $cause', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Recommended technician checks:',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    for (final check in _offlineDetail!.checks)
                      Text('• $check', style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(_result!.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        const SectionHeader(
          'Browse offline catalog',
          eyebrow: 'INSTANT ON-DEVICE REFERENCE',
          subtitle:
              'Tap any generic code below to inspect causes and technician checks immediately—even without internet.',
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final entry in const [
              ('ALL', 'All systems (56)'),
              ('P', 'Powertrain (P)'),
              ('C', 'Chassis / ABS (C)'),
              ('B', 'Body / SRS (B)'),
              ('U', 'Network / CAN (U)'),
            ])
              FilterChip(
                label: Text(entry.$2),
                selected: _systemFilter == entry.$1,
                onSelected: (_) => setState(() => _systemFilter = entry.$1),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (final item in filteredCatalog.take(12))
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.small,
                ),
                child: Text(
                  item.code,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.carbon,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(item.title),
              subtitle: Text(item.systemLabel),
              trailing: const Icon(Icons.bolt_outlined),
              onTap: _busy ? null : () => _lookup(item.code),
            ),
          ),
      ]),
    );
  }
}
