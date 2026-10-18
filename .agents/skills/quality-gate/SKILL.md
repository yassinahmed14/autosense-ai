---
name: quality-gate
description: >-
  Runs the full AutoSense AI verification suite (API lint/format/tests, contract
  export, Flutter analyze/format/tests, debug APK build). Use this skill before
  declaring any code change complete, before committing, or when the user asks
  to "check", "verify" or "test everything".
---

# Quality gate

Run from the repository root in PowerShell. Stop and fix at the first failure.

```powershell
. .\scripts\dev_env.ps1
.\scripts\quality_gate.ps1            # everything
.\scripts\quality_gate.ps1 -Only api  # just the API
.\scripts\quality_gate.ps1 -Only app  # just the Flutter app
.\scripts\quality_gate.ps1 -SkipBuild # skip the APK build (faster)
```

What it runs:

| Area | Checks |
|---|---|
| API | `ruff check`, `ruff format --check`, `pytest api/tests` |
| Contracts | `scripts/export_contracts.py` then `git diff --exit-code` on generated files |
| App | `flutter pub get`, `dart format --set-exit-if-changed lib test`, `flutter analyze`, `flutter test` |
| Build | `flutter build apk --debug` |

Success = script exits 0 and prints `QUALITY GATE PASSED`.
If generated contract files changed, review and commit them — the fixture in
`app/test/fixtures/result.json` must match the API.
