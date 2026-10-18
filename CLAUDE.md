# CLAUDE.md — AutoSense AI project context

> **Last updated:** 2026-10-18 — v1.0.0+6 Google Play Ready: Signed Release `.aab` (`AutoSense-AI-v1.0.0+6-release-signed.aab`), live HTTPS Privacy Policy & Terms (`https://autosense-api.vercel.app/privacy` & `/terms`), Freemium + AutoSense Pro (`EGP 99/mo` & `EGP 999/yr` + 3-day trial), 56-code SAE J2012 catalog (`P`/`B`/`C`/`U`), 35 global car brands, Hybrid Smart Mode (`<5ms` offline engine + cloud API), 140 passing tests, and verified on both Pixel 7 emulator (`emulator-5554`) and wireless Samsung tablet (`GT-N8000`).
>
> This file is the project's "memory". AI agents read it automatically
> (via `AGENTS.md`) and **must update it after every meaningful change**.
> Humans: read this first.

## 1. What is this?

**AutoSense AI** is a Freemium + Pro car-diagnostics and live telemetry app. You plug an OBD-II
scanner into your car (or use the built-in simulator), and the app:

- reads 56 generic trouble codes across all 4 vehicle systems (`P` Powertrain, `C` Chassis/ABS, `B` Body/SRS, `U` Network/CAN) and explains them in plain language,
- supports 35 global car brands (1900–present) across North American, European, Asian, and EV/Hybrid makes,
- runs in **Hybrid Smart Mode** (cloud API first, with automatic `<5ms` on-device offline fallback for underground garages or Wi-Fi OBD adapters),
- shows a live dashboard (RPM, speed, coolant, throttle) and pre-inspection emissions readiness guide,
- estimates power from a 10-second acceleration run and converts horsepower ↔ torque.

It gives **preliminary guidance only** — never a definitive diagnosis.

| Part | Tech | Folder |
|---|---|---|
| Mobile/web app | Flutter (Dart) + `OfflineDiagnosticEngine` | `app/` |
| Backend API | Python FastAPI | `api/` |
| Database schema (optional) | Supabase / Postgres (56-code seed) | `infra/supabase/` |
| Store listing & policies | Markdown/HTML | `distribution/google-play/` |

## 2. Status at a glance

| Item | Status |
|---|---|
| App version | **1.0.0+6** (Freemium + AutoSense Pro: `EGP 99/mo` or `EGP 999/yr` + 3-day trial) |
| API live URL | **`https://autosense-api.vercel.app`** (live & smoke-tested on Vercel Hobby) |
| Live Legal URLs | **`https://autosense-api.vercel.app/privacy`** & **`https://autosense-api.vercel.app/terms`** (`youssefahmed4010@gmail.com`) |
| Signed Google Play `.aab` | **`D:\AutoSense AI\releases\AutoSense-AI-v1.0.0+6-release-signed.aab`** (`52.4 MB`, signed with `autosense-upload.jks`) |
| Android Debug APK | `D:\AutoSense AI\releases\AutoSense-AI-v1.0.0+6-debug.apk` |
| Emulator QA | **Passed (0 crashes)** on `emulator-5554` (Pixel 7, API 36, `1080x2400`) |
| Wireless Tablet QA | **Passed (0 crashes)** on `192.168.100.199:48729` (Samsung `GT-N8000`, Android 11, `1280x800`) |
| Automated Tests | **140 passed** (`71` FastAPI `pytest` + `69` Flutter unit/widget/protocol tests; `0` lint issues) |
| Bluetooth/Wi‑Fi scanner | BLE + Wi-Fi ELM327 drivers & unit tests verified; physical car ECU test requires plugging adapter into a real car |

## 3. Repository map

```text
autosense-ai/
├─ AGENTS.md            Rules every AI agent follows (includes this file)
├─ CLAUDE.md             ← you are here: project memory
├─ DESIGN.md            Design system: colors, fonts, spacing, components
├─ README.md            Quick start for humans
├─ .agents/skills/      Step-by-step runbooks for agents (quality gate, QA, deploy…)
├─ api/                 Backend (FastAPI) — see api/README.md
│  ├─ src/autosense_api/  core/ routers/ schemas/ services/ data/ (56-code catalog)
│  └─ tests/              unit/ integration/ (70 tests)
├─ app/                 Flutter app — see app/README.md
│  ├─ lib/core/           config, theme, network (Hybrid Smart Mode), routing
│  ├─ lib/features/       home, diagnostics (OfflineDiagnosticEngine), scanner,
│  │                      dashboard, calculator, subscription, settings, privacy
│  ├─ lib/shared/         reusable widgets
│  └─ test/               mirrors lib/ (68 tests)
├─ infra/               compose.yaml (Docker), supabase/ (SQL migrations + 56-code seed)
├─ distribution/        google-play/ listing, privacy policy, assets
├─ docs/                architecture/, hardware/, setup/, release/
└─ scripts/             dev_env.ps1, quality_gate.ps1, export_contracts.py, smoke_api.py
```

Outside the repo (in `D:\AutoSense AI\`): `releases/` (built APK/AAB),
`_archive/` (old copies of the project — safe to delete later).

## 4. Commands (Windows PowerShell, from repo root)

```powershell
. .\scripts\dev_env.ps1                    # ALWAYS first: sets PATH + moves caches to D:
.\scripts\quality_gate.ps1 -SkipBuild      # run every check (lint, contracts, 138 tests)
# API locally
.\.venv\Scripts\python.exe -m uvicorn autosense_api.main:app --reload --app-dir api/src
# Run on emulator or wireless tablet
cd app; flutter run -d 192.168.100.199:48729 --dart-define=API_BASE_URL=https://autosense-api.vercel.app
```

## 5. Environments & config

| Setting | Where | Example |
|---|---|---|
| `API_BASE_URL` | Flutter `--dart-define` | `https://autosense-api.vercel.app` (live cloud + automatic `<5ms` offline fallback) |
| `ENABLE_SUBSCRIPTIONS` | Flutter `--dart-define` | `false` (default — 100% Free Forever Edition) |
| `CORS_ORIGINS`, `APP_ENV` | API env vars | see `api/README.md` |

Dev machine quirk: **drive C: is almost full**, so Gradle, temp files, AVDs
and npm cache live on `D:\CodexWork\…` (handled by `dev_env.ps1`).

## 6. Tooling available to agents

- **Skills** (`.agents/skills/`): `quality-gate`, `update-claude-md`,
  `android-emulator-qa`, `deploy-vercel`, `add-flutter-feature`.
- **MCP servers** (global config `~/.gemini/config/mcp_config.json`):
  `context7` (up-to-date library docs), `vercel`, `supabase`,
  `mobile` (control emulator/phone), `playwright` (control a browser).

## 7. Known hardware boundaries / optional next steps

- **Physical Car ECU Test:** Plugging a real BLE or Wi-Fi ELM327 adapter into a vehicle's OBD-II port with ignition ON is the only step that cannot be simulated in software.
- **Second LAN Device (`SM-A075F`):** `adb devices` detected a Samsung Galaxy A07 (`192.168.100.243:5555`) in `unauthorized` state; tap "Allow USB/Wireless debugging" on that phone to install the APK there too.
- **iOS Build:** Requires macOS + Xcode.

## 8. Decision log

- 2026-10-18 — Canonical source = former "Google Play preparation" copy; restructured into `api/`, `app/`, `infra/`, `distribution/`.
- 2026-10-18 — Light theme **"Racing Yellow & Carbon"** (owner's choice): white/silver base, racing-yellow fills, carbon text, Saira + Inter fonts, custom yellow supercar hero image (`DESIGN.md`).
- 2026-10-18 — **Competitor Feature Parity (A2):** Expanded to 56 generic SAE J2012 DTC codes (`P`, `B`, `C`, `U`), interactive offline catalog browser with filter chips, 35 global car brands, and SAE J1979 emissions readiness reference.
- 2026-10-18 — **Hybrid Smart Mode (A3):** `ApiClient` attempts the cloud API first (4s timeout) and automatically falls back in `<5ms` to on-device `OfflineDiagnosticEngine`.
- 2026-10-18 — **Live Cloud Deployment (A4):** Deployed FastAPI backend to Vercel Hobby (`https://autosense-api.vercel.app`) and verified on both `emulator-5554` and wireless tablet `GT-N8000`.
- 2026-10-18 — **Freemium + AutoSense Pro Subscription Fee:** Added **Monthly (`EGP 99/month`, ~$2.99/mo)** and **Annual (`EGP 999/year`, ~$24.99/yr, Save 16%)** plans with a **3-day free trial**. Basic DTC lookup (`56 codes`) and HP calculator are always Free; Pro unlocks Live OBD Scanner, Clear Codes, 10s Dyno Run, and Full AI Guidance, with interactive tablet/demo trial controls plus Google Play Billing support.
- 2026-10-18 — **Google Play Store Package (`prepare google play`):** Generated private Upload Keystore (`D:\AutoSense AI\releases\signing\autosense-upload.jks`), built and verified signed release bundle (`D:\AutoSense AI\releases\AutoSense-AI-v1.0.0+6-release-signed.aab`), deployed live HTTPS `/privacy` and `/terms` pages on Vercel (`youssefahmed4010@gmail.com`), and updated `distribution/google-play/` with real phone and 10-inch tablet screenshots.

## 9. Working with the owner

The owner is **new to software development**. Agents use *mentor mode*
(see `AGENTS.md` §0): plain language, explain each concept in 1–3
sentences, and ask decisions as simple multiple-choice questions with a
recommended option.

## 10. Glossary (the owner's dictionary — add a line for each new concept)

| Term | Simple meaning |
|---|---|
| **App (frontend)** | What users see and tap on their phone/tablet. Here: Flutter in `app/`. |
| **API (backend)** | The app's "waiter": the phone asks it a question, it fetches the answer from the server. Here: `api/`. |
| **Freemium & Paywall** | Giving basic tools for free (like DTC code lookup & HP calculator) so anyone can use the app, while showing an upgrade sheet ("paywall") when someone taps a Pro feature. |
| **Upload Keystore (`.jks`)** | Your private digital passport (`autosense-upload.jks`) that stamps your `.aab` file so Google Play knows every update truly comes from you. |
| **Hybrid Smart Mode (Offline Fallback)** | A backup brain built right inside the app: if your phone has no internet in a garage, the app answers in under 5 milliseconds by itself. |
| **SAE J2012 (`P`, `B`, `C`, `U` codes)** | The world standard for car trouble codes: **P** = Powertrain (engine/gearbox), **C** = Chassis (ABS/brakes), **B** = Body (airbags), **U** = Network (computer wiring). |
| **Readiness Monitors (SAE J1979)** | Self-tests your car's computer runs while you drive to prove emissions systems work before a government inspection. |
| **Wireless ADB** | A tool that lets your PC install and test apps on your real Android tablet over Wi-Fi without plugging in a USB cable. |
| **Flutter / Dart** | Google's toolkit to build one app for Android, iOS and web; Dart is its language. |
| **FastAPI / Python** | A Python toolkit for building APIs quickly. |
| **Repository (repo) / Git** | The project folder plus a full history of every change, so nothing is ever lost. |
| **Commit** | A saved snapshot of changes with a short message, like a save point in a game. |
| **Emulator** | A pretend Android phone running on your PC for testing. |
| **APK / AAB** | Android install files. APK = install directly; AAB = upload to Google Play. |
| **Vercel** | A cloud hosting company with a free plan; hosts our live API at `https://autosense-api.vercel.app`. |
| **Design system** | One rulebook of colors, fonts and spacing (`DESIGN.md`) so every screen looks consistent. |
