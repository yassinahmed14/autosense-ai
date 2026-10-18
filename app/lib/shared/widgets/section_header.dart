import 'package:autosense_ai/core/theme/app_colors.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Section title with optional motorsport spec-sheet eyebrow, supporting line,
/// and trailing action.
class SectionHeader extends StatelessWidget {
  /// Creates a section header.
  const SectionHeader(
    this.title, {
    super.key,
    this.eyebrow,
    this.subtitle,
    this.trailing,
    this.large = false,
  });

  /// Section title.
  final String title;

  /// Optional uppercase eyebrow label above the title.
  final String? eyebrow;

  /// Optional supporting text under the title.
  final String? subtitle;

  /// Optional trailing widget (usually a [TextButton]).
  final Widget? trailing;

  /// Uses `headlineSmall` instead of `titleLarge` for top-level sections.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!.toUpperCase(),
              style: AppTypography.eyebrow.copyWith(color: AppColors.brandInk),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Row(children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: large
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.titleLarge,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ]),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
