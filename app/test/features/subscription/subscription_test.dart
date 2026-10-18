import 'package:autosense_ai/core/network/api_client.dart';
import 'package:autosense_ai/features/dashboard/presentation/dashboard_screen.dart';
import 'package:autosense_ai/features/diagnostics/presentation/lookup_screen.dart';
import 'package:autosense_ai/features/home/presentation/home_screen.dart';
import 'package:autosense_ai/features/privacy/presentation/privacy_screen.dart';
import 'package:autosense_ai/features/subscription/data/subscription_controller.dart';
import 'package:autosense_ai/features/subscription/presentation/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

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
  testWidgets(
      'freemium mode keeps DTC library free, gates Pro dashboard, and unlocks via 3-day trial',
      (tester) async {
    final controller = SubscriptionController('http://localhost');
    final api = ApiClient(baseUrl: 'http://localhost');
    addTearDown(controller.dispose);
    addTearDown(api.close);

    controller.switchToFreeTier();
    expect(controller.freemiumGateLocked, isTrue);

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(api: api, subscription: controller)),
    );

    // 1. Free feature (DTC library) opens without paywall.
    await tester.scrollUntilVisible(find.text('DTC library'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('DTC library'));
    await tester.pumpAndSettle();
    expect(find.byType(LookupScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 2. Pro feature (Open live dashboard) shows Freemium Pro paywall sheet.
    await tester.scrollUntilVisible(find.text('Open live dashboard'), -200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Open live dashboard'));
    await tester.pumpAndSettle();
    expect(
        find.text('Unlock Live OBD Dashboard & 10s Dyno Run'), findsOneWidget);

    // 3. Tapping Unlock Annual activates 3-day trial and navigates to DashboardScreen.
    await tester.tap(
        find.text('Unlock Annual • 3 days free, then EGP 999/yr (Save 16%)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(controller.demoTrialActive, isTrue);
    expect(controller.activePlan, 'annual');
    expect(find.byType(DashboardScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
