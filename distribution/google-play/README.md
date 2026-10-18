# AutoSense AI — Google Play Submission Package (`v1.0.0+6`)

Updated October 18, 2026 for **Youssef Ahmed** (`youssefahmed4010@gmail.com`).
This folder contains everything needed to publish **AutoSense AI** on Google Play Console.

---

## 1. Ready-to-Upload Artifacts & Live Links

| Item | Value / File Path |
|---|---|
| **Signed Release App Bundle (`.aab`)** | `D:\AutoSense AI\releases\AutoSense-AI-v1.0.0+6-release-signed.aab` |
| **Signed Debug/Testing APK (`.apk`)** | `D:\AutoSense AI\releases\AutoSense-AI-v1.0.0+6-debug.apk` |
| **Upload Keystore (`.jks`)** | `D:\AutoSense AI\releases\signing\autosense-upload.jks` (keep backed up privately; never commit to Git) |
| **Package Name (`applicationId`)** | `com.autosense.autosense_ai` |
| **Version / Version Code** | `1.0.0` (`versionCode: 6`, `minSdk: 24`, `targetSdk: 36`) |
| **Live Production API (HTTPS)** | `https://autosense-api.vercel.app` |
| **Live Privacy Policy URL (HTTPS)** | `https://autosense-api.vercel.app/privacy` |
| **Live Subscription Terms URL (HTTPS)** | `https://autosense-api.vercel.app/terms` |
| **Support Email** | `youssefahmed4010@gmail.com` |

---

## 2. Files Included in `distribution/google-play/`

- [STORE_LISTING.md](STORE_LISTING.md): Copy-paste title, short description, full description, release notes, and reviewer instructions.
- [DATA_SAFETY.md](DATA_SAFETY.md): Exact answers for the Google Play Console Data Safety questionnaire.
- [SUBSCRIPTIONS.md](SUBSCRIPTIONS.md): Setup guide for `autosense_pro` (`monthly` @ `EGP 99.00` and `annual` @ `EGP 999.00` with 3-day free trial).
- [RELEASE_STEPS.md](RELEASE_STEPS.md): Step-by-step checklist for uploading the signed `.aab` in Google Play Console.
- [privacy-policy.html](privacy-policy.html) & [subscription-terms.html](subscription-terms.html): Static copies of the live HTML pages hosted at `https://autosense-api.vercel.app/privacy` and `/terms`.
- `assets/`:
  - `play-icon-512.png` (512×512 High-Res Play Store Icon)
  - `feature-graphic-1024x500.png` (1024×500 Feature Graphic)
- `review-screenshots/`:
  - Real Android Phone (`1080×2400`) and 10-inch Android Tablet (`1280×800`) screenshots captured from `emulator-5554` and Samsung `GT-N8000`.
