---
name: android-emulator-qa
description: >-
  Boots the Android emulator, installs the AutoSense AI APK and walks through
  every screen and button with screenshots and crash checks. Use this skill
  when asked to test the app on Android, verify a build on the emulator or a
  connected phone, or reproduce a UI bug.
---

# Android emulator QA

## 1. Start a device
```powershell
. .\scripts\dev_env.ps1
emulator -list-avds                                  # expect AutoSense_Pixel_API36
Start-Process emulator -ArgumentList '-avd AutoSense_Pixel_API36 -no-snapshot -no-boot-anim -partition-size 2047'
adb wait-for-device; adb shell getprop sys.boot_completed   # wait until it prints 1
```
If the AVD is missing, recreate it:
`avdmanager create avd -n AutoSense_Pixel_API36 -k "system-images;android-36;google_apis;x86_64" -d pixel_7`.
Real phone: enable Developer options → USB debugging, plug in, accept the prompt, check `adb devices`.

## 2. Build, install, launch
```powershell
cd app; flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000; cd ..
$qa = '.agents/skills/android-emulator-qa/scripts/adb_ui.py'
python $qa install app/build/app/outputs/flutter-apk/app-debug.apk
python $qa launch; python $qa shot 00-home
```
For the live API instead of a local one, build with `API_BASE_URL=<vercel url>`.
For a local API, start uvicorn on port 8000 first (`10.0.2.2` = the PC from inside the emulator).

## 3. Walk every flow
Use `python $qa texts` to see what is on screen, `tap "<label>"`,
`scrolltap "<label>"`, `type`, `back`, `shot <name>`. View screenshots
to confirm layout. The checklist is in [references/flows.md](references/flows.md).

## 4. Check for crashes after each flow
`python $qa crashes` must print `no crashes`. Record results (pass/fail +
screenshot name) in the QA report requested by the user and update CLAUDE.md
"Status at a glance".

If the `mobile` MCP server is connected you may use it instead of adb_ui.py.
