# AutoSense AI — Flutter Application (`app/`)

Cross-platform client (Android, iOS, Web) built with Flutter 3 / Material 3 and the **Racing Yellow & Carbon** light design system ([`../DESIGN.md`](../DESIGN.md)).

## Architecture (`lib/`)

```text
lib/
├─ main.dart                  # Application entry point
├─ app.dart                   # Root AutoSenseApp widget, theme & subscription gate
├─ core/
│  ├─ config/                 # Compile-time environment configuration (AppConfig)
│  ├─ network/                # HTTP API client (ApiClient)
│  ├─ routing/                # Named route constants & navigation helpers (AppRouter)
│  ├─ theme/                  # AppColors, AppTypography, AppSpacing, AppRadius, AppTheme
│  └─ utils/                  # Display formatters & NIST unit conversions
├─ features/
│  ├─ home/                   # HomeScreen + HomeHeroCard (supercar studio hero)
│  ├─ dashboard/              # Live RPM gauge, telemetry cards, trend chart & 10-s run estimator
│  ├─ diagnostics/            # Manual DTC/symptom form, DTC lookup library & structured result screen
│  ├─ scanner/                # Connection hub, BLE auto-profile scanner, Wi-Fi ELM TCP & mock adapter
│  ├─ calculator/             # Bidirectional HP ↔ torque calculator
│  ├─ subscription/           # Google Play subscription offers, verification & overlay gate
│  ├─ privacy/                # In-app privacy, safety & data-handling disclosures
│  └─ settings/               # Runtime configuration & environment inspection screen
└─ shared/
   └─ widgets/                # SafetyNotice, StatusBanner, SectionHeader, MetricCard,
                              # PrimaryActionButton, SecondaryActionButton, EmptyState, PageListView
```

Tests under `test/` mirror `lib/` (`test/core/`, `test/features/`, plus end-to-end flow tests in `test/widget_test.dart`).

## Commands

Run `. ..\scripts\dev_env.ps1` first on the Windows development workstation so Gradle, Pub, and AVD caches use drive `D:`.

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000
```
