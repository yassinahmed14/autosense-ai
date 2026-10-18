<#
.SYNOPSIS
  Runs every AutoSense AI check. Exits non-zero on the first failure.
.EXAMPLE
  . .\scripts\dev_env.ps1; .\scripts\quality_gate.ps1 -SkipBuild
#>
param(
    [ValidateSet('all', 'api', 'app')] [string]$Only = 'all',
    [switch]$SkipBuild
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$python = Join-Path $root '.venv\Scripts\python.exe'
if (-not (Test-Path $python)) { $python = 'python' }

function Step([string]$name, [scriptblock]$block) {
    Write-Host "`n==> $name" -ForegroundColor Cyan
    & $block
    if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: $name" -ForegroundColor Red; exit $LASTEXITCODE }
}

Push-Location $root
try {
    if ($Only -in 'all', 'api') {
        Step 'API lint' { & $python -m ruff check api scripts }
        Step 'API format' { & $python -m ruff format --check api scripts }
        Step 'API tests' { & $python -m pytest api/tests -q }
        Step 'Export contracts' { & $python scripts/export_contracts.py }
        Step 'Contracts unchanged' {
            git diff --exit-code -- docs/architecture/openapi.json app/test/fixtures/result.json infra/supabase/seed.sql
        }
    }
    if ($Only -in 'all', 'app') {
        Push-Location app
        try {
            Step 'Flutter pub get' { flutter pub get }
            Step 'Dart format' { dart format --output=none --set-exit-if-changed lib test }
            Step 'Flutter analyze' { flutter analyze }
            Step 'Flutter tests' { flutter test }
            if (-not $SkipBuild) {
                Step 'Debug APK' { flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000 }
            }
        } finally { Pop-Location }
    }
    Write-Host "`nQUALITY GATE PASSED" -ForegroundColor Green
} finally { Pop-Location }
