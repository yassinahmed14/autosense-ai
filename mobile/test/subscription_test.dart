import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:autosense_ai/screens/subscription_screen.dart';
import 'package:autosense_ai/screens/privacy_screen.dart';
import 'package:autosense_ai/services/subscription_controller.dart';

GooglePlayProductDetails product(
    {bool trial = false,
    String period = 'P3D',
    String plan = 'monthly',
    int price = 99000000}) {
  return GooglePlayProductDetails.fromProductDetails(ProductDetailsWrapper(
    description: 'Test',
    name: 'Test',
    title: 'Test',
    productId: 'autosense_pro',
    productType: ProductType.subs,
    subscriptionOfferDetails: [
      SubscriptionOfferDetailsWrapper(
        basePlanId: plan,
        offerIdToken: 'synthetic-offer-token',
        offerTags: const [],
        pricingPhases: [
          if (trial)
            PricingPhaseWrapper(
                billingCycleCount: 1,
                billingPeriod: period,
                formattedPrice: 'Free',
                priceAmountMicros: 0,
                priceCurrencyCode: 'EGP',
                recurrenceMode: RecurrenceMode.finiteRecurring),
          PricingPhaseWrapper(
              billingCycleCount: 0,
              billingPeriod: plan == 'annual' ? 'P1Y' : 'P1M',
              formattedPrice: plan == 'annual' ? 'EGP 999.00' : 'EGP 99.00',
              priceAmountMicros: price,
              priceCurrencyCode: 'EGP',
              recurrenceMode: RecurrenceMode.infiniteRecurring),
        ],
      )
    ],
  )).single;
}

void main() {
  test('trial label includes actual recurring price, not free phase price', () {
    final offer = SubscriptionOffer.fromProduct(product(trial: true))!;
    expect(offer.trial, isTrue);
    expect(offer.price, 'EGP 99.00');
  });
  test('paid plan has no invented trial and annual uses full yearly charge',
      () {
    final offer = SubscriptionOffer.fromProduct(
        product(plan: 'annual', price: 999000000))!;
    expect(offer.trial, isFalse);
    expect(offer.price, 'EGP 999.00');
  });
  test('unexpected trial duration, plan and free recurring price rejected', () {
    expect(SubscriptionOffer.fromProduct(product(trial: true, period: 'P7D')),
        isNull);
    expect(SubscriptionOffer.fromProduct(product(plan: 'weekly')), isNull);
    expect(SubscriptionOffer.fromProduct(product(price: 0)), isNull);
  });
  testWidgets('preview cannot start checkout and keeps support accessible',
      (tester) async {
    final controller = SubscriptionController('http://localhost');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
        MaterialApp(home: SubscriptionScreen(controller: controller)));
    expect(find.textContaining('checkout is disabled'), findsOneWidget);
    expect(find.text('Start 3-day trial'), findsNothing);
    expect(controller.active, isFalse);
    await tester.scrollUntilVisible(find.text('Privacy & support'), 250);
    await tester.tap(find.text('Privacy & support'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyScreen), findsOneWidget);
  });
}
