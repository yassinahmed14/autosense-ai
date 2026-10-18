# Release preparation validation — October 15, 2026

Publisher: Youssef Ahmed. Version: 0.1.0+3. No app has been submitted to Google Play.

| Check | Observed result |
|---|---|
| Flutter analysis | Passed, no issues |
| Flutter full suite | 55 passed, billing-enabled gate case intentionally skipped in default configuration |
| Targeted BLE profile/navigation/session retest | 6 passed; includes one additional return-from-dashboard test, so 56 distinct default-mode cases passed across runs |
| Billing-enabled gate | Separately passed with ENABLE_SUBSCRIPTIONS=true; unverified access blocked while privacy remains reachable |
| Backend tests | 38 passed; subscription state/expiry rejection, disabled configuration and validation errors that do not echo tokens |
| Backend Ruff | Lint and formatting passed |
| Browser membership UI | Reviewed at 390×844; EGP 99/month, EGP 999/year, eligible 3-day trial, disabled checkout; privacy screen opens; zero console errors |
| Android debug APK | Built, versionCode 3, min SDK 24, target SDK 36; signature verified and matches earlier installed APK certificate |
| Android APK packaging | zipalign -c -P 16 4 passed; three 64-bit ELF libraries passed static load-segment alignment checks |
| Android release App Bundle | Built; unsigned by design, versionCode 3, min SDK 24, target SDK 36; four 64-bit ELF libraries passed static load-segment alignment checks |
| Android 16 KB runtime | Not tested; static alignment does not establish runtime compatibility |
| Earlier physical install | User reported installing the previous debug APK and opening BLE setup |
| Updated adapter connection | Not physically tested; automatic known-profile matching, identity handshake and menu navigation are synthetic tests |
| Live Play billing / trial / renewals / refunds / lifecycle | Not tested; no Play account/products/credentials; checkout disabled |
| Signed release install, Play pre-launch report and closed test | Not run |
| iOS native build / hardware | Not run |

The unsigned review bundle and development APK remain checkout-disabled and use
development API configuration. They are not paid production upload candidates.
The Play release helper requires actual HTTPS API/policy/terms, contact email,
private upload signing configuration and an enabled verification endpoint.

Production billing still needs authenticated user/token ownership, durable lifecycle
processing, API entitlement enforcement, abuse controls and real license testing.
See SUBSCRIPTIONS.md. Store privacy/data-safety/terms drafts need real contact and
hosting details. No claims of definite diagnosis, universal adapter support or
measured engine horsepower/torque are made.

Artifact hashes and static native-library inspection are in the sibling Android
delivery folder's SHA256SUMS.txt and artifact-checks.json.


October 16, 2026: Android test source updated to 0.1.0+4 for ECU read recovery. 33 targeted tests passed. The review AAB/web preview remain the October 15 build; regenerate the commercial release after physical testing. See docs/BLE_AUTO_CONNECT.md.

Android test build 0.1.0+5: fixed ATCFC1 acknowledgement parsing using the user-supplied SEARCHING... / OK trace. 38 targeted tests passed, including four negative acknowledgement cases. Physical ECU access still needs retesting. AAB/web preview remain +3.
