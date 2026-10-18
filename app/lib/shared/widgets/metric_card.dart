import 'package:autosense_ai/core/theme/app_colors.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Compact live-reading tile: icon chip, large tabular Saira value, label • unit.
///
/// Show `—` (see `missingValue`) for unavailable or stale readings; never a
/// fabricated number.
class MetricCard extends StatelessWidget {
  /// Creates a metric card.
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.accent,
    this.width = 160,
  });

  /// Reading name, e.g. `Speed`.
  final String label;

  /// Pre-formatted value or `—`.
  final String value;

  /// Unit suffix, e.g. `km/h`.
  final String unit;

  /// Leading icon.
  final IconData icon;

  /// Icon / chip accent. When omitted or set to [AppColors.brandYellow], uses a
  /// yellow icon well with carbon icon so contrast stays sharp.
  final Color? accent;

  /// Fixed tile width so wraps align.
  final double width;

  @override
  Widget build(BuildContext context) {
    final isBrand = accent == null || accent == AppColors.brandYellow;
    final wellBg =
        isBrand ? AppColors.primaryContainer : accent!.withValues(alpha: 0.14);
    final iconColor = isBrand ? AppColors.carbon : accent!;
    return Semantics(
      label: '$label $value $unit',
      excludeSemantics: true,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: wellBg,
                borderRadius: AppRadius.small,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(value, style: AppTypography.metricValue),
            Text(
              '$label • $unit',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
