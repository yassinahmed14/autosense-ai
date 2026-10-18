# Release steps — Google Play Console Upload Guide

## Ready-to-Use Release Artifacts & URLs

- **Signed Android App Bundle (`.aab`)**: `D:\AutoSense AI\releases\AutoSense-AI-v1.0.0+6-release-signed.aab`
- **Upload Keystore**: `D:\AutoSense AI\releases\signing\autosense-upload.jks` (keep `README-KEEP-SAFE.txt` backed up securely)
- **Package ID (`applicationId`)**: `com.autosense.autosense_ai`
- **Version**: `1.0.0+6` (`versionName = 1.0.0`, `versionCode = 6`)
- **Live Cloud Backend URL**: `https://autosense-api.vercel.app`
- **Live Privacy Policy URL**: `https://autosense-api.vercel.app/privacy`
- **Live Subscription Terms URL**: `https://autosense-api.vercel.app/terms`
- **Support Email**: `youssefahmed4010@gmail.com`

---

## Step-by-Step Google Play Console Checklist

### 1. Create the App in Google Play Console
1. Sign in to [Google Play Console](https://play.google.com/console) and click **Create app**.
2. Enter:
   - **App name**: `AutoSense AI: OBD2 & Car Codes`
   - **Default language**: `English (United States) – en-US`
   - **App or game**: `App`
   - **Free or paid**: `Free` (Freemium apps with in-app subscriptions are listed as **Free** on Google Play)
3. Accept the Play Console declarations and click **Create app**.

### 2. Complete App Content & Policy Declarations (Left Sidebar -> Policy -> App content)
1. **Privacy Policy**: Paste `https://autosense-api.vercel.app/privacy`
2. **Ads**: Select **No, my app does not contain ads**.
3. **App Access**: Select **All or some functionality is restricted**, and add instructions for Google reviewers:
   - *"Core DTC code lookup (56 codes), fault catalog browser, and HP/Torque calculator are 100% free with no login. Reviewers can also preview AutoSense Pro features immediately using the built-in 3-day trial simulator on the AutoSense Pro screen or test with Demo Scanner mode without needing a physical car."*
4. **Content Rating**: Complete the questionnaire under the **Utility / Productivity / Reference** category (no violence, no user-generated content, no gambling).
5. **Target Audience**: Select **18 and over** (recommended for automotive tool apps so your app is never subject to family/children policy restrictions).
6. **Data Safety**: Use the exact answers in [DATA_SAFETY.md](file:///D:/AutoSense%20AI/autosense-ai/distribution/google-play/DATA_SAFETY.md).

### 3. Configure Store Listing & Graphics (Grow -> Store presence -> Main store listing)
1. Copy the **App name**, **Short description**, and **Full description** from [STORE_LISTING.md](file:///D:/AutoSense%20AI/autosense-ai/distribution/google-play/STORE_LISTING.md).
2. Upload graphics from `distribution/google-play/assets/` and `distribution/google-play/review-screenshots/`:
   - **App Icon** (512x512 PNG): `distribution/google-play/assets/icon-512.png`
   - **Feature Graphic** (1024x500 PNG): `distribution/google-play/assets/feature-graphic-1024x500.png`
   - **Phone Screenshots**: Upload `phone_01_home.png` through `phone_06_dyno.png` from `distribution/google-play/review-screenshots/`
   - **7-inch & 10-inch Tablet Screenshots**: Upload `tablet_01_home.png` through `tablet_05_subscription.png` from `distribution/google-play/review-screenshots/`

### 4. Set Up AutoSense Pro Subscription (`autosense_pro`) (Monetize -> Products -> Subscriptions)
1. Create a subscription with Product ID: **`autosense_pro`**
2. Add two auto-renewing base plans:
   - **`monthly`** (`P1M` billing period): Set price to **`EGP 99.00`** (`~$2.99 USD`) and add a **3-day free trial (`P3D`)** offer for new subscribers.
   - **`annual`** (`P1Y` billing period): Set price to **`EGP 999.00`** (`~$24.99 USD`) and add a **3-day free trial (`P3D`)** offer for new subscribers.
3. Activate both base plans and offers.

### 5. Upload the Signed App Bundle (`.aab`)
1. Go to **Test and release -> Testing -> Internal testing** (or **Closed testing** / **Production**).
2. Enable **Play App Signing** when prompted.
3. Upload **`D:\AutoSense AI\releases\AutoSense-AI-v1.0.0+6-release-signed.aab`**.
4. Enter release notes (e.g., *"Initial release of AutoSense AI v1.0.0+6: 35-brand OBD-II diagnostics, 56 verified DTC fault guides, ELM327 Bluetooth/Wi-Fi live scanner, HP/Torque dyno calculator, and AutoSense Pro membership."*).
5. Click **Next -> Save and publish**.

---

## Rebuilding a Future Update (Build Number `7+`)

Whenever you publish a future update, increment `version: 1.0.0+7` in `app/pubspec.yaml` and run:

```powershell
. .\scripts\dev_env.ps1
Set-Location app
flutter build appbundle --release `
  --dart-define=API_BASE_URL=https://autosense-api.vercel.app `
  --dart-define=PRIVACY_POLICY_URL=https://autosense-api.vercel.app/privacy `
  --dart-define=TERMS_URL=https://autosense-api.vercel.app/terms `
  --dart-define=SUPPORT_EMAIL=youssefahmed4010@gmail.com
```
