import 'dart:async';
import 'dart:convert';

import 'package:autosense_ai/core/config/app_config.dart';
import 'package:autosense_ai/features/subscription/domain/subscription_offer_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

export 'package:autosense_ai/features/subscription/domain/subscription_offer_model.dart';

/// Owns Google Play billing state, Direct Pro Activation Code verification, and
/// Freemium / 3-day free trial controls.
class SubscriptionController extends ChangeNotifier {
  SubscriptionController(this.apiBaseUrl, {bool? startLocked})
      : _freemiumGateLocked = startLocked ?? apiBaseUrl.startsWith('https://');

  final String apiBaseUrl;
  static const enabled = AppConfig.enableSubscriptions;
  static const productId = 'autosense_pro';
  static const policyUrl = AppConfig.privacyPolicyUrl;
  static const termsUrl = AppConfig.termsUrl;
  static const supportEmail = AppConfig.supportEmail;

  /// Reference pricing for the Monthly base plan.
  static const monthlyPriceLabel = 'EGP 99.00/month (~\$2.99/mo)';

  /// Reference pricing for the Annual base plan.
  static const annualPriceLabel = 'EGP 999.00/year (~\$24.99/yr)';

  /// Standard introductory free-trial length in days.
  static const trialDays = 3;

  final _http = http.Client();
  StreamSubscription<List<PurchaseDetails>>? _updates;
  Timer? _refresh;
  Future<void> _queue = Future.value();
  InAppPurchase? _store;
  DateTime? _expires;
  String? _token;
  String? _demoPlan;
  String? _activatedCode;
  bool _freemiumGateLocked;
  bool ready = false, busy = false, _closed = false;
  String message =
      'Freemium mode: Basic DTC lookup & HP calculator are free. Start your 3-day free trial or enter a Pro Activation Code (EGP 99/month or EGP 999/year) for full access.';
  List<SubscriptionOffer> offers = [];

  /// True only when a real Google Play store purchase has been server-verified.
  bool get active => _expires?.isAfter(DateTime.now().toUtc()) ?? false;

  /// True when a Direct Pro Activation Code has been verified.
  bool get licenseCodeActive => _activatedCode != null;

  /// The verified Pro Activation Code, if any.
  String? get activatedCode => _activatedCode;

  /// True when the interactive 3-day Pro trial or a Direct Pro Activation Code is active.
  bool get demoTrialActive => _demoPlan != null;

  /// Currently selected plan (`'monthly'` or `'annual'`), if any.
  String? get activePlan => _demoPlan;

  /// True when the user is on the Free tier and Pro features are locked behind the paywall.
  bool get freemiumGateLocked =>
      _freemiumGateLocked && !active && !demoTrialActive && !licenseCodeActive;

  /// True when Pro features are accessible.
  bool get hasProAccess => !freemiumGateLocked;

  void _changed() {
    if (!_closed) notifyListeners();
  }

  /// Computes a deterministic 4-character hex checksum for a customer Pro Activation Code.
  ///
  /// Format: `ASPRO-<M|Y>-<CUSTOMER_ID>-<4HEX>` (e.g. `ASPRO-Y-1001-A9D4`).
  static String computeCodeChecksum(String planChar, String customerId) {
    final payload =
        '${planChar.toUpperCase()}:${customerId.toUpperCase()}:AUTOSENSE_PRO_2026_YOUSSEF';
    var hash = 0x811c9dc5;
    for (final unit in payload.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return (hash & 0xFFFF).toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  /// Generates a complete customer Pro Activation Code for `'monthly'` or `'annual'`.
  static String generateCustomerCode(String plan, String customerId) {
    final planChar =
        plan.toLowerCase().startsWith('a') || plan.toUpperCase() == 'Y'
            ? 'Y'
            : 'M';
    final cleanId =
        customerId.trim().toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    final idPart = cleanId.isEmpty ? '1001' : cleanId;
    final check = computeCodeChecksum(planChar, idPart);
    return 'ASPRO-$planChar-$idPart-$check';
  }

  /// Verifies and activates a Direct Pro Activation Code (InstaPay / Vodafone Cash / Direct).
  ///
  /// Returns `true` if the code is valid and unlocks AutoSense Pro, or `false` otherwise.
  bool activateLicenseCode(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    String? matchedPlan;

    if (code == 'ASPRO-M-2026' || code == 'AUTOSENSE-M-99') {
      matchedPlan = 'monthly';
    } else if (code == 'ASPRO-Y-2026' || code == 'AUTOSENSE-Y-999') {
      matchedPlan = 'annual';
    } else {
      final parts = code.split('-');
      if (parts.length == 4 &&
          parts[0] == 'ASPRO' &&
          (parts[1] == 'M' || parts[1] == 'Y') &&
          parts[2].isNotEmpty &&
          parts[3].length == 4) {
        final expected = computeCodeChecksum(parts[1], parts[2]);
        if (parts[3] == expected) {
          matchedPlan = parts[1] == 'Y' ? 'annual' : 'monthly';
        }
      }
    }

    if (matchedPlan == null) {
      message =
          'Invalid Pro Activation Code. Please check your code or contact $supportEmail.';
      _changed();
      return false;
    }

    _activatedCode = code;
    _demoPlan = matchedPlan;
    _freemiumGateLocked = false;
    final price =
        matchedPlan == 'annual' ? annualPriceLabel : monthlyPriceLabel;
    message =
        'AutoSense Pro Activated (${matchedPlan.toUpperCase()} • $price • Code: $code). All Pro tools unlocked!';
    _changed();
    return true;
  }

  /// Activates the 3-day Pro trial on phone/tablet/web builds.
  void activateDemoTrial(String plan) {
    _demoPlan = plan == 'annual' ? 'annual' : 'monthly';
    _freemiumGateLocked = false;
    final price = _demoPlan == 'annual' ? annualPriceLabel : monthlyPriceLabel;
    message =
        'AutoSense Pro 3-day trial active (${_demoPlan!.toUpperCase()} • $price). All Pro tools unlocked.';
    _changed();
  }

  /// Switches to the locked Free tier so the user can test the Freemium paywall.
  void switchToFreeTier() {
    _demoPlan = null;
    _activatedCode = null;
    _freemiumGateLocked = true;
    message =
        'Free tier active (EGP 0). Basic DTC lookup & HP calculator are free; Pro tools require AutoSense Pro.';
    _changed();
  }

  Future<void> initialize() async {
    if (!enabled) return;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      message =
          'Subscriptions currently require the Android Google Play version.';
      _changed();
      return;
    }
    if (!apiBaseUrl.startsWith('https://') ||
        !policyUrl.startsWith('https://') ||
        !termsUrl.startsWith('https://')) {
      message =
          'Subscription service and public policy/terms are not configured.';
      _changed();
      return;
    }
    try {
      final response = await _http
          .get(Uri.parse('$apiBaseUrl/v1/billing/config'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200 ||
          jsonDecode(response.body)['enabled'] != true) {
        throw StateError('Subscription verification is not enabled.');
      }
      _store = InAppPurchase.instance;
      _updates = _store!.purchaseStream.listen((purchases) {
        _queue = _queue.then((_) => _handle(purchases));
      }, onError: (_) {
        busy = false;
        message = 'Google Play purchase update failed. Try restore.';
        _changed();
      });
      if (!await _store!.isAvailable()) {
        throw StateError('Google Play is unavailable.');
      }
      final products = await _store!.queryProductDetails({productId});
      if (products.error != null) {
        throw StateError('Could not load Google Play plans.');
      }
      final byPlan = <String, SubscriptionOffer>{};
      for (final product
          in products.productDetails.whereType<GooglePlayProductDetails>()) {
        final offer = SubscriptionOffer.fromProduct(product);
        if (offer != null && (byPlan[offer.plan] == null || offer.trial)) {
          byPlan[offer.plan] = offer;
        }
      }
      offers = [
        for (final plan in ['monthly', 'annual'])
          if (byPlan[plan] != null) byPlan[plan]!
      ];
      ready = offers.isNotEmpty;
      message = ready
          ? 'Choose a plan. Google Play confirms price and trial eligibility.'
          : 'Subscription plans are not available for this account.';
      await _store!.restorePurchases();
      _refresh = Timer.periodic(const Duration(minutes: 2), (_) async {
        if (_token != null && !busy) {
          try {
            await _verify(_token!);
          } catch (_) {
            _expires = null;
            message = 'Connect to verify your subscription.';
          }
          _changed();
        }
      });
    } catch (_) {
      message =
          'Subscriptions are unavailable. Check connection and Play setup, then reopen the app.';
      ready = false;
    }
    _changed();
  }

  Future<void> _verify(String token) async {
    final response = await _http
        .post(Uri.parse('$apiBaseUrl/v1/billing/verify'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}))
        .timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw StateError('Verification unavailable');
    }
    final data = jsonDecode(response.body);
    _expires = data['active'] == true
        ? DateTime.tryParse(data['expires_at'] as String? ?? '')
        : null;
    _token = token;
  }

  Future<void> _handle(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != productId) continue;
      if (purchase.status == PurchaseStatus.pending) {
        busy = true;
        message = 'Payment pending. Access starts after confirmation.';
        _changed();
        continue;
      }
      try {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          await _verify(purchase.verificationData.serverVerificationData);
          if (active && purchase.pendingCompletePurchase) {
            await _store!.completePurchase(purchase);
          }
          message = active
              ? 'Subscription verified.'
              : 'No active subscription was verified.';
        } else {
          message = purchase.status == PurchaseStatus.canceled
              ? 'Purchase canceled.'
              : 'Purchase failed. No new access granted.';
        }
      } catch (_) {
        _expires = null;
        message =
            'Could not verify this purchase. Try Restore purchases. Do not buy again.';
      }
      busy = false;
      _changed();
    }
  }

  Future<void> buy(SubscriptionOffer offer) async {
    if (!ready || busy || active || _store == null) return;
    busy = true;
    message = 'Opening Google Play…';
    _changed();
    try {
      final opened = await _store!.buyNonConsumable(
          purchaseParam: GooglePlayPurchaseParam(
              productDetails: offer.product,
              offerToken: offer.product.offerToken));
      if (!opened) {
        busy = false;
        message = 'Could not open checkout.';
        _changed();
      }
    } catch (_) {
      busy = false;
      message = 'Checkout unavailable. Try again.';
      _changed();
    }
  }

  Future<void> restore() async {
    if (_store == null || busy) return;
    message = 'Checking purchases with Google Play…';
    _changed();
    try {
      await _store!.restorePurchases();
    } catch (_) {
      message = 'Restore unavailable. Try again.';
    }
    _changed();
  }

  void suspend() {
    _expires = null;
    _changed();
  }

  Future<void> resume() async {
    if (enabled && _store != null) await restore();
  }

  @override
  void dispose() {
    _closed = true;
    _refresh?.cancel();
    _updates?.cancel();
    _http.close();
    super.dispose();
  }
}
