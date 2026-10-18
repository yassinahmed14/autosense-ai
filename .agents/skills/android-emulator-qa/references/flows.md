# Core flows checklist (tick each on every release)

| # | Flow | Steps | Expected |
|---|---|---|---|
| 1 | Launch | Open app | Home loads, light theme, no crash |
| 2 | App bar | Tap Membership, Privacy, Configuration icons; back each time | Each screen opens and closes |
| 3 | Live dashboard (demo) | Home → "Open live dashboard" | RPM/speed values update, "Demo stream" status |
| 4 | Metric chips | Toggle Speed/Coolant/Throttle chips | Cards hide/show |
| 5 | Demo run | Enter mass `1400`, tick confirmation, "Start 10-second demo run", wait 11 s | Estimate cards appear; "Copy run data (CSV)" shows snackbar |
| 6 | Cancel run | Start run → "Cancel recording" | "Recording cancelled" message |
| 7 | Connection hub | Home → "Connect a scanner" | Bluetooth + Wi‑Fi options listed |
| 8 | BLE screen | Open Bluetooth option → "Discover devices" | Permission prompt or scan; no crash without adapter |
| 9 | Wi‑Fi screen | Open Wi‑Fi option, bad host → connect | Validation/timeout error, no crash |
| 10 | Manual guidance | "Enter codes or symptoms" → `P0300` → "Get preliminary guidance" | Result screen (needs API) |
| 11 | Auto-detect (demo) | Manual screen → "Auto-detect car (demo)" | Mock scan flow opens |
| 12 | Mock scan | "Try mock OBD scan" → Discover → tap adapter | Prefilled 2020 Toyota Corolla, SIMULATED labels |
| 13 | Clear codes (demo) | Mock scan → "Clear codes (demo)" → Cancel, then confirm | Confirmation dialog; cleared message |
| 14 | Session history | After a result, back to Home | History card; tap opens result; "Clear" empties |
| 15 | DTC library | Lookup `P0420`, `P1234`, `P9999` | Known entry / unknown / validation error |
| 16 | Calculator | 200 N·m at 3000 RPM | ≈ 84.3 hp; switch direction works |
| 17 | Safety tile | Expand "Safety and use" | Safety notice visible |
| 18 | Rotation/background | Rotate device; press Home and return on dashboard | No crash; dashboard reports disconnect |
