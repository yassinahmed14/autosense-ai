<#
.SYNOPSIS
  Builds the Flutter web app against a given API and deploys it to Vercel (free Hobby plan).
.EXAMPLE
  . .\scripts\dev_env.ps1; .\scripts\deploy_web.ps1 -ApiUrl https://autosense-api.vercel.app
#>
param(
    [Parameter(Mandatory)] [string]$ApiUrl,
    [string]$Project = 'autosense-web',
    [switch]$Preview
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$env:npm_config_cache = 'D:\CodexWork\npm-cache'
$ApiUrl = $ApiUrl.TrimEnd('/')

Push-Location (Join-Path $root 'app')
try {
    flutter build web --release --dart-define=API_BASE_URL=$ApiUrl
    if ($LASTEXITCODE -ne 0) { throw 'flutter build web failed' }
    $web = Join-Path (Get-Location) 'build\web'
    # SPA fallback + long cache for hashed assets
    @'
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }],
  "headers": [
    { "source": "/assets/(.*)", "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }] }
  ]
}
'@ | Set-Content -Encoding utf8 (Join-Path $web 'vercel.json')
    Push-Location $web
    try {
        $prodFlag = if ($Preview) { @() } else { @('--prod') }
        npx --yes vercel@latest deploy @prodFlag --yes --name $Project
        if ($LASTEXITCODE -ne 0) { throw 'vercel deploy failed' }
    } finally { Pop-Location }
} finally { Pop-Location }
