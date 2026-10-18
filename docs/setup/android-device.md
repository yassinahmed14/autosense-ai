# Android phone testing

Android 7.0 (API 24) or newer is required. No paid developer account is needed
for direct installation. Actual adapter compatibility remains unverified.

## USB installation from Windows

1. Connect the unlocked phone using a USB data cable.
2. Enable Developer options (usually tap Build number seven times under About
   phone), enable USB debugging, and accept the computer authorization prompt.
3. Run `adb devices`. The phone must show `device`, not `unauthorized`.
4. Build from the project's `mobile` folder:

   ```powershell
   flutter pub get
   flutter build apk --debug --dart-define=API_BASE_URL=http://127.0.0.1:8000
   adb install -r build/app/outputs/flutter-apk/app-debug.apk
   adb reverse tcp:8000 tcp:8000
   ```

5. Start the backend using the main README, listening on loopback port 8000,
   and open AutoSense on the phone. Keep USB connected while using backend
   diagnostics. Reapply `adb reverse` if the connection or phone restarts.

If multiple devices are connected, use `adb -s DEVICE_SERIAL` for installation
and reverse commands. Install failures must be investigated before uninstalling
an existing app, since uninstalling can erase app data.

## Adapter test

Keep the vehicle parked for the first test. Close other scanner apps. Open
Connect a scanner > Bluetooth and allow Nearby devices/Bluetooth permissions.
Older Android versions may also need location permission and location enabled
for BLE discovery. Select your actual adapter; supported UART layouts and an ELM
identity response are checked automatically. Successful setup opens the connected
Live dashboard / Diagnose menu. If setup fails, copy the troubleshooting report.

Once the serial profile is verified, read stored codes, then check stationary
live RPM. Real code clearing is disabled. Live telemetry does not need the PC
backend, but diagnostic guidance does. Wi-Fi mode requires a physical adapter
that supports Wi-Fi and its documented TCP address and port.

## Manual installation

Copy the built APK to the phone, open it, and allow installation from that file
manager if prompted. The USB-configured APK's backend features still need USB
debugging and port reversal; copying it alone does not connect to the PC API.

This is a debug-signed development build, not a Play Store release. Do not treat
simulated readings or acceleration-power estimates as measured engine output.
