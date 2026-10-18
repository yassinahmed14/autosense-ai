# Verification Record

Updated 2026-10-18 on Windows with Python 3.11.0, Flutter 3.47.7, and Dart 3.13.5.
This file records observed automated and hardware/emulator verification results for **AutoSense AI v1.0.0+6**.

| Check | Status |
|---|---|
| Backend unit & integration tests (`pytest`) | **70 passed** (56 generic SAE J2012 DTC codes across `P`, `B`, `C`, `U`, safety priority rules, billing state/expiry rejection, rate limiting, and OpenAPI contract parity) |
| Backend lint & formatting (`ruff check` + `ruff format --check`) | **Passed** (35 files formatted, 0 lint errors) |
| Live Vercel Production HTTP smoke check (`scripts/smoke_api.py https://autosense-api.vercel.app`) | **Passed**: `/health`, known/unknown DTCs (`P0300`, `B0001`, `C0031`, `U0100`, `P1234`), manual guidance, mock OBD guidance, and critical safety stop-driving priority |
| Local Uvicorn HTTP smoke check (`http://127.0.0.1:8000`) | **Passed** |
| OpenAPI & Flutter fixture freshness (`scripts/export_contracts.py --check`) | **Passed** (`docs/architecture/openapi.json`, `app/test/fixtures/result.json`, `infra/supabase/seed.sql` in sync) |
| Migration, seed (56 codes) & RLS SQL syntax | **Passed** (`infra/supabase/migrations/20260401000000_init.sql`, `infra/supabase/seed.sql`) |
| Supabase live cloud execution | Optional / Not connected; app runs 100% free with stateless cloud API + on-device `OfflineDiagnosticEngine` |
| Flutter static analysis (`flutter analyze`) | **Passed** (0 issues) |
| Dart formatting (`dart format --set-exit-if-changed`) | **Passed** (61 files formatted) |
| Flutter automated test suite (`flutter test`) | **68 passed** (including Hybrid Smart Mode offline fallback tests, 56-code offline catalog browser, 35-brand vehicle selector, 100% Free Forever screen, BLE/Wi-Fi protocol parsers, 10s power estimator, and HP/Torque calculator) |
| Flutter Web release build (`flutter build web --release`) | **Passed** (`app/build/web` compiled against `https://autosense-api.vercel.app`) |
| Android Debug APK (`flutter build apk --debug`) | **Passed**: `D:\AutoSense AI\releases\AutoSense-AI-v1.0.0+6-debug.apk` (`v1.0.0+6`) |
| Android Emulator QA Sweep (`emulator-5554`, Pixel 7 API 36, `1080x2400`) | **Passed**: Installed APK, executed autonomous UI sweep (`qa-shots/emu_01..24`), verified Racing Yellow & Carbon theme, 56-code catalog filters, mock scan, manual guidance, live dashboard, and **0 `AndroidRuntime` crashes** |
| Physical Wireless Android Tablet QA Sweep (`192.168.100.199:48729`, Samsung `GT-N8000`, Android 11, `1280x800`) | **Passed**: Installed APK over Wi-Fi ADB, executed full autonomous UI sweep (`qa-shots/tablet_01..24`), verified landscape layout, live cloud + offline Hybrid Smart Mode, and **0 `AndroidRuntime` crashes** |
| iOS native build | Not run on Windows (requires macOS + Xcode) |
| Physical ELM327 BLE / Wi-Fi adapter plugged into a live car ECU | Software protocol drivers & unit tests verified; physical vehicle CAN bus test requires plugging an ELM327 adapter into a vehicle OBD-II port with ignition ON |
