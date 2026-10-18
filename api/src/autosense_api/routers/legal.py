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
