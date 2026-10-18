---
name: deploy-vercel
description: >-
  Deploys the AutoSense AI API (Python/FastAPI) and the Flutter web app to
  Vercel's free Hobby plan and verifies them live. Use this skill when asked to
  deploy, publish, "make it live", redeploy after changes, or check production.
---

# Deploy to Vercel (free)

Zero-cost rules: Hobby plan only, no paid add-ons, no custom domain purchase.

## 0. Prerequisites
```powershell
$env:npm_config_cache = 'D:\CodexWork\npm-cache'
npx --yes vercel@latest whoami     # if "Logged out": npx vercel login (owner signs in in the browser)
```

## 1. API  (project `autosense-api`, folder `api/`)
```powershell
cd api
npx vercel deploy --prod --yes
cd ..
python scripts/smoke_api.py https://<api-url>     # must print "Live HTTP checks passed"
```
Env vars (Vercel dashboard or `npx vercel env add`): `APP_ENV=production`,
optional `CORS_ORIGINS` (JSON list). `*.vercel.app` origins are allowed by default.

## 2. Web app  (project `autosense-web`)
```powershell
. .\scripts\dev_env.ps1
.\scripts\deploy_web.ps1 -ApiUrl https://<api-url>
```
The script builds `flutter build web --release --dart-define=API_BASE_URL=<api-url>`
and deploys `app/build/web` as a static site.

## 3. Verify
- Open the web URL; Home loads with the light theme.
- DTC library → `P0420` returns an entry (proves web → API works, no CORS error).
- Update CLAUDE.md "Status at a glance" with both URLs and the date.

Note: Bluetooth/Wi‑Fi scanners can't work in a browser; the web app is a demo.
