# Automatic BLE connection

Selecting a device connects/discovers its services, matches one documented UART
layout with appropriate write/notify capabilities, then sends read-only `ATI` and
requires an ELM327/STN/OBDLink identity. Only after that does the UI replace the
selection screen with a connected menu offering Live dashboard and Diagnose.
No RX/TX selectors or profile confirmation checkbox remain in the user flow.

## Recognized layouts

| Serial service | App writes to | App receives notifications from |
|---|---|---|
| FFF0 UART | FFF2 | FFF1 |
| FFE0 HM-10 UART | FFE1 | FFE1 |
| Nordic UART 6e400001-b5a3-f393-e0a9-e50e24dcca9e | 6e400002-b5a3-f393-e0a9-e50e24dcca9e | 6e400003-b5a3-f393-e0a9-e50e24dcca9e |

Short UUIDs use the standard Bluetooth base UUID. Discovery order and advertised
name do not choose directions. Wrong properties, unknown/ambiguous layouts and
duplicate UUID instances are rejected; arbitrary writable GATT characteristics
are never probed. Matching a layout is not an adapter/vehicle compatibility claim.

Unknown profiles produce an actionable error and retain discovered service details
under Troubleshooting > Copy connection report. Manufacturer documentation or a
physical trace is still needed before adding another profile. No universal scanner
support is claimed, and the user's specific ELM327 Mini has not been validated.

The initial handshake confirms only the adapter serial response. ECU initialization
and CAN protocol/PID or DTC checks happen when an action is selected. Diagnose reads
stored engine/emissions codes and opens their review/symptom form. Online guidance
still needs a reachable backend. Real clearing remains disabled.

The connected menu owns the BLE session. Returning from the dashboard keeps it
available and waits for the in-flight PID read before another action. Leaving the
connected menu or app backgrounding disconnects. ECU read errors keep Bluetooth connected when possible. Actions reconnect the
same selected adapter when needed. Device identity and ECU availability are not
inferred from the connection badge.

Primary references:
- OBDLink FFF0/FFF2/FFF1 UART: https://support.obdlink.com/support/solutions/articles/43000746707-obdlink-cx-adapter-notes
- HM module vendor datasheet (mirror): https://components101.com/sites/default/files/component_datasheet/HM10%20Bluetooth%20Module%20Datasheet.pdf
- Nordic UART: https://nrfconnectdocs.nordicsemi.com/ncs/latest/nrf/libraries/bluetooth/services/nus.html

Synthetic profile, handshake and navigation tests verify software behavior; they
are not physical adapter or ECU test results.

## ECU read recovery update — October 16, 2026

Android test build 0.1.0+4 preserves Bluetooth after ECU read failures. A complete
prompt-terminated NO DATA/error response can be retried without disconnecting. A
transport failure or timeout still invalidates the ELM session to prevent late
responses being assigned to another command; the next action reconnects safely.
The menu separately shows Bluetooth and verified ECU state and offers a copyable
command transcript, including incomplete timeout replies. The dashboard stops
readings and recordings on failure without disconnecting the menu-owned session.
Only paused/detached app lifecycle states disconnect; transient inactive states
no longer interrupt reads. Automatic protocol search allows 45 seconds; other
commands retain a 20-second timeout.

An explicit '?' for ATD0 is accepted because DLC display defaults off on documented
ELM firmware; frame validation still rejects malformed or unsupported layouts.
Other unacknowledged setup commands remain errors. No arbitrary protocol probing,
code clearing, or actuator commands were added.

Reference: https://www.elmelectronics.com/wp-content/uploads/2017/01/ELM327DS.pdf

33 targeted synthetic protocol/profile/navigation tests passed, including NO DATA
retry, unsupported ATD0, and both diagnosis/live failure preserving Bluetooth.
User reports Bluetooth connection with a 2013 Mercedes C180 1.6 turbo; the cause
of the original ECU initialization failure remains unknown pending a fresh trace.
The unsigned AAB and web preview are still the earlier build 0.1.0+3.

## Adapter acknowledgement fix — Android 0.1.0+5

The user's physical trace identifies ELM UART and an advertised ELM327 V2.1
identity. It stops at ATCFC1, which replies SEARCHING... followed by OK. The old
exact-string acknowledgement check rejected that reply before sending 0100.
Setup now accepts an optional standalone SEARCHING... line followed by exactly
one OK. Unknown text, duplicate OK, NO DATA, missing acknowledgement and errors
remain failures. This resolves the observed software blocker; a new physical
ECU read is needed to verify the next stage. Firmware identity is self-reported.
