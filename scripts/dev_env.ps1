# Dot-source this in PowerShell before building/testing on this machine:
#   . .\scripts\dev_env.ps1
#
# Why: drive C: is nearly full, so Gradle caches, temp files and Android
# emulator images are redirected to drive D:. Paths can be overridden by
# setting the variables before dot-sourcing.

$devRoot = if ($env:AUTOSENSE_DEV_ROOT) { $env:AUTOSENSE_DEV_ROOT } else { 'D:\CodexWork' }
$flutterSdk = if ($env:FLUTTER_ROOT) { $env:FLUTTER_ROOT } else { Join-Path $devRoot 'autosense-sdk-20261012' }
$androidSdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
$buildRoot = Join-Path $devRoot 'autosense-android-build-20261013'

$env:ANDROID_HOME = $androidSdk
$env:ANDROID_SDK_ROOT = $androidSdk
$env:GRADLE_USER_HOME = Join-Path $buildRoot 'gradle'
$env:ANDROID_AVD_HOME = Join-Path $devRoot 'avd'
$env:PUB_CACHE = Join-Path $devRoot 'pub-cache'
$env:npm_config_cache = Join-Path $devRoot 'npm-cache'
$env:TEMP = Join-Path $buildRoot 'temp'
$env:TMP = $env:TEMP
foreach ($dir in $env:GRADLE_USER_HOME, $env:ANDROID_AVD_HOME, $env:PUB_CACHE, $env:npm_config_cache, $env:TEMP) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

$env:Path = @(
    (Join-Path $flutterSdk 'bin'),
    (Join-Path $androidSdk 'platform-tools'),
    (Join-Path $androidSdk 'emulator'),
    (Join-Path $androidSdk 'cmdline-tools\latest\bin'),
    $env:Path
) -join ';'

Write-Host "Flutter : $flutterSdk"
Write-Host "Android : $androidSdk"
Write-Host "Gradle  : $env:GRADLE_USER_HOME"
Write-Host "AVDs    : $env:ANDROID_AVD_HOME"
