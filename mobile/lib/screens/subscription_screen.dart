import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/subscription_controller.dart';
import 'privacy_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key, required this.controller});
  final SubscriptionController controller;
  Future<void> _manage() async {
    await Clipboard.setData(const ClipboardData(
        text:
            'https://play.google.com/store/account/subscriptions?sku=autosense_pro&package=com.autosense.autosense_ai'));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('AutoSense membership')),
        body: AnimatedBuilder(
            animation: controller,
            builder: (context, _) =>
                ListView(padding: const EdgeInsets.all(24), children: [
                  Text('One membership. Full app access.',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  const Text(
                      'Manual diagnostics, live dashboards and performance tools. '
                      'A compatible scanner and supported vehicle are still required for real readings.'),
                  const SizedBox(height: 20),
                  if (!SubscriptionController.enabled) ...[
                    const Text(
                        'PLAN PREVIEW • checkout is disabled in this development build'),
                    const ListTile(
                        title: Text('Monthly'),
                        subtitle: Text(
                            '3-day trial for eligible users, then EGP 99/month')),
                    const ListTile(
                        title: Text('Annual'),
                        subtitle: Text(
                            '3-day trial for eligible users, then EGP 999/year')),
                  ],
                  for (final offer in controller.offers)
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      offer.plan == 'monthly'
                                          ? 'Monthly'
                                          : 'Annual',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  Text(
                                      '${offer.trial ? '3 days free, then ' : ''}${offer.price}/${offer.plan == 'monthly' ? 'month' : 'year'}'),
                                  Text(offer.trial
                                      ? 'Renews automatically at the price above after the trial unless canceled.'
                                      : 'No trial offer is available for this plan/account. Recurring billing starts on purchase.'),
                                  FilledButton(
                                      onPressed:
                                          controller.busy || controller.active
                                              ? null
                                              : () => controller.buy(offer),
                                      child: Text(offer.trial
                                          ? 'Start 3-day trial'
                                          : 'Subscribe')),
                                ]))),
                  const SizedBox(height: 12),
                  Text(controller.message),
                  const SizedBox(height: 12),
                  const Text(
                      'Subscriptions renew automatically unless canceled. Cancel in Google Play before '
                      'the trial ends to avoid the first subscription charge. Cancellation normally keeps '
                      'access until the current paid period ends. The annual plan charges the full yearly amount.'),
                  OutlinedButton(
                      onPressed: controller.ready && !controller.busy
                          ? controller.restore
                          : null,
                      child: const Text('Restore purchases')),
                  OutlinedButton(
                      onPressed: () async {
                        await _manage();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Google Play subscription link copied. Open it in your browser, or use Play Store → Payments & subscriptions.')));
                        }
                      },
                      child:
                          const Text('Copy manage / cancel subscription link')),
                  TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (_) => const PrivacyScreen())),
                      child: const Text('Privacy & support')),
                  const SelectableText(
                      'Privacy policy: ${SubscriptionController.policyUrl}\nTerms: ${SubscriptionController.termsUrl}'),
                  const Text(
                      'Internet access is required for subscription verification. '
                      'The development APK already installed on your tablet does not charge a fee.'),
                ])),
      );
}
