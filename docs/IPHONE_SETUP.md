# Install AutoSense on your iPhone

Current status: source is prepared, but no native iOS build has been compiled,
signed, installed, or tested. This Windows PC cannot run Xcode. The browser demo
cannot connect to the adapter using this project's native Bluetooth/Wi-Fi drivers.

## Option 1: Borrow a Mac and use a free Apple account

This avoids paying for TestFlight membership just to test on your own device.

1. Copy `autosense-ai-starter.zip` to the Mac and extract it.
2. Install Flutter and Xcode using the official setup guide below. Complete
   `flutter doctor` requirements, including any plugin tooling it requests.
3. Connect the unlocked iPhone by USB, trust the Mac, and enable Developer Mode
   when prompted. Sign into your Apple account in Xcode.
4. In Terminal, enter the extracted project's `mobile` directory and run:

   ```sh
   flutter pub get
   open ios/Runner.xcworkspace
   ```

5. In Xcode select Runner, then Signing & Capabilities. Enable automatic signing,
   select your Personal Team, and replace `com.autosense.autosenseAi` with a
   unique bundle identifier under your control. Choose the connected iPhone.
6. From the same Terminal directory run `flutter devices`, then:

   ```sh
   flutter run -d YOUR_IPHONE_DEVICE_ID
   ```

   Replace the device ID with the one Flutter reports. Follow Xcode/iPhone trust
   prompts if signing requires them. Free provisioning may require periodic
   rebuilding/reinstallation.

## Option 2: Cloud Mac build and TestFlight

This works without owning a Mac, but requires an active Apple Developer Program
membership (Apple lists US$99/year, with local pricing where available), a cloud
build account, and an App Store Connect app/signing setup. Build-service charges
are separate. No accounts, subscriptions, uploads, or builds have been created.

A service such as Codemagic can build Flutter iOS apps on hosted Macs. Connect a
private source repository, set the Flutter project directory to `mobile`, register
a unique bundle ID, and configure Apple's signing integration using the service's
secure credential settings. Never put Apple passwords, signing keys, or API keys
in the project or chat. Follow its official signing guide, build a signed IPA,
upload to App Store Connect, and add your account as an internal TestFlight tester.
Resolve any required Apple processing/compliance prompts before installing.

## First adapter test after installation

1. Keep the car parked. Plug in the adapter and follow its instructions for
   ignition state. Close other scanner apps that might hold the connection.
2. Open AutoSense > Connect a scanner > Bluetooth. Allow Bluetooth access and
   select the actual adapter. A name such as `OBDII` does not verify compatibility.
3. Select the device. AutoSense matches supported documented UART layouts and
   verifies an ELM response automatically. If it fails, use Troubleshooting to copy
   the report; unknown profiles need documentation and validation.
4. From the connected menu, try Diagnose for a stored-code read, then Live dashboard for RPM
   while stationary. Record any connection error exactly. Do not start a road
   performance run for this initial connection test.
5. Wi-Fi is a separate option only if the physical adapter supports it. Join its
   network in iPhone Settings and enter its documented TCP host and port in the
   app. Software cannot add Wi-Fi to a Bluetooth-only adapter.

Live adapter readings and run estimates are local. Backend diagnostic guidance
needs a reachable API: the default localhost address refers to the iPhone itself
and will not reach the Windows backend. Configure a reachable development API
with `--dart-define=API_BASE_URL=...` when building; see the main README. Do not
publish the unauthenticated demo backend to the internet as-is.

Real code clearing remains disabled. Vehicle auto-identification is not validated
on hardware. Performance results are acceleration-based estimates, not measured
engine horsepower or torque. Supporting other scanners requires their protocols
and testing; the current drivers do not support every OBD device.

## Official references (checked October 12, 2026)

- Flutter iOS setup: https://docs.flutter.dev/platform-integration/ios/setup
- Apple membership: https://developer.apple.com/programs/
- Codemagic iOS signing: https://docs.codemagic.io/flutter-code-signing/ios-code-signing/
- Codemagic Flutter builds: https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/
