import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// A validated Google Play base plan (monthly / annual) with optional trial.
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
