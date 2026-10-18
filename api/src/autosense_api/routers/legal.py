"""Public HTML Privacy Policy and Subscription Terms pages for Google Play."""

from fastapi import APIRouter
from fastapi.responses import HTMLResponse

router = APIRouter(tags=["legal"])

PRIVACY_HTML = """<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>AutoSense AI — Privacy Policy</title>
  <style>
    body {
      max-width: 780px; margin: 40px auto; padding: 0 24px;
      font: 16px/1.65 system-ui, -apple-system, sans-serif;
      color: #111317; background: #F6F7F9;
    }
    main {
      background: #FFFFFF; border: 1px solid #D3D7DD;
      border-radius: 20px; padding: 32px;
    }
    h1, h2 { color: #111317; line-height: 1.25; }
    .badge {
      display: inline-block; background: #FFC20E; color: #111317;
      font-weight: 700; font-size: 12px; padding: 4px 10px;
      border-radius: 8px; letter-spacing: 0.05em;
    }
    a { color: #8A6100; font-weight: 600; }
  </style>
</head>
<body>
  <main>
    <span class="badge">AUTOSENSE AI • PRIVACY POLICY</span>
    <h1>AutoSense AI Privacy Policy</h1>
    <p>
      <strong>Effective Date:</strong> October 18, 2026 &bull;
      <strong>Publisher:</strong> Youssef Ahmed &bull;
      <strong>Support &amp; Privacy Contact:</strong>
      <a href="mailto:youssefahmed4010@gmail.com">youssefahmed4010@gmail.com</a>
    </p>

    <h2>1. Information Used by the App</h2>
    <p>
      AutoSense AI lets you select a vehicle make/model/year and enter
      diagnostic trouble codes (DTCs), symptoms, safety checklist selections,
      and optional diagnostic notes. When you request online diagnostic
      guidance, these inputs are sent over HTTPS to our stateless diagnostic
      service (<code>https://autosense-api.vercel.app</code>) or processed
      directly on your device via the built-in offline diagnostic engine.
      Please do not enter personal identifiers in diagnostic notes.
    </p>

    <h2>2. OBD-II Scanner &amp; Performance Telemetry</h2>
    <p>
      Bluetooth Low Energy (BLE) discovery accesses nearby OBD-II scanner
      names, device identifiers, and serial GATT characteristics. On older
      Android versions, Android requires Location permission to scan for BLE
      devices; AutoSense AI does not collect or store GPS coordinates. Wi-Fi
      mode connects over local TCP to the adapter host and port you specify.
      Live vehicle readings (RPM, speed, coolant temperature, throttle
      position), vehicle mass, 10-second acceleration run samples, and session
      history are processed in device memory and are cleared when the app
      closes.
    </p>

    <h2>3. Purpose, Hosting &amp; Data Retention</h2>
    <p>
      Diagnostic inputs are used solely to generate preliminary rule-based
      diagnostic guidance. The cloud API is hosted on Vercel and processes
      diagnostic requests in memory without a persistent user database.
      Standard serverless infrastructure access logs (such as IP address,
      request path, and timestamp) are retained temporarily by the hosting
      provider for security and operational reliability. On-device session
      history disappears when the app closes.
    </p>

    <h2>4. Accounts, Analytics &amp; Advertising</h2>
    <p>
      AutoSense AI does not require user registration, contains no third-party
      advertising SDKs, and does not sell or share personal data with data
      brokers or advertisers.
    </p>

    <h2>5. Subscriptions &amp; Google Play Billing</h2>
    <p>
      AutoSense AI offers a Freemium tier and optional AutoSense Pro
      subscriptions (Monthly at EGP 99.00/month and Annual at EGP 999.00/year,
      with a 3-day free trial for eligible new subscribers). All payments are
      processed by Google Play. When Google Play billing verification is
      enabled, the app transmits the Google Play purchase token over HTTPS to
      our verification endpoint solely to validate active entitlement status
      and expiry with Google Play. AutoSense AI never receives or stores your
      credit card or payment instrument details.
    </p>

    <h2>6. Your Choices, Security &amp; Contact</h2>
    <p>
      All cloud communication uses HTTPS encryption in transit. You may
      disconnect scanners, clear your in-memory session history, or revoke
      Bluetooth permissions in Android Settings at any time. For support,
      privacy questions, or data inquiries, contact
      <a href="mailto:youssefahmed4010@gmail.com">youssefahmed4010@gmail.com</a>.
    </p>
  </main>
</body>
</html>
"""

TERMS_HTML = """<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>AutoSense AI — Subscription &amp; Service Terms</title>
  <style>
    body {
      max-width: 780px; margin: 40px auto; padding: 0 24px;
      font: 16px/1.65 system-ui, -apple-system, sans-serif;
      color: #111317; background: #F6F7F9;
    }
    main {
      background: #FFFFFF; border: 1px solid #D3D7DD;
      border-radius: 20px; padding: 32px;
    }
    h1, h2 { color: #111317; line-height: 1.25; }
    .badge {
      display: inline-block; background: #FFC20E; color: #111317;
      font-weight: 700; font-size: 12px; padding: 4px 10px;
      border-radius: 8px; letter-spacing: 0.05em;
    }
    a { color: #8A6100; font-weight: 600; }
  </style>
</head>
<body>
  <main>
    <span class="badge">AUTOSENSE AI • SUBSCRIPTION TERMS</span>
    <h1>AutoSense AI Subscription &amp; Service Terms</h1>
    <p>
      <strong>Effective Date:</strong> October 18, 2026 &bull;
      <strong>Publisher:</strong> Youssef Ahmed &bull;
      <strong>Support Contact:</strong>
      <a href="mailto:youssefahmed4010@gmail.com">youssefahmed4010@gmail.com</a>
    </p>

    <h2>1. Scope of Service &amp; Safety Notice</h2>
    <p>
      AutoSense AI provides preliminary rule-based vehicle diagnostic guidance,
      generic SAE J2012 trouble-code definitions, live OBD-II telemetry
      display, and acceleration power estimates. Outputs are preliminary
      information only and never replace a qualified technician's inspection or
      establish that a vehicle is safe to drive. Do not interact with the app
      while driving. Compatible OBD-II hardware and vehicle protocol support
      are required for live scanner readings.
    </p>

    <h2>2. Freemium &amp; AutoSense Pro Plans</h2>
    <p>
      Basic 56-code DTC lookup, the offline catalog browser, and the HP &amp;
      Torque calculator are available at no charge. AutoSense Pro unlocks Live
      OBD-II Bluetooth/Wi-Fi telemetry, Clear Codes, 10-Second Dyno Power
      Estimator, and Full 35-Brand Diagnostic Guidance:
    </p>
    <ul>
      <li>
        <strong>Monthly Plan:</strong> EGP 99.00/month (~$2.99/month) after a
        3-day free trial for eligible new subscribers.
      </li>
      <li>
        <strong>Annual Plan:</strong> EGP 999.00/year (~$24.99/year, billed
        annually in full) after a 3-day free trial for eligible new
        subscribers.
      </li>
    </ul>
    <p>
      Google Play determines trial eligibility and localized currency pricing
      at checkout.
    </p>

    <h2>3. Automatic Renewal, Cancellation &amp; Refunds</h2>
    <p>
      Subscriptions renew automatically at the end of each billing cycle unless
      canceled in Google Play at least 24 hours before the current period or
      3-day trial ends. Cancel anytime via Google Play Store &rarr; Payments
      &amp; subscriptions &rarr; Subscriptions. Uninstalling the app does not
      cancel an active subscription. Refunds are handled in accordance with
      Google Play refund policies and applicable consumer protection laws.
    </p>

    <h2>4. Privacy &amp; Support</h2>
    <p>
      Please review our <a href="/privacy">Privacy Policy</a>. For customer
      support or billing assistance, email
      <a href="mailto:youssefahmed4010@gmail.com">youssefahmed4010@gmail.com</a>.
    </p>
  </main>
</body>
</html>
"""


@router.get("/privacy", response_class=HTMLResponse, include_in_schema=False)
@router.get("/privacy-policy", response_class=HTMLResponse, include_in_schema=False)
def privacy_policy() -> HTMLResponse:
    """Serve the public HTML Privacy Policy for Google Play Console and in-app links."""
    return HTMLResponse(content=PRIVACY_HTML)


@router.get("/terms", response_class=HTMLResponse, include_in_schema=False)
@router.get("/subscription-terms", response_class=HTMLResponse, include_in_schema=False)
def subscription_terms() -> HTMLResponse:
    """Serve the public HTML Subscription Terms for Google Play Console and in-app links."""
    return HTMLResponse(content=TERMS_HTML)


DOWNLOAD_HTML = """<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>AutoSense AI — Official Free Download &amp; Web App</title>
  <style>
    :root {
      --bg: #F6F7F9;
      --surface: #FFFFFF;
      --carbon: #111317;
      --yellow: #FFC20E;
      --yellow-dark: #8A6100;
      --border: #D3D7DD;
      --muted: #525866;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0; padding: 32px 18px 64px;
      font: 16px/1.6 system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      color: var(--carbon); background: var(--bg);
    }
    .container { max-width: 860px; margin: 0 auto; }
    .hero {
      background: var(--carbon); color: #FFFFFF;
      border-radius: 24px; padding: 36px 32px;
      box-shadow: 0 18px 40px rgba(17, 19, 23, 0.14);
      margin-bottom: 24px;
    }
    .badge {
      display: inline-block; background: var(--yellow); color: var(--carbon);
      font-weight: 800; font-size: 12px; padding: 5px 12px;
      border-radius: 999px; letter-spacing: 0.06em; text-transform: uppercase;
    }
    h1 {
      font-size: clamp(28px, 4.5vw, 42px);
      line-height: 1.15; margin: 16px 0 12px;
    }
    .subtitle {
      color: #D3D7DD; font-size: 17px; max-width: 680px; margin: 0 0 28px;
    }
    .cta-row {
      display: flex; flex-wrap: wrap; gap: 14px; align-items: center;
    }
    .btn-primary {
      display: inline-flex; align-items: center; gap: 10px;
      background: var(--yellow); color: var(--carbon);
      font-weight: 800; font-size: 16px; text-decoration: none;
      padding: 15px 24px; border-radius: 14px;
      box-shadow: 0 6px 20px rgba(255, 194, 14, 0.35);
    }
    .btn-secondary {
      display: inline-flex; align-items: center; gap: 10px;
      background: #23272F; color: #FFFFFF;
      border: 1px solid #3A404D;
      font-weight: 700; font-size: 16px; text-decoration: none;
      padding: 15px 24px; border-radius: 14px;
    }
    .grid {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
      gap: 18px; margin-bottom: 24px;
    }
    .card {
      background: var(--surface); border: 1px solid var(--border);
      border-radius: 20px; padding: 24px;
    }
    .card h2 { margin-top: 0; font-size: 20px; }
    .meta { color: var(--muted); font-size: 14px; }
    ul, ol { padding-left: 20px; margin: 10px 0 0; }
    li { margin-bottom: 8px; }
    .footer {
      text-align: center; color: var(--muted); font-size: 14px; margin-top: 32px;
    }
    .footer a { color: var(--yellow-dark); font-weight: 700; text-decoration: none; }
  </style>
</head>
<body>
  <div class="container">
    <section class="hero">
      <span class="badge">AUTOSENSE AI &bull; V1.0.0+6 OFFICIAL RELEASE</span>
      <h1>OBD-II Car Diagnostics, 56-Code Library &amp; Live Telemetry</h1>
      <p class="subtitle">
        Supports 35 global car brands (1900&ndash;2026), offline &amp; cloud Hybrid Smart Mode (&lt;5ms response),
        Bluetooth/Wi-Fi ELM327 scanner, and Horsepower/Torque Dyno Estimator.
      </p>
      <div class="cta-row">
        <a class="btn-primary" href="https://github.com/yassinahmed14/autosense-ai/releases/download/v1.0.0/AutoSense-AI-v1.0.0+6-release-signed.apk">
          &#11015; Download Android APK (53.2 MB &bull; Free)
        </a>
        <a class="btn-secondary" href="https://yassinahmed14.github.io/autosense-ai/">
          &#9889; Launch Web App Instantly (Phone / Tablet / PC)
        </a>
      </div>
    </section>

    <div class="grid">
      <div class="card">
        <h2>How to Install on Android (Free)</h2>
        <ol>
          <li>Tap <strong>Download Android APK</strong> above on your Android phone or tablet.</li>
          <li>Open the downloaded file <code>AutoSense-AI-v1.0.0+6-release-signed.apk</code>.</li>
          <li>If prompted by Android, tap <strong>Allow from this source</strong> and tap <strong>Install</strong>.</li>
        </ol>
        <p class="meta">
          Cryptographically signed with the official AutoSense AI release key (<code>com.autosense.autosense_ai</code>).
        </p>
      </div>

      <div class="card">
        <h2>Use on iPhone, iPad, Tablet or PC</h2>
        <ul>
          <li>Tap <strong>Launch Web App Instantly</strong> above to run AutoSense AI right inside Chrome or Safari.</li>
          <li><strong>Add to Home Screen:</strong> In Safari (iPhone/iPad) or Chrome (Android), tap <strong>Share &rarr; Add to Home Screen</strong> to install AutoSense AI like a native app with zero store fees.</li>
        </ul>
      </div>
    </div>

    <div class="card">
      <h2>What's Included in v1.0.0+6</h2>
      <ul>
        <li><strong>100% Free Core Tools:</strong> 56 verified SAE J2012 trouble codes across Powertrain (<code>P</code>), Chassis/ABS (<code>C</code>), Body/Airbag (<code>B</code>), and Network/CAN (<code>U</code>), plus the bidirectional HP &amp; Torque Calculator.</li>
        <li><strong>AutoSense Pro (Includes Built-In 3-Day Free Trial):</strong> Live OBD-II Bluetooth &amp; Wi-Fi ELM327 Telemetry Dashboard, Clear Trouble Codes, 10-Second Dyno Power Run, and Full 35-Brand AI Diagnostic Action Plans.</li>
        <li><strong>Works Offline &amp; Online:</strong> Hybrid Smart Mode connects to our cloud API when online and automatically falls back in under 5 milliseconds to the built-in offline engine in underground garages.</li>
      </ul>
    </div>

    <div class="footer">
      <p>
        Published by Youssef Ahmed &bull;
        <a href="/privacy">Privacy Policy</a> &bull;
        <a href="/terms">Subscription Terms</a> &bull;
        <a href="mailto:youssefahmed4010@gmail.com">youssefahmed4010@gmail.com</a>
      </p>
    </div>
  </div>
</body>
</html>
"""


@router.get("/download", response_class=HTMLResponse, include_in_schema=False)
def download_portal() -> HTMLResponse:
    """Serve the official $0 APK download and Web App launch portal."""
    return HTMLResponse(content=DOWNLOAD_HTML)

