import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';

class SubscriptionOffer {
  const SubscriptionOffer(this.product, this.plan, this.price, this.trial);
  final GooglePlayProductDetails product;
  final String plan, price;
  final bool trial;

  static SubscriptionOffer? fromProduct(GooglePlayProductDetails product) {
    final index = product.subscriptionIndex;
    final details = product.productDetails.subscriptionOfferDetails;
    if (index == null || details == null || index >= details.length) {
      return null;
    }
    final offer = details[index];
    final period = switch (offer.basePlanId) {
      'monthly' => 'P1M',
      'annual' => 'P1Y',
      _ => '',
    };
    final phases = offer.pricingPhases;
    if (period.isEmpty || phases.isEmpty) return null;
    final recurring = phases.last;
    if (recurring.billingPeriod != period ||
        recurring.priceAmountMicros <= 0 ||
        recurring.recurrenceMode != RecurrenceMode.infiniteRecurring) {
      return null;
    }
    final trial = phases.length == 2 &&
        phases.first.priceAmountMicros == 0 &&
        phases.first.billingPeriod == 'P3D' &&
        phases.first.billingCycleCount == 1;
    if (phases.length != 1 && !trial) return null;
    return SubscriptionOffer(
        product, offer.basePlanId, recurring.formattedPrice, trial);
  }
}

class SubscriptionController extends ChangeNotifier {
  SubscriptionController(this.apiBaseUrl);
  final String apiBaseUrl;
  static const enabled = bool.fromEnvironment('ENABLE_SUBSCRIPTIONS');
  static const productId = 'autosense_pro';
  static const policyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');
  static const termsUrl = String.fromEnvironment('TERMS_URL');
  final _http = http.Client();
  StreamSubscription<List<PurchaseDetails>>? _updates;
  Timer? _refresh;
  Future<void> _queue = Future.value();
  InAppPurchase? _store;
  DateTime? _expires;
  String? _token;
  bool ready = false, busy = false, _closed = false;
  String message = 'Subscriptions are not activated in this development build.';
  List<SubscriptionOffer> offers = [];
  bool get active => _expires?.isAfter(DateTime.now().toUtc()) ?? false;
  void _changed() {
    if (!_closed) notifyListeners();
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
