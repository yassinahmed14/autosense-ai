/// Compile-time configuration supplied with `--dart-define`.
///
/// Every value is a `const` so it can be tree-shaken and used in `const`
/// widgets. Never read `String.fromEnvironment` anywhere else in the app.
abstract final class AppConfig {
  /// Base URL of the diagnostic API (no trailing slash required).
  ///
  /// Defaults to the Android emulator loopback for local development.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Whether Google Play subscriptions gate access to the app.
  static const enableSubscriptions = bool.fromEnvironment(
    'ENABLE_SUBSCRIPTIONS',
  );

  /// Public HTTPS privacy-policy URL hosted on Vercel.
  static const privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://autosense-api.vercel.app/privacy',
  );

  /// Public HTTPS terms-of-service URL hosted on Vercel.
  static const termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://autosense-api.vercel.app/terms',
  );

  /// Public support e-mail address.
  static const supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'youssefahmed4010@gmail.com',
  );

  /// Human-readable privacy-policy value shown in the privacy screen.
  static const privacyPolicyLabel = privacyPolicyUrl == ''
      ? 'Public policy URL pending store release'
      : privacyPolicyUrl;

  /// Human-readable support value shown in the privacy screen.
  static const supportEmailLabel = supportEmail == ''
      ? 'Support contact pending store release'
      : supportEmail;

  /// Play Store link that lets a user manage or cancel the subscription.
  static const manageSubscriptionUrl =
      'https://play.google.com/store/account/subscriptions'
      '?sku=autosense_pro&package=com.autosense.autosense_ai';
}
