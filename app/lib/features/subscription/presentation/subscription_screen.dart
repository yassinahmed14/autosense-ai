import 'package:autosense_ai/core/config/app_config.dart';
import 'package:autosense_ai/core/routing/app_router.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:autosense_ai/features/privacy/presentation/privacy_screen.dart';
import 'package:autosense_ai/features/subscription/data/subscription_controller.dart';
import 'package:autosense_ai/shared/widgets/action_buttons.dart';
import 'package:autosense_ai/shared/widgets/page_layout.dart';
import 'package:autosense_ai/shared/widgets/status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 100% Free Edition & Membership overview screen.
///
/// Highlights that all Pro diagnostic, offline catalog, and telemetry tools
/// are unlocked at zero cost in this edition, while retaining Google Play
/// billing compliance disclosures when `ENABLE_BILLING=true`.
class SubscriptionScreen extends StatelessWidget {
  /// Creates the membership screen bound to [controller].
  const SubscriptionScreen({super.key, required this.controller});

  /// Billing state and actions.
  final SubscriptionController controller;

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
                '100% Free Edition: All manual diagnostics, 56-code offline & cloud DTC library, '
                '35-brand vehicle selector, live telemetry dashboard, and 10-second dyno power tools are unlocked at zero cost. '
                'A compatible scanner and supported vehicle are still required for real readings.'),
            const SizedBox(height: AppSpacing.xl),
            if (!SubscriptionController.enabled) ...[
              const StatusBanner(
                  '100% FREE EDITION • All Pro tools are unlocked forever; checkout is disabled in this development build',
                  tone: BannerTone.warning),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('Unlocked Free Forever (EGP 0 / \$0)'),
                  subtitle: Text(
                      'Offline + Cloud 56-Code P/B/C/U Engine • 35 Car Brands • Live RPM/Speed/Coolant/Throttle • 10s Dyno Power Estimator'),
                ),
              ),
              const Card(
                child: ListTile(
                    title: Text('Monthly'),
                    subtitle: Text(
                        'Included free in this edition (standard reference: 3-day trial, then EGP 99/month)')),
              ),
              const Card(
                child: ListTile(
                    title: Text('Annual'),
                    subtitle: Text(
                        'Included free in this edition (standard reference: 3-day trial, then EGP 999/year)')),
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
                'Internet access is only required when verifying store subscriptions; '
                'all diagnostic and calculation features work offline at zero cost.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
