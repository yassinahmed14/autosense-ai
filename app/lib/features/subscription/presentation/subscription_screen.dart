import 'package:autosense_ai/core/config/app_config.dart';
import 'package:autosense_ai/core/routing/app_router.dart';
import 'package:autosense_ai/core/theme/app_colors.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/features/privacy/presentation/privacy_screen.dart';
import 'package:autosense_ai/features/subscription/data/subscription_controller.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AutoSense Pro membership & Freemium plan selector screen.
///
/// Displays Monthly (`EGP 99.00/month`) and Annual (`EGP 999.00/year`) plans
/// with a 3-day free trial, Freemium vs. Pro feature comparison, interactive
/// tablet/demo trial activation, and Google Play billing compliance disclosures.
class SubscriptionScreen extends StatelessWidget {
  /// Creates the membership screen bound to [controller].
  const SubscriptionScreen({super.key, required this.controller});

  /// Billing state and actions.
  final SubscriptionController controller;

  /// Shows the Freemium Pro paywall bottom sheet when a locked Pro feature is tapped.
  static Future<void> showProPaywallSheet(
    BuildContext context,
    SubscriptionController controller, {
    required String featureName,
    required VoidCallback onUnlocked,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.sm,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.brandYellow,
                        borderRadius: AppRadius.small,
                      ),
                      child: Text(
                        'AUTOSENSE PRO',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.onBrandYellow,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '3-Day Free Trial',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.brandInk,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Unlock $featureName',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Basic DTC lookup and the HP & torque calculator are always free. '
                  'Subscribe to AutoSense Pro to unlock Live OBD-II Bluetooth/Wi-Fi scanning, '
                  'Clear Check-Engine Codes, 10-Second Dyno Power Runs, and Full AI Guidance.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryActionButton(
                  icon: Icons.workspace_premium_outlined,
                  label:
                      'Unlock Annual • 3 days free, then EGP 999/yr (Save 16%)',
                  onPressed: () {
                    controller.activateDemoTrial('annual');
                    Navigator.of(sheetContext).pop();
                    onUnlocked();
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                SecondaryActionButton(
                  icon: Icons.calendar_month_outlined,
                  label: 'Unlock Monthly • 3 days free, then EGP 99/mo',
                  onPressed: () {
                    controller.activateDemoTrial('monthly');
                    Navigator.of(sheetContext).pop();
                    onUnlocked();
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      AppRouter.push<void>(
                        context,
                        AppRoutes.subscription,
                        SubscriptionScreen(controller: controller),
                      );
                    },
                    child: const Text('Compare Free vs. Pro plans'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _manage() async {
    await Clipboard.setData(
        const ClipboardData(text: AppConfig.manageSubscriptionUrl));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('AutoSense membership')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => PageListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            const HeaderIcon(Icons.workspace_premium_outlined),
            const SizedBox(height: AppSpacing.lg),
            Text('One membership. Full app access.',
                style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            const Text(
                'Freemium & AutoSense Pro: Basic 56-code DTC lookup and the HP & torque '
                'calculator are always Free (EGP 0). Upgrade to AutoSense Pro (3-day free trial, '
                'then EGP 99/month or EGP 999/year) to unlock Live OBD-II Bluetooth/Wi-Fi '
                'telemetry, Clear Codes, 10-Second Dyno Power Estimator, and Full AI Guidance. '
                'A compatible scanner and supported vehicle are still required for real readings.'),
            const SizedBox(height: AppSpacing.xl),
            if (!SubscriptionController.enabled) ...[
              StatusBanner(
                controller.demoTrialActive
                    ? 'AUTOSENSE PRO ACTIVE (${controller.activePlan?.toUpperCase()}) • 3-day trial unlocked (Google Play checkout is disabled in this development build)'
                    : controller.freemiumGateLocked
                        ? 'FREE TIER ACTIVE (EGP 0) • Pro features are locked behind the paywall (Google Play checkout is disabled in this development build)'
                        : 'AUTOSENSE PRO PLANS • 3-day free trial, then EGP 99/mo or EGP 999/yr (Google Play checkout is disabled in this development build)',
                tone: controller.demoTrialActive
                    ? BannerTone.info
                    : BannerTone.warning,
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Monthly',
                                style: theme.textTheme.titleLarge),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: AppRadius.small,
                            ),
                            child: Text(
                              '3-DAY FREE TRIAL',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.brandInk,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '3-day trial, then EGP 99/month (~\$2.99/mo)',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Full access to Live OBD-II Bluetooth & Wi-Fi Scanner, Clear Codes, '
                        '10-Second Dyno Power Run, and 35-Brand AI Diagnostic Guidance. Cancel anytime.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryActionButton(
                        icon: controller.activePlan == 'monthly'
                            ? Icons.check_circle
                            : Icons.play_arrow_rounded,
                        label: controller.activePlan == 'monthly'
                            ? 'Monthly Pro trial active (EGP 99/mo)'
                            : 'Activate Monthly 3-day trial (EGP 99/mo)',
                        onPressed: controller.activePlan == 'monthly'
                            ? null
                            : () => controller.activateDemoTrial('monthly'),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Annual',
                                style: theme.textTheme.titleLarge),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.brandYellow,
                              borderRadius: AppRadius.small,
                            ),
                            child: Text(
                              'BEST VALUE • SAVE 16%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.onBrandYellow,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '3-day trial, then EGP 999/year (~\$24.99/yr • EGP 83.25/mo)',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Includes 3-day free trial and 2 months free compared to monthly billing. '
                        'Unlocks every Pro diagnostic, telemetry, and scanner tool for 12 months.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryActionButton(
                        icon: controller.activePlan == 'annual'
                            ? Icons.check_circle
                            : Icons.workspace_premium_outlined,
                        label: controller.activePlan == 'annual'
                            ? 'Annual Pro trial active (EGP 999/yr)'
                            : 'Activate Annual 3-day trial (EGP 999/yr)',
                        onPressed: controller.activePlan == 'annual'
                            ? null
                            : () => controller.activateDemoTrial('annual'),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Free Tier vs. AutoSense Pro',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        '• Always Free (EGP 0): 56-Code DTC Library (P/B/C/U), Offline Catalog Browser & HP/Torque Calculator.\n'
                        '• AutoSense Pro (EGP 99/mo or EGP 999/yr): Live OBD-II Bluetooth/Wi-Fi Dashboard, Clear Check-Engine Codes, 10s Dyno Power Run & Full 35-Brand AI Diagnostic Guidance.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SecondaryActionButton(
                        icon: controller.freemiumGateLocked
                            ? Icons.lock_outline
                            : Icons.lock_open_outlined,
                        label: controller.freemiumGateLocked
                            ? 'Free tier active (Pro paywall locked)'
                            : 'Switch to Free tier (test Pro paywall lock)',
                        onPressed: controller.freemiumGateLocked
                            ? null
                            : controller.switchToFreeTier,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            for (final offer in controller.offers)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer.plan == 'monthly' ? 'Monthly' : 'Annual',
                          style: theme.textTheme.titleLarge),
                      Text(
                          '${offer.trial ? '3 days free, then ' : ''}${offer.price}/${offer.plan == 'monthly' ? 'month' : 'year'}'),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                          offer.trial
                              ? 'Renews automatically at the price above after the trial unless canceled.'
                              : 'No trial offer is available for this plan/account. Recurring billing starts on purchase.',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryActionButton(
                          onPressed: controller.busy || controller.active
                              ? null
                              : () => controller.buy(offer),
                          label:
                              offer.trial ? 'Start 3-day trial' : 'Subscribe'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(controller.message),
            const SizedBox(height: AppSpacing.md),
            Text(
                'Subscriptions renew automatically unless canceled. Cancel in Google Play before '
                'the trial ends to avoid the first subscription charge. Cancellation normally keeps '
                'access until the current paid period ends. The annual plan charges the full yearly amount.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.lg),
            SecondaryActionButton(
                onPressed: controller.ready && !controller.busy
                    ? controller.restore
                    : null,
                label: 'Restore purchases'),
            const SizedBox(height: AppSpacing.sm),
            SecondaryActionButton(
                onPressed: () async {
                  await _manage();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Google Play subscription link copied. Open it in your browser, or use Play Store → Payments & subscriptions.')));
                  }
                },
                label: 'Copy manage / cancel subscription link'),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
                onPressed: () => AppRouter.push<void>(
                    context, AppRoutes.privacy, const PrivacyScreen()),
                child: const Text('Privacy & support')),
            const SelectionArea(
              child: Text(
                  'Privacy policy: ${SubscriptionController.policyUrl}\nTerms: ${SubscriptionController.termsUrl}'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
                'Internet access is required to verify Google Play store subscriptions.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
