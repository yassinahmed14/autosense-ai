# Release test plan and evidence

Do not count simulated data as a physical adapter test.

## Software checks

Run flutter analyze, flutter test, backend pytest, and an Android release App
Bundle build. Record observed results in VALIDATION.md. Inspect merged permissions,
signature, API target and native library alignment. The Play pre-launch report and
an installed signed release test are still required after upload.

## Device checks (pending unless explicitly recorded)

- Android 7 baseline and Android 11/12+/16: install, start, rotate, background,
  permission refusal/retry, large text, narrow phone/tablet layouts, TalkBack.
- Empty/invalid/unknown codes and unavailable API show clear errors.
- Live demo is labelled simulated; no actual vehicle identity inferred from it.
- Stationary BLE scan/connect/disconnect using vendor-documented serial UUIDs;
  validate ECU replies against another trusted scanner, record raw trace/profile.
- Wi-Fi adapter TCP read, local-network restrictions and lost-network recovery.
- Live values stop/show stale after disconnection; background aborts a run.
- Closed-course run: compare timestamps/sampling and estimates to reference
  instruments. Do not claim engine torque, dyno output, or accuracy without evidence.
- No Mode 04/code clear issued by native drivers. Demo clearing remains simulated.
- HTTPS backend round-trip from cellular/Wi-Fi, policy link and support contact.

## Play test stages

1. Internal test with the signed App Bundle; inspect automated pre-launch report.
2. Resolve crashes, ANRs, accessibility, policy and device-compatibility findings.
3. Where required, recruit at least 12 real testers and keep them opted in for
   14 consecutive days in closed testing. Record feedback and fixes honestly.
4. Apply for production access only after test and readiness requirements are met.

No testers have been contacted, no closed test has started, and no Google test
results exist yet. User reported installing the development APK on Android 11;
this is not an instrumented release or adapter validation.
