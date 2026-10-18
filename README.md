# AutoSense AI — executable MVP starter

Google Play preparation is in [play-store/README.md](play-store/README.md):
turbo branding, listing and privacy drafts, data-safety inventory, signing setup,
release commands and outstanding account/hosting/test requirements. Nothing has
been submitted or published. Private upload credentials must stay outside archives.

Flutter iOS/Android app + FastAPI diagnostic guidance + Supabase-ready SQL + a mock
OBD adapter plus experimental BLE / Wi-Fi drivers. Run locally without Supabase, API keys,
an AI subscription, or a scanner. The name is AutoSense AI; the shipped engine is
transparent **deterministic demo rules**, not an AI model or a validated diagnostic tool.

## Included

- Home, vehicle/manual DTC + symptom input, safety checklist, mock adapter discovery
  and scan review, structured results, DTC library, session history and configuration.
  Vehicle menus include make-dependent models and a year picker. The mock scanner
  auto-fills a clearly simulated car, and supports confirmed clearing of demo codes.
  An HP/torque calculator converts known torque or mechanical horsepower at a supplied RPM.
- Eight generic DTC definitions: P0300, P0301, P0171, P0420, P0442, P0455, P0128, U0100.
  Unknown valid codes remain unknown; malformed input produces validation errors.
- Possible causes with evidence, all explicitly unconfirmed; next checks, urgency
  reasons, limitations, engine version and simulation provenance.
- Owner-isolated Supabase schema, seed data and a rollback-only SQL ownership test.
- API/unit/widget tests, OpenAPI snapshot, Docker option and CI configuration.

**Boundaries:** physical BLE and Wi-Fi code is experimental and untested on hardware.
There are no tested adapter compatibility claims, definitive diagnoses, physical code clearing, Supabase Auth,
cloud persistence or AI inference. History lasts only for the current app session.
Free-text notes are accepted but require human review and leave urgency unassessed.
Vehicle fields do not make the generic rules vehicle-specific. Use only while parked.

## 1. Start the backend

Requirements: Python 3.11+, Flutter stable (Dart 3.6+), and the target platform tools.
Native Android requires API 24+ and compile SDK 37 for the pinned BLE/permission
plugins. iOS requires a Mac with Xcode. Android debug APK and unsigned release AAB
builds have passed; iOS native builds have not run here.
On Windows, extract to a short path such as `C:\src\autosense-ai` to avoid platform
toolchain path-length limits.
Use [Flutter's official installation guide](https://docs.flutter.dev/install/custom).
iOS builds require macOS with Xcode; Android requires its SDK/toolchain.

From this project's root in PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r backend/requirements.lock.txt
.\.venv\Scripts\python.exe -m pip install -e 'backend[dev]'
Copy-Item backend/.env.example backend/.env
Set-Location backend
..\.venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

macOS/Linux, from the project root:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r backend/requirements.lock.txt
.venv/bin/python -m pip install -e 'backend[dev]'
cp backend/.env.example backend/.env
cd backend
../.venv/bin/python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Keep that terminal running. Open `http://127.0.0.1:8000/docs` for interactive API
documentation or `/health` for a health check. `.env` is read from the backend working
directory. The lock snapshot records the tested Python environment; `pyproject.toml`
contains allowed version ranges. Review dependency updates before adopting them.

Optional instead: `docker compose up --build` from the root. Docker is not required.
The provided container mapping binds to localhost for local development.

## 2. Start Flutter

From a new terminal at the project root:

```sh
cd mobile
flutter doctor
flutter pub get
flutter devices
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

If platform folders have not been generated, first run in `mobile`:

```sh
flutter create --platforms=android,ios,web --org com.autosense --project-name autosense_ai .
python ../scripts/configure_platforms.py
```

Keep the starter's `lib/`, `test/` and `pubspec.yaml`; do not replace them with the
Flutter counter sample. The platform configuration helper is idempotent.

| Target | API_BASE_URL | Notes |
|---|---|---|
| Android emulator | `http://10.0.2.2:8000` | Host loopback alias; debug HTTP enabled |
| iOS simulator | `http://localhost:8000` | Run backend on the same Mac; use HTTPS if ATS blocks local HTTP |
| Browser preview | `http://localhost:8000` | Run at port 3000 to match default CORS |
| Physical phone | `https://your-dev-api.example` | HTTPS preferred; no production URL is supplied |

For a private Android LAN test, start the backend with `--host 0.0.0.0` and use your
computer's LAN IP (for example `http://192.168.1.20:8000`). Both devices must share a
network and the firewall must permit that port. This unauthenticated local demo
should not be exposed publicly. iOS physical-device HTTP/local-network settings need
explicit device validation; a reachable HTTPS development API avoids ATS exceptions.

Environment-file option: copy `mobile/config/example.json` to `local.json`, edit its
address, and launch with `flutter run --dart-define-from-file=config/local.json`.
Do not put secrets in Dart defines: these values are compiled into the client.
Browser demo: `flutter run -d chrome --web-port=3000 --dart-define=API_BASE_URL=http://localhost:8000`.

### Included browser preview without Flutter

The archive also includes a compiled copy of the same Flutter app in `demo/web`.
Start the backend from step 1, then from the project root run:

```sh
python -m http.server 3000 --bind 127.0.0.1 --directory demo/web
```

Open `http://127.0.0.1:3000` in your browser. This preview points to
`http://localhost:8000`. Manual guidance needs the API; the live demo/run estimate work locally.
If an older preview is cached at localhost, use the 127.0.0.1 URL for the updated copy.
Serve it over HTTP as shown; opening `index.html` directly will not work reliably.
To change its API address, rebuild the Flutter web app with a different
`API_BASE_URL` and replace `demo/web` with the contents of `mobile/build/web`.
The included preview was compiled successfully; browser/device interaction outside
the automated widget tests remains to be verified.

## 3. Try the flows

1. Choose **Enter codes or symptoms**; optionally select make, model, and year from
   the menus, then enter `P0300`, or select **Rough idle**. Model choices follow the
   selected make. Lists contain common examples; use **Other / not listed** if needed.
2. Review the safety checklist; choose **Get preliminary guidance**. Read possible
   causes, evidence, next steps, limitations and safety advice.
3. Return home; the result appears in temporary session history. **Clear** removes it.
4. Choose **Try mock OBD scan**, discover the demo adapter, then tap it. Review the
   prefilled simulated car (2020 Toyota Corolla), codes and safety checklist.
   Results retain the SIMULATED label. The manual form's **Auto-detect car (demo)**
   button opens this same flow; real VIN reading/decoding is not implemented.
   **Clear codes (demo)** asks for confirmation and clears only that mock adapter's
   codes for the current demo session. It never changes a real check-engine light.
5. In **DTC library**, try `P0420`, unknown `P1234`, and malformed `P9999`.
6. Open **HP & torque calculator**. Choose torque → HP or HP → torque, enter
   a known value and its RPM, then calculate. For example, 200 N·m at 3,000 RPM
   gives approximately 84.3 mechanical hp / 62.8 kW. This is a calculation from
   supplied inputs, not measured vehicle performance. The calculator applies no
   engine/wheel drivetrain-loss correction and does not estimate peak output.

The calculator uses `P(W) = T(N·m) × 2π × RPM / 60`, mechanical hp = W / 745.6999,
and 1 lb·ft = 1.355818 N·m. Units follow
[NIST SP 811 conversion factors](https://www.nist.gov/pml/special-publication-811/nist-guide-si-appendix-b-conversion-factors/nist-guide-si-appendix-b8).
Mechanical horsepower differs from metric PS. Use torque and RPM from the same
operating point; peak torque and peak horsepower may occur at different RPM.

API example in PowerShell:

```powershell
$payload = @{ codes=@('P0300'); symptoms=@('rough_idle'); safety_check_completed=$true } | ConvertTo-Json
Invoke-RestMethod http://127.0.0.1:8000/v1/diagnostics -Method Post -ContentType application/json -Body $payload
Invoke-RestMethod http://127.0.0.1:8000/v1/dtc/P0420
```

Or with curl on macOS/Linux:

```sh
curl http://127.0.0.1:8000/v1/diagnostics -H 'Content-Type: application/json' \
  -d '{"codes":["P0300"],"symptoms":["rough_idle"],"safety_check_completed":true}'
```

## Live dashboard and automatic performance recording

**Open live dashboard** starts a clearly labelled demo stream in the browser or
phone app. Large RPM gauge, selectable speed/coolant/throttle cards and RPM trend
use navy, mint, amber and violet. Missing/stale values show `—`.

**Connect a scanner • Bluetooth / Wi-Fi** opens the transport menu. BLE discovery,
connection and service inspection are implemented for native Android/iOS. Selecting
an adapter automatically matches a documented UART profile and verifies an ELM
identity before opening a connected menu with Live dashboard and Diagnose. Unknown
profiles fail with a troubleshooting report; no RX/TX selection is required. See
[automatic BLE setup](docs/BLE_AUTO_CONNECT.md). Wi-Fi uses ELM ASCII over TCP: join its
network in phone settings and enter the documented host and port. Browser previews
cannot use these native transports. No physical hardware compatibility is verified.

Current physical protocol subset: ISO 15765-4 CAN, ELM protocols 6–9. Stored DTCs
retain ECU identifiers and a bounded transcript. Live speed, RPM, supported coolant
and absolute throttle come from one ECU advertising speed/RPM. Other scanners can
implement `ObdAdapter` / `LiveObdAdapter`. Bluetooth Classic, USB, OBD-I, non-CAN and
proprietary protocols need separate documented drivers and are not yet supported.
Real clearing and automatic make/model/VIN decoding remain unavailable.

For a **10-second run**, enter total vehicle + occupants + cargo mass, confirm
demo/closed-course conditions, and start recording. Speed and RPM are recorded
automatically; horsepower/torque inputs are unnecessary. The app does not control
the throttle. Prepare while stationary; an operator handles the app on a closed course.

The estimate is **net translational acceleration power**:
`P = Δ(½ m v²) / Δt`, with speed in m/s and mechanical hp = W / 745.6999. It shows
whole-run average and a peak window of at least one second. The torque number is
**RPM-referred equivalent torque at the peak-power window** (`P/ω`), not measured
engine or axle torque. This is not engine/crank hp, total wheel hp or a dyno.
Slope, wind, drag, rolling resistance, rotating inertia, shifts and drivetrain loss
are not corrected. Full throttle alone cannot establish true engine power/torque.
See [kinetic-energy definition](https://openstax.org/books/university-physics-volume-1/pages/7-2-kinetic-energy).

Quality gates reject fewer than 20 readings, gaps above one second, nonmonotonic
timestamps, speed/RPM skew above 750 ms, mixed simulated/real sources, invalid
numbers, large speed discontinuities, sampled coverage outside 8–12 seconds, or
less than 10 km/h net speed gain. Backgrounding, stale readings and connection
failure cancel recording. Slow adapters may produce no estimate. Software gates
do not validate physical accuracy. Run data can be copied as CSV and stays in
screen memory until closed. Try the complete run with the simulator first.

## Tests and builds

From the root (on macOS/Linux replace the Python executable with `.venv/bin/python`):
Keep the API running for `smoke_api.py`; the other tests run without a server.

```powershell
.\.venv\Scripts\python.exe -m pytest backend/tests -q
.\.venv\Scripts\python.exe -m ruff check backend
.\.venv\Scripts\python.exe -m ruff format --check backend
.\.venv\Scripts\python.exe scripts/smoke_api.py
.\.venv\Scripts\python.exe scripts/export_contracts.py
Set-Location mobile
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

iOS on a Mac: `flutter build ios --simulator --dart-define=API_BASE_URL=http://localhost:8000`.
For release, use HTTPS, your own bundle IDs, signing keys and store configuration;
debug signing and local networking are development settings. The starter is not a
store-ready release. See [verification status](docs/VERIFICATION.md) for what actually ran.

## Optional Supabase setup

Create a disposable Supabase project. In the SQL editor, run
`supabase/migrations/202610120001_initial.sql`, then
`supabase/migrations/202610120002_ble_source.sql`, then `supabase/seed.sql` as an admin.
For an existing Supabase CLI project, copy both migrations into its migration folder
and use its normal migration workflow. Do not run the initial migration twice.
Run `supabase/tests/ownership.sql` on the disposable database as admin to exercise
two-user isolation and forbidden relationships. It rolls back all test records.

The app and API intentionally do not consume Supabase credentials yet. A migration
does not activate persistence. Implement Auth and token verification before adding
remote history. See [architecture](docs/ARCHITECTURE.md) for the integration sequence.

## Folder structure and first coding tasks

```text
autosense-ai/
  backend/
    app/              # models, catalog, rules, config, routes
    tests/            # API behavior, validation and safety precedence
    .env.example, pyproject.toml, requirements.lock.txt, Dockerfile
  mobile/
    lib/
      main.dart       # home, configuration, in-memory history
      models/         # shared input/result models
      screens/        # dashboard, BLE/Wi-Fi menu, manual, scan, lookup, results
      services/       # API, driver interfaces, BLE/TCP, ELM protocol, mock
      widgets/        # shared safety notice
    test/             # contract fixture, model/API/adapter/widget tests
    config/           # compile-time environment example
    android/, ios/, web/  # platform wrappers; can regenerate with Flutter
  supabase/           # migration, seed, ownership tests
  scripts/            # export contracts, configure platform networking
  docs/               # architecture, BLE plan, milestones/costs, OpenAPI, verification
  demo/web/           # compiled browser preview of the same Flutter client
  .github/workflows/ci.yml
  compose.yaml
```

Begin in `backend/app/diagnostics.py` and `mobile/lib/screens/manual_screen.dart`.
Add reviewed content to `catalog.py`, regenerate contracts, and test unknown/error
cases. Next implement Auth + persistence; then a single documented BLE profile.
See [milestones and costs](docs/MILESTONES_AND_COSTS.md) and [BLE plan](docs/BLE_PLAN.md).

References: [Flutter creation](https://docs.flutter.dev/reference/create-new-app),
[FastAPI tests](https://fastapi.tiangolo.com/tutorial/testing/),
[Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security),
[EPA OBD background](https://nepis.epa.gov/Exe/ZyPURL.cgi?Dockey=P1009Z15.TXT).
The eight-code catalog is original demo content, not a reproduced standards database.
Review OEM definitions, local requirements and content licensing before public use.
