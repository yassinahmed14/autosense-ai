# Subscription requirements — owner decision recorded

Owner requested a 3-day trial, followed by a monthly or annual subscription.
Confirmed: EGP 99/month and EGP 999/year, full app access. Google Play controls
localized prices and trial eligibility. A Flutter purchase/restore/paywall prototype
and optional Google Play backend verification are now included. Checkout is disabled
by default; there is no active Play product or configured credential. No money can
be charged by the supplied review build. Live billing has not been tested.

## Proposed store configuration

Use one Google Play subscription product, `autosense_pro`, with two auto-renewing
base plans: `monthly` (P1M) and `annual` (P1Y). Add a 3-day free trial (P3D) offer
to each base plan, eligible only for new subscribers under Google's rules. This
keeps monthly/yearly access in one subscription family. Do not create an app-side
clock that grants another trial after reinstalling. Google Play determines offer
availability; ineligible users must see the paid plan without a trial claim.

Use localized prices and actual pricing phases from Play product details. The
paywall must state the 3-day trial, the selected plan's full recurring price and
period, automatic renewal, when charging begins, and how to cancel. Annual price
must be shown as the actual yearly charge, not only a monthly equivalent. Include
Restore purchases, Manage subscription, privacy policy and terms. No payment
details should be collected directly by AutoSense.

## Implemented prototype

- in_app_purchase 3.3.1 and Android adapter 0.5.4; query `autosense_pro`.
- Match monthly/annual base plans and a P3D zero-price trial followed by the expected
  recurring phase. Show the full localized recurring amount; reject unknown phases.
- Purchase stream, selected offer token, restore, pending/canceled/error states,
  HTTPS server verification, verified completion, periodic refresh and resume checks.
- App-wide gate in billing-enabled builds. Development builds retain open access
  and show a clearly marked non-purchasable plan preview.
- Backend `/v1/billing/config` and `/v1/billing/verify`: disabled without explicit
  process environment, validate Play package/product/base plan/state/expiry, acknowledge
  active purchases, avoid echoing purchase tokens in exceptions.
- Synthetic offer parsing and subscription state/expiry tests. No live Google test.

## Deployment configuration

Install backend optional dependency with `pip install -e ".[billing]"`. Export
`PLAY_BILLING_ENABLED=true`, `PLAY_PACKAGE_NAME=com.autosense.autosense_ai`, and
`GOOGLE_APPLICATION_CREDENTIALS` pointing to a private service-account JSON outside
the project. Grant only necessary Play API access. Never put this JSON in an APK/ZIP.
The `.env.example` entries are documentation; the billing module reads process
environment variables. Configure products and license testers in Console.

Build flags: `ENABLE_SUBSCRIPTIONS=true`, HTTPS `API_BASE_URL`, `PRIVACY_POLICY_URL`,
`TERMS_URL`, and real `SUPPORT_EMAIL`. The supplied release helper sets these flags.
Subscription verification needs network access; the prototype has no offline lease.

## Required before public activation

1. Integrate Flutter's official in_app_purchase adapter and Google Play product /
   base-plan / offer-token selection. Listen to purchase updates on app startup.
2. Add backend purchase-token verification against Google's subscription API;
   verify package, expected product, expiry and purchase state. Keep service-account
   credentials only on the server. Bind entitlements to the intended user/account.
3. Grant access only after verification, handle pending/canceled/error purchases,
   and acknowledge verified purchases. Restore/reconcile on startup and resume.
4. Add subscription lifecycle notifications and durable entitlement state covering
   renewal, cancellation until paid expiry, grace period, account hold, refund,
   revocation, expiry, plan change and resubscription. Never trust a local Pro flag.
5. Gate only the approved paid scope, keep access to cancellation/help/privacy,
   and avoid charging twice when a subscriber changes monthly/yearly plans.
6. Update privacy/data-safety disclosures for purchase tokens, user identifiers,
   subscription status, hosting retention and account deletion if accounts are added.
7. Test using Play license testers and an internal-track installation. Validate
   trial eligibility, localized pricing, renewal, restore, failures, refunds and
   all transitions. A sideloaded APK/mock checkout cannot establish billing readiness.

## Release decision

The current unsigned release artifact has checkout disabled for review. Do not upload
it as the final subscription release. Configure the Play account/products, settle
pricing/scope, implement and test verification/entitlements, then rebuild, re-audit
the disclosures and run the required Play testing before publication.

Official references checked October 15, 2026:
- https://developer.android.com/google/play/billing/subscriptions
- https://developer.android.com/google/play/billing/integrate
- https://developer.android.com/google/play/billing/lifecycle/subscriptions
- https://pub.dev/packages/in_app_purchase

### Security and lifecycle release blockers

The prototype uses the Play purchase token as bearer evidence and has no authenticated
user/account binding, rate limiter, durable token ownership/replay protection or RTDN
consumer. The general diagnostic routes are not protected by subscription entitlement.
Do not expose/enable it as a production paid service until these are implemented and
reviewed. Polling Play does not establish robust background lifecycle handling. Local
feature gating can be modified by a hostile client and is not an API authorization
boundary. These limitations require deployment/account work beyond a store mockup.
