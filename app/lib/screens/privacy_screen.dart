import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const supportEmail = String.fromEnvironment('SUPPORT_EMAIL',
      defaultValue: 'Support contact pending store release');
  static const policyUrl = String.fromEnvironment('PRIVACY_POLICY_URL',
      defaultValue: 'Public policy URL pending store release');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Privacy & app information')),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: SelectionArea(
            child: Text(
              'AutoSense AI • Development version\n'
              'Publisher: Youssef Ahmed\n'
              'Support: $supportEmail\n'
              'Privacy policy: $policyUrl\n\n'
              'Your choices\n'
              'The demo and live scanner dashboard run on your device. '
              'Bluetooth discovery uses nearby device names and identifiers to '
              'connect to the scanner you select. On older Android versions, '
              'Bluetooth discovery requires a location permission; AutoSense '
              'does not request GPS coordinates. Wi-Fi mode connects to the '
              'adapter address you enter.\n\n'
              'Diagnostic requests\n'
              'When you request guidance, the app sends your selected vehicle, '
              'DTC codes, symptoms, safety selections, notes and input source '
              'to the configured backend. Code lookup sends the requested code. '
              'Do not enter names, contact details or other personal information '
              'in notes. The supplied backend processes requests in memory; '
              'hosting providers may process connection metadata and logs.\n\n'
              'Storage and sharing\n'
              'History and recorded runs are kept in app memory and disappear '
              'when the app process ends. Reports or CSV data you copy are '
              'placed on your device clipboard. This version has no accounts, '
              'ads, analytics or enabled cloud history.\n\n'
              'Subscriptions\n'
              'In a billing-enabled Google Play build, Google handles checkout. '
              'Purchase tokens are sent to the configured backend to verify '
              'subscription status and expiry. AutoSense does not collect card '
              'details. Development builds keep checkout disabled.\n\n'
              'Controls\n'
              'You can disconnect a scanner, cancel a run, revoke permissions '
              'in Android Settings, and close the app to end its session.\n\n'
              'Release status\n'
              'A public support email and hosted privacy-policy URL must be '
              'configured before store release. Hardware compatibility is '
              'experimental. Guidance lists possibilities, not definite diagnoses. '
              'Run estimates are not measured engine horsepower or torque. '
              'Real code clearing is disabled.',
            ),
          ),
        ),
      );
}
