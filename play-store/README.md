# AutoSense AI — Google Play preparation

Prepared October 15, 2026 for Youssef Ahmed. This folder is a preparation pack,
not evidence of publication, Play approval, or completed real-world testing.

## Included

- STORE_LISTING.md: copy for the store, with honest feature limitations.
- privacy-policy.html: public-policy draft to complete and host.
- DATA_SAFETY.md: data-flow inventory and form preparation.
- TEST_PLAN.md: software results and physical/Play test cases.
- RELEASE_STEPS.md: signing, deployment, account and upload instructions.
- SUBSCRIPTIONS.md: confirmed pricing, implemented prototype and activation blockers.
- assets/: turbo logo, launcher resources and feature graphic.
- review-screenshots/: actual earlier Flutter browser screenshots, explicitly
  for review; replace with captures of the release on Android before upload.

## Current blockers

1. Public support email and final privacy contact details are missing.
2. A public HTTPS privacy-policy URL and a working HTTPS diagnostic backend are missing.
   The supplied backend is unauthenticated; harden/deploy it before public use.
3. No Google Play Console account exists yet. The owner must enroll, verify
   identity and accept agreements. No account was created or payment made.
4. A private upload signing key has not been created. Review bundles are unsigned.
5. The application ID com.autosense.autosense_ai must be confirmed as the owner's
   final unique identifier before the first upload; it becomes difficult to change.
6. Adapter compatibility, native BLE/Wi-Fi permission flows and performance accuracy
   have not been validated. User reported successful APK installation on Android 11.
7. Play closed testing and pre-launch reports have not run. Do not mark tests passed
   unless there is evidence. New personal accounts normally need 12 testers opted
   in continuously for at least 14 days before applying for production access.

## Official requirements checked

- API target: https://developer.android.com/google/play/requirements/target-sdk
- Testing: https://support.google.com/googleplay/android-developer/answer/14151465
- User data/privacy: https://support.google.com/googleplay/android-developer/answer/10144311
- Data safety: https://support.google.com/googleplay/android-developer/answer/10787469
- Listing assets: https://support.google.com/googleplay/android-developer/answer/9866151

Target SDK is explicitly 36. Recheck requirements in Play Console at upload time.

## Subscription decision and code status

Confirmed by owner: EGP 99/month or EGP 999/year, 3-day trial for eligible users,
full app access. No free functional tier is planned for the billing-enabled release.
Privacy, terms, restore and cancellation/help access remain available without payment.

Flutter Play Billing integration and backend verification prototype are included.
Checkout is OFF by default. This is not an active commercial subscription service.
Public activation still needs Play products/credentials, authenticated user binding,
abuse controls, durable lifecycle processing, legal/contact details and license testing.
An unsigned review AAB is not ready for upload or charging.
