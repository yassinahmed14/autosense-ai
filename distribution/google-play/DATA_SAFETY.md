# Data safety preparation — not a completed declaration

Publisher: Youssef Ahmed. Complete after choosing the final hosting stack and
auditing the exact release artifact and all enabled SDKs.

| Flow | Local / transmitted | Purpose / retention |
|---|---|---|
| Selected vehicle make/model/year, DTCs, symptoms, safety flags, notes, source | Sent to configured API on guidance request | App functionality; supplied rules backend handles in memory |
| DTC lookup code | Sent to API in URL path | Lookup; may appear in proxy/access logs |
| Network IP, connection metadata | Visible to API host/network infrastructure | Hosting/access logs depend on chosen provider; policy must specify actual retention |
| BLE names, identifiers, service UUIDs | On-device connection handling; report can be copied by user | Scanner discovery; not included in diagnostic request |
| Live speed, RPM, temperature, throttle, mass, recorded runs | On-device memory; user can copy CSV | Dashboard and estimates; no automatic telemetry upload |
| History | On-device memory | Disappears when process ends |
| Clipboard exports | Device clipboard / user-selected destination | Sharing initiated by user; recipients have their own practices |

The app has no login, advertising or analytics SDK. Google Play Billing SDK is now
included. When activated, purchase tokens go to the verifier, which queries Google
for subscription state/expiry and acknowledges verified purchases. Inventory purchase
history/financial information, identifiers and service-provider flows according to
the final authenticated deployment. No payment-card details are collected by the app. Supabase
is not connected. No GPS coordinate read is implemented. Older Android BLE scan
permission does not by itself establish GPS collection. Verify transitive SDK
behavior and the merged manifest before declaring permissions/data practices.

Do not automatically answer "no data collected": guidance transmits user inputs.
Ephemeral off-device processing still needs evaluation in Google's form. Review
vehicle/diagnostic fields under Other user-generated content or Other app activity
as appropriate to current Console definitions. Free-form notes can contain personal
information despite the in-app request not to include it. Assess IP/identifier
categories using the deployed hosting behavior. No third-party sharing claim can
be finalized until service-provider relationships are reviewed.

Only declare encrypted in transit after the release uses HTTPS throughout. The
installed development APK uses HTTP via USB forwarding and does not establish it.
Account deletion is not applicable while accounts do not exist; provide an actual
support/deletion contact for any server-side information retained in deployment.

Before submitting: fill real support contact, retention durations, provider list,
data categories, required/optional collection, deletion mechanism, security answers,
and SDK disclosures. Keep the website policy, in-app information and form aligned.

Source: https://support.google.com/googleplay/android-developer/answer/10787469
