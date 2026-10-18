# Experimental scanner transports and hardware validation

No physical adapter, phone Bluetooth stack, Wi-Fi scanner or car has been tested.
Android builds have passed; the user reported installing the debug APK. iOS builds
have not run. Web compilation and fixture tests do
not establish hardware compatibility. Real clearing remains disabled.

## Reported target

ELM327 Mini, reportedly BLE 4.0–5.0, advertised name `OBDII`, intended for Android
and iPhone. The supplied screenshot shows BLE selected and that name; it does not
establish successful ECU communication or a GATT profile. The Noon listing was
inaccessible. Manufacturer, firmware and serial UUIDs remain unverified.

## Implemented software

- `flutter_reactive_ble` 5.6.0 (BSD-3-Clause) handles BLE discovery, connection,
  service inspection and serial notifications/writes. `permission_handler` 13.0.2
  (MIT) handles Android runtime permissions. Versions are pinned and locked.
- Android API 31+ requests scan/connect; API 24–30 requests location when in use
  and may require Location services on. Compile SDK 37 / min SDK 24 are configured.
  Denied permissions, Bluetooth off, unsupported platform, timeout and cancellation
  produce errors. iOS Bluetooth/local-network purpose strings are supplied.
- Selecting a device automatically matches a documented UART layout and verifies
  an ELM identity before opening the Live dashboard / Diagnose menu. No RX/TX choice
  is required. Unknown/ambiguous profiles and duplicate UUIDs fail with a report.
  See BLE_AUTO_CONNECT.md for supported layouts and primary references.
- Wi-Fi opens native TCP at a user-entered documented endpoint. Join its network
  in system settings. No UDP, HTTP, automatic joining or network discovery is
  claimed. Browser previews disable physical transports.
- ELM commands are allowlisted: setup, supported-PID request, protocol query,
  stored Mode 03 DTCs, speed/RPM/coolant/absolute-throttle PIDs. Clearing, actuator
  tests, ECU writes and arbitrary typed commands are excluded.
- Protocol subset: CAN 11/29-bit, ELM protocols 6–9, headers/spaces enabled, no DLC.
  ISO-TP single/multiframes preserve responding ECUs and check DTC counts. Unknown,
  negative, empty, malformed or partial replies fail instead of reporting no codes.
  Live PIDs select one ECU advertising both speed and RPM.
- Serialized commands buffer fragmented ASCII to a prompt with size/time limits.
  A timeout invalidates the session so late bytes cannot satisfy a later request.
  Backgrounding disconnects; returning to the connected menu preserves the session
  after any pending read ends. Leaving that menu disconnects. Stale readings do not appear current.
- Other scanners implement `ObdAdapter` / `LiveObdAdapter`. Classic, USB, OBD-I,
  non-CAN and proprietary protocols need separate documented drivers; they are
  not supported merely because they have a similar connector. Mock flows remain.

## Physical validation milestones

1. Build the native app. A Wi-Fi adapter network without internet may make the
   diagnostic API unreachable; dashboard readings stay local.
2. Park, follow vehicle/adapter instructions, and close other scanner apps.
3. BLE: test automatic profile matching/ELM handshake and preserve the report. Wi-Fi:
   confirm ELM TCP support and documented endpoint. Never infer from a name.
4. Compare stored codes/live PIDs against a trusted scanner and preserve reports.
   No stored codes is not a complete vehicle-health assessment.
5. Test Android/iOS independently, including permission denial, Bluetooth off,
   no power, disconnect mid-read, delayed/malformed data, cancellation and reconnect.
6. Only after reliable reads, consider clearing with saved codes/freeze-frame
   evidence, confirmation, readiness-loss explanation and verified response.

Performance estimates need a separate closed-course accuracy study against
calibrated equipment. The current kinetic-energy estimate omits road load and is
not dyno output. Synthetic fixtures and loopback tests are not hardware traces.

## Required evidence matrix

Record date, exact manufacturer/model/hardware/firmware, phone/OS, app version,
vehicle make/model/year/engine/market, protocol, permission results, GATT UUIDs or
TCP endpoint, redacted reports, trusted-scanner comparison and pass/fail. Include
zero/one/multiple-ECU codes, unsupported PIDs/protocols, malformed/missing frames,
timeouts, backgrounding, reconnect and cancellation. Publish only tested functions
on the specific tested combinations.

References: [BLE package](https://pub.dev/packages/flutter_reactive_ble),
[permissions](https://pub.dev/packages/permission_handler),
[ELM327 framing/commands](https://www.elmelectronics.com/wp-content/uploads/2017/01/ELM327DS.pdf),
[PID tables](https://python-obd.readthedocs.io/en/latest/Command%20Tables/).
