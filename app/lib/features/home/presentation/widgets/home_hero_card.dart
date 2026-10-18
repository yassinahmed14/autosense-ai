import 'package:autosense_ai/core/theme/app_colors.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/core/theme/app_typography.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:flutter/material.dart';

/// Showroom-style light hero card at the top of the home screen with the
/// custom racing-yellow supercar illustration and primary dashboard CTA.
class HomeHeroCard extends StatelessWidget {
  /// Creates the hero card.
  const HomeHeroCard({super.key, required this.onOpenDashboard});

  /// Opens the simulated live dashboard.
  final VoidCallback onOpenDashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryText =
        theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.extraLarge,
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(
              color: AppColors.background,
              child: Image.asset(
                'assets/images/hero_car.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.directions_car_filled_outlined,
                    size: 64,
                    color: AppColors.carbon,
                  ),
                ),
              ),
            ),
          ),
          Container(height: 4, color: AppColors.brandYellow),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AUTOSENSE / DRIVE INSIGHT',
                  style: AppTypography.eyebrow.copyWith(
                    color: AppColors.brandInk,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 36,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: AppColors.brandYellow,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Your car,\nat a glance.',
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Live gauges. Clear choices.\nRecord a run and explore your data.',
                  style: secondaryText,
                ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryActionButton(
                  icon: Icons.speed,
                  label: 'Open live dashboard',
                  onPressed: onOpenDashboard,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Preview with simulated data • no car connection',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
