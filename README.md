# AutoSense AI — Vehicle Diagnostics & Live Telemetry

AutoSense AI is a 100% free, multi-platform vehicle diagnostic and live telemetry
application built with **Flutter** (`app/`) and **FastAPI** (`api/`), featuring the
**Racing Yellow & Carbon** showroom design system ([DESIGN.md](DESIGN.md)), a
56-code generic SAE J2012 catalog across all four vehicle systems (`P`, `B`, `C`, `U`),
a 35-brand global vehicle selector, and **Hybrid Smart Mode** (cloud API with
automatic `<5ms` on-device offline fallback for underground garages and Wi-Fi OBD
dongles).

- **Project Memory & Mentor Mode:** [CLAUDE.md](CLAUDE.md) and [AGENTS.md](AGENTS.md)
- **Visual Design System:** [DESIGN.md](DESIGN.md)
- **Backend API Documentation:** [api/README.md](api/README.md)
- **Mobile & Web App Documentation:** [app/README.md](app/README.md)
- **Google Play Preparation:** [distribution/google-play/README.md](distribution/google-play/README.md)

---

## 1. What Is Included

- **100% Free Forever Edition:** Every diagnostic, catalog, telemetry, and calculator
  feature is unlocked at zero cost.
- **Hybrid Smart Mode (Cloud + Instant Offline Engine):** Calls the configured
  FastAPI service first (`https://autosense-api.vercel.app` or local API) and
  automatically falls back in `<5ms` to the built-in 56-code `OfflineDiagnosticEngine`
  when offline or connected to a Wi-Fi ELM327 adapter without internet.
- **56 Generic SAE J2012 DTC Definitions (`P`, `B`, `C`, `U`):**
  - **Powertrain (`P0xxx` / `P0Axx`):** Misfire, fuel trim, MAF/MAP/O2/ECT/IAT/TPS
    sensors, catalyst, EVAP, EGR, speed/idle control, system voltage, transmission,
    and hybrid/EV battery pack alerts.
  - **Chassis / ABS (`C0xxx`):** Wheel speed sensors and brake pedal switch.
  - **Body / SRS (`B0xxx`):** Frontal and side airbag squib circuit guidance.
  - **Network / CAN (`U0xxx`):** Lost communication with ECM/PCM, TCM, ABS, BCM, and IPC.
  - Unknown valid codes (`P1234`) remain explicitly uninvented; malformed inputs
    (`P9999`) return validation errors.
- **35 Global Vehicle Brands (1900–present):** Audi, BMW, BYD, Chery, Chevrolet,
  Citroen, Dacia, Dodge, Fiat, Ford, Geely, GMC, Honda, Hyundai, Jeep, Kia,
  Land Rover, Lexus, Mazda, Mercedes-Benz, MG, Mitsubishi, Nissan, Opel, Peugeot,
  Porsche, Renault, Seat, Skoda, Subaru, Suzuki, Tesla, Toyota, Volkswagen, Volvo,
  plus `Other / not listed`.
- **Live Telemetry Dashboard & 10-Second Performance Estimator:**
  - 240° Saira tabular-numeral RPM gauge, toggleable Speed (`km/h`), Coolant (`°C`),
    and Throttle (`%`) metric cards, and live RPM trend chart.
  - Automatic 10-second acceleration power estimator (`P = Δ(½ m v²) / Δt`) with
    strict sample quality gates and 1-tap CSV export.
- **OBD-II Scanner Transports & Multi-Protocol Reference:**
  - Built-in Mock OBD Simulator (`2020 Toyota Corolla`), native Bluetooth LE
    auto-connect (`BleObdAdapter`), and Wi-Fi ELM327 ASCII-over-TCP (`WifiObdAdapter`),
    plus pre-inspection emissions readiness monitor reference.
- **HP & Torque Calculator:** Bidirectional NIST SP 811 conversion between torque
  (`N·m` or `lb·ft`) and mechanical horsepower / kilowatts at any RPM.

**Safety & Boundaries:** All outputs are **preliminary guidance only**, never a
definitive diagnosis or a determination that driving is safe. Physical BLE/Wi-Fi
drivers require a compatible ELM327 CAN adapter and vehicle ignition on. Use only
while safely parked.

---

## 2. Repository Structure

```text
autosense-ai/
├─ AGENTS.md                  # AI agent instructions + Mentor Mode + UTF-8 rules
├─ CLAUDE.md                  # Living project memory & beginner glossary
├─ DESIGN.md                  # "Racing Yellow & Carbon" light UI specification
├─ README.md                  # Quick-start & architecture guide (this file)
├─ .agents/skills/            # Agent skills (quality-gate, android-emulator-qa, deploy-vercel...)
├─ api/                       # FastAPI backend (Python 3.11+)
│  ├─ src/autosense_api/      # main.py, core/, routers/, schemas/, services/, data/
│  ├─ tests/                  # unit/ and integration/ pytest suites (70 tests)
│  ├─ index.py                # Vercel serverless Python entrypoint
│  └─ pyproject.toml          # Dependencies, ruff & pytest config
├─ app/                       # Flutter mobile & web client (Dart 3.6+)
│  ├─ lib/
│  │  ├─ core/                # config/, network/, routing/, theme/, utils/
│  │  ├─ features/            # home, dashboard, diagnostics, scanner, calculator,
│  │  │                       # subscription, privacy, settings
│  │  └─ shared/widgets/      # Reusable showroom UI components
│  ├─ assets/                 # Saira & Inter OFL fonts + hero_car.png supercar studio art
│  └─ test/                   # Unit, protocol, contract & widget tests (68 tests)
├─ infra/
│  ├─ compose.yaml            # Optional local Docker Compose stack
│  └─ supabase/               # PostgreSQL migrations, 56-code seed.sql & RLS tests
├─ distribution/
│  └─ google-play/            # Store listing, data-safety, privacy policy & signing guide
├─ docs/                      # Architecture, OpenAPI snapshot, BLE protocol & verification
└─ scripts/                   # dev_env.ps1, quality_gate.ps1, export_contracts.py, smoke_api.py
```

---

## 3. Quick Start (Windows PowerShell)

### Step 1: Load the workspace environment (`D:` drive caches & SDK paths)

```powershell
. .\scripts\dev_env.ps1
```

### Step 2: Run the full quality gate (API + Contracts + Flutter Analyze + 138 Tests)

```powershell
.\scripts\quality_gate.ps1 -SkipBuild
```

### Step 3: Start the FastAPI backend locally (or use the live Vercel API)

```powershell
$env:PYTHONPATH = "$PWD\api\src"
.\.venv\Scripts\python.exe -m uvicorn autosense_api.main:app --reload --host 0.0.0.0 --port 8000
```

- Local health check: `http://127.0.0.1:8000/health`
- Interactive Swagger UI: `http://127.0.0.1:8000/docs`
- Live production API (Vercel Hobby): `https://autosense-api.vercel.app/health`

### Step 4: Run or build the Flutter app

```powershell
Set-Location app
# Run on Android emulator or connected wireless tablet:
flutter run --dart-define=API_BASE_URL=https://autosense-api.vercel.app

# Build debug APK:
flutter build apk --debug --dart-define=API_BASE_URL=https://autosense-api.vercel.app
```

| Target | Recommended `API_BASE_URL` | Notes |
|---|---|---|
| Live Cloud (All devices) | `https://autosense-api.vercel.app` | Works everywhere + automatic `<5ms` offline fallback |
| Android Emulator (Local) | `http://10.0.2.2:8000` | Host loopback alias to local uvicorn server |
| Physical Device on LAN | `http://192.168.100.7:8000` | Host PC Wi-Fi IP with `--host 0.0.0.0` |
| Offline / Garage Mode | Any URL | Automatically falls back to on-device `OfflineDiagnosticEngine` |

---

## 4. Testing on Android Emulator & Physical Wireless Tablet

Use the included UI automation driver (`.agents/skills/android-emulator-qa/scripts/adb_ui.py`)
to inspect accessibility nodes, tap buttons, scroll, capture screenshots, and verify
zero `AndroidRuntime` crashes:

```powershell
. .\scripts\dev_env.ps1
$env:ADB_SERIAL = "emulator-5554"          # or wireless tablet "192.168.100.199:48729"
python .agents/skills/android-emulator-qa/scripts/adb_ui.py launch
python .agents/skills/android-emulator-qa/scripts/adb_ui.py texts
python .agents/skills/android-emulator-qa/scripts/adb_ui.py crashes
```

See [docs/release/verification-history.md](docs/release/verification-history.md) and [CLAUDE.md](CLAUDE.md)
for the latest verification report across both `emulator-5554` (Pixel 7 API 36) and
the physical Samsung tablet (`GT-N8000`, Android 11).
