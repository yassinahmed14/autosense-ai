# Release steps

## Owner actions before uploading

Create and verify a Play Console account using Google's official signup. Review
current fees, identity requirements and agreements yourself. Choose final support
email, privacy policy URL and application ID. No account or payment is automated.

Deploy a hardened diagnostic API behind HTTPS. The supplied development API has
no authentication, rate limiting, abuse controls or production log-retention policy.
Decide access controls, limits, monitoring and privacy practices before public use.
Update the privacy policy with real contact/retention/provider details and host it
at a public non-editable HTML URL (not a PDF, sign-in page or local network URL).
Replace the development-status paragraph in the in-app privacy screen and provide
the final policy/support access there before release. Verify every data declaration.

## Upload signing

Create a private upload key with Java keytool outside the project, for example:

```powershell
keytool -genkeypair -v -keystore D:/private/autosense-upload.jks -alias autosense-upload -keyalg RSA -keysize 3072 -validity 10000
```

Choose the password interactively. Back up the keystore and credentials securely.
Copy mobile/android/key.properties.example to key.properties and fill it locally.
Never send passwords in chat or include private keys/properties in the ZIP.
The release Gradle configuration uses this upload key when configured and otherwise
produces unsigned review output. It never falls back to the debug signing key.
Enable Play App Signing when creating the app in Console.

## Build upload candidate

From the project root, with Flutter on PATH:

```powershell
./scripts/build_play_release.ps1 -ApiBaseUrl https://YOUR_REAL_API -PrivacyPolicyUrl https://YOUR_REAL_POLICY -TermsUrl https://YOUR_REAL_TERMS -SupportEmail YOUR_REAL_EMAIL -BuildNumber 2
```

Use real addresses and a higher unused build number for every upload. The helper
rejects obvious development addresses and missing signing configuration, checks
policy/API reachability, runs tests, and builds an AAB. Passing it does not replace
security review or prove the final policy is complete. Output is under
mobile/build/app/outputs/bundle/release/app-release.aab. Verify its signing with
`jarsigner -verify -verbose -certs PATH_TO_AAB`; never upload unsigned review output.

The current package ID is com.autosense.autosense_ai. Change it before first upload
if desired, and update all release references. The test APK is debug signed; a
Play-signed install with the same package may require uninstalling that test copy.
Ask before removing app data. Keep the upload key stable across updates.

## Store Console

Use the draft listing, new icon and feature graphic; replace review screenshots
with actual release Android captures. Complete privacy/data safety, app access,
ads (none in current code), paid subscriptions, content rating, target audience and other declarations
based on the final binary. Suggested category: Auto & Vehicles. No app accounts exist; Google Play Billing is optional and disabled by default. Do not claim universal scanner support or definite diagnoses.
Run internal and required closed tests; fix findings before production review.

Nothing in this pack creates a public listing or submits a release.

Before activating billing, complete the security/lifecycle blockers in SUBSCRIPTIONS.md and pass real Play license tests.
