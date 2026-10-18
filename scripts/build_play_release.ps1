param(
    [Parameter(Mandatory=$true)][string]$ApiBaseUrl,
    [Parameter(Mandatory=$true)][string]$PrivacyPolicyUrl,
    [Parameter(Mandatory=$true)][string]$TermsUrl,
    [Parameter(Mandatory=$true)][string]$SupportEmail,
    [Parameter(Mandatory=$true)][int]$BuildNumber
)
$ErrorActionPreference = 'Stop'
$mobilePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'mobile'
foreach ($address in @($ApiBaseUrl, $PrivacyPolicyUrl, $TermsUrl)) {
    $uri = [Uri]$address
    if ($uri.Scheme -ne 'https' -or $uri.IsLoopback -or $uri.Host -match 'example\.|localhost|\.invalid$') {
        throw 'Use real public HTTPS addresses for the API and privacy policy.'
    }
}
if ($SupportEmail -notmatch '^[^\s@]+@[^\s@]+\.[^\s@]+$' -or $SupportEmail -match 'example\.|REPLACE') {
    throw 'Supply your public support email.'
}
if ($BuildNumber -lt 2) { throw 'Use an unused build number of 2 or greater.' }
if (-not (Test-Path (Join-Path $mobilePath 'android/key.properties'))) {
    throw 'Configure a private upload key in mobile/android/key.properties first.'
}
$policy = Invoke-WebRequest -Uri $PrivacyPolicyUrl -TimeoutSec 20
if ($policy.StatusCode -ne 200 -or $policy.Content -match 'REPLACE|SUPPORT_EMAIL|DRAFT') {
    throw 'Publish the completed privacy policy before building the upload candidate.'
}
$health = Invoke-RestMethod -Uri ($ApiBaseUrl.TrimEnd('/') + '/health') -TimeoutSec 20
if ($health.status -ne 'ok') { throw 'Backend health check failed.' }
$billing = Invoke-RestMethod -Uri ($ApiBaseUrl.TrimEnd('/') + '/v1/billing/config') -TimeoutSec 20
if ($billing.enabled -ne $true) { throw 'Configure and validate Google Play verification before the subscription release.' }
$terms = Invoke-WebRequest -Uri $TermsUrl -TimeoutSec 20
if ($terms.StatusCode -ne 200 -or $terms.Content -match 'REPLACE|SUPPORT_EMAIL|DRAFT') {
    throw 'Publish completed subscription terms before the release.'
}
Push-Location $mobilePath
try {
    flutter analyze
    if ($LASTEXITCODE -ne 0) { throw 'Analysis failed.' }
    flutter test
    if ($LASTEXITCODE -ne 0) { throw 'Tests failed.' }
    flutter build appbundle --release "--build-number=$BuildNumber" "--dart-define=API_BASE_URL=$ApiBaseUrl" "--dart-define=SUPPORT_EMAIL=$SupportEmail" "--dart-define=PRIVACY_POLICY_URL=$PrivacyPolicyUrl" "--dart-define=TERMS_URL=$TermsUrl" --dart-define=ENABLE_SUBSCRIPTIONS=true
    if ($LASTEXITCODE -ne 0) { throw 'App Bundle build failed.' }
    Write-Output 'Bundle built. Verify signing, permissions, Play pre-launch report and device behavior before submitting.'
} finally { Pop-Location }
