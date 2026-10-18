import 'package:autosense_ai/core/config/app_config.dart';
import 'package:autosense_ai/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Privacy disclosure and app information (publisher, support, policy).
class PrivacyScreen extends StatelessWidget {
  /// Creates the privacy screen.
  const PrivacyScreen({super.key});

  /// Support contact shown to users (configured via `SUPPORT_EMAIL`).
  static const supportEmail = AppConfig.supportEmailLabel;

  /// Privacy-policy URL shown to users (configured via `PRIVACY_POLICY_URL`).
  static const policyUrl = AppConfig.privacyPolicyLabel;

  /// Subscription terms URL shown to users (configured via `TERMS_URL`).
  static const termsUrl = AppConfig.termsUrl;

  /// Full disclosure text.
  static const disclosure = 'AutoSense AI • v1.0.0+6\n'
      'Publisher: Youssef Ahmed\n'
      'Support: $supportEmail\n'
      'Privacy policy: $policyUrl\n'
      'Subscription terms: $termsUrl\n\n'
      'Your choices\n'
      'The demo and live scanner dashboard run on your device. '
      'Bluetooth discovery uses nearby device names and identifiers to '
      'connect to the scanner you select. On older Android versions, '
      'Bluetooth discovery requires a location permission; AutoSense '
      'does not request GPS coordinates. Wi-Fi mode connects to the '
      'adapter address you enter.\n\n'
      'Diagnostic requests & Hybrid Smart Mode\n'
      'When you request guidance, the app sends your selected vehicle, '
      'DTC codes, symptoms, safety selections, notes and input source '
      'over HTTPS to the configured diagnostic service, or processes '
      'them directly on-device via the offline diagnostic engine when '
      'offline. Code lookup sends the requested code. Do not enter names, '
      'contact details or other personal information in notes. The cloud '
      'backend processes requests in memory without a user database.\n\n'
      'Storage and sharing\n'
      'History and recorded runs are kept in app memory and disappear '
      'when the app process ends. Reports or CSV data you copy are '
      'placed on your device clipboard. This version has no accounts, '
      'ads, analytics or enabled cloud history.\n\n'
      'Subscriptions (Freemium & AutoSense Pro)\n'
      'Basic 56-code DTC lookup and the HP & torque calculator are free. '
      'AutoSense Pro (EGP 99/month or EGP 999/year with a 3-day free trial) '
      'is processed through Google Play. Purchase tokens are sent over HTTPS '
      'to the configured backend to verify subscription status and expiry. '
      'AutoSense does not collect card details.\n\n'
      'Controls & boundaries\n'
      'You can disconnect a scanner, cancel a run, revoke permissions '
      'in Android Settings, and close the app to end its session. '
      'Hardware compatibility is experimental. Guidance lists possibilities, '
      'not definite diagnoses. Run estimates are not measured engine '
      'horsepower or torque.';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Privacy & app information')),
        body: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: const SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: SelectionArea(child: Text(disclosure)),
                ),
              ),
            ),
          ),
        ),
      );
}
