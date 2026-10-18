# Verification record

Updated 2026-10-15 on Windows with Python 3.11.0, Flutter 3.47.7 and Dart 3.13.5.
This file reports observed results,
not implied production readiness.

| Check | Status |
|---|---|
| Backend tests | 38 passed, including billing state/expiry rejection, disabled verification and token-safe errors |
| Backend lint and formatting | Passed |
| Live Uvicorn HTTP smoke check | Passed: health, known/unknown DTC, manual result, mock result and safety priority |
| OpenAPI and Flutter fixture freshness | Passed in backend contract tests |
| Migration, seed and ownership SQL syntax | Parsed successfully with PostgreSQL parser (pglast 8.5) |
| Supabase migrations and RLS execution | Not run; no Supabase/PostgreSQL instance or credentials provided |
| Flutter analysis | Passed, no issues |
| Flutter tests | Full suite: 55 passed, one gate test skipped in the default non-billing configuration. Targeted BLE retest: 6 passed, including one additional dashboard-return/session-ownership test. 56 distinct default-mode tests passed across these runs. |
| Subscription gate test | Separately passed with ENABLE_SUBSCRIPTIONS=true: unverified access blocked; privacy remains reachable |
| Live Google Play billing / renewals / refunds | Not tested; Play account, products and service credentials absent; checkout disabled in review builds |
| Flutter platform wrappers | Android, iOS and web generated; debug networking configured |
| Flutter web build | Passed; compiled preview supplied in demo/web (local API URL) |
| Desktop browser at 390×844 | Passed: redesigned home/dashboard, mass input, confirmation and complete 10-second simulated run; 48 samples, result shown, no browser errors |
| Browser interaction on real phones | Not run |
| Android APK | Version 0.1.0+3 debug APK built; apksigner verified and certificate matches earlier APK; min SDK 24 / target SDK 36; ARM32, ARM64 and x86_64 included. APK ZIP and static 64-bit ELF alignment checks passed. |
| Android release AAB | Version 0.1.0+3 built; unsigned review output, checkout disabled; static 64-bit ELF alignment checks passed; no Play upload or 16 KB runtime test |
| Android physical-device installation / launch | User reported installing the earlier APK and reaching BLE setup. Updated automatic-connect APK requires retest. No adb instrumentation or verified ECU data. |
| iOS native build | Not run; macOS/Xcode unavailable |
| Docker image | Not built; Docker unavailable |
| Physical BLE / Wi-Fi adapter / vehicle | Experimental software implemented; no hardware testing or compatibility established |

Backend environment is captured in `backend/requirements.lock.txt`. The installed
Starlette test client emitted an upstream HTTPX deprecation warning; all assertions
passed. No real vehicle data or hosted database was accessed.

The supplied SQL test should run against a disposable Supabase project before
connecting any real users. It covers owner visibility, cross-user reads/writes,
forbidden parent links, anonymous access, and result deletion cascade, then rolls
back its test data. Syntax parsing does not establish RLS behavior.

Repeat backend checks and the mobile checks using README commands. Hardware
validation requires the evidence matrix in `BLE_PLAN.md`; automated mock tests
cannot prove adapter compatibility or mechanical diagnostic accuracy.
