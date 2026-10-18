# AutoSense API

FastAPI service that returns deterministic, rule-based (`rules-v1`) diagnostic guidance for
vehicle trouble codes and symptoms. It never issues definitive diagnoses: every possible cause is
`unconfirmed`, and safety concerns always override code-based urgency.

## Layout

```
api/
├── index.py                 # Vercel entrypoint (exposes `app`)
├── vercel.json, .vercelignore, requirements.txt   # Vercel deploy (runtime deps only)
├── Dockerfile, .dockerignore
├── pyproject.toml           # package `autosense-api`, ruff + pytest config
├── requirements.lock.txt    # pinned versions (CI + Docker constraints)
├── src/autosense_api/
│   ├── main.py              # create_app() factory + module-level `app`
│   ├── core/                # settings, logging, request-id middleware, error handlers
│   ├── routers/             # health, dtc, diagnostics, billing
│   ├── schemas/             # pydantic request/response models (the public contract)
│   ├── services/            # diagnostics rule engine, Google Play verification
│   └── data/                # editorial demo DTC catalog
└── tests/
    ├── unit/                # settings, rule engine, billing entitlement
    └── integration/         # HTTP via TestClient, CORS, contract snapshots
```

## Endpoints

| Method | Path | Notes |
| --- | --- | --- |
| GET | `/health` | `{"status":"ok","engine":"rules-v1","storage":"none"}` |
| GET | `/v1/dtc/{code}` | Catalog lookup; `422` for malformed codes; unknown codes return `found: false` |
| POST | `/v1/diagnostics` | Rule-based guidance; strict validation (unknown fields rejected) |
| GET | `/v1/billing/config` | `{"enabled": bool, "product_id": "autosense_pro"}` |
| POST | `/v1/billing/verify` | `503` unless Play billing is explicitly configured |

Interactive docs: `/docs`. The OpenAPI snapshot lives in `docs/architecture/openapi.json`.
Validation errors return only `loc`/`msg`/`type`: request values (purchase tokens, notes) are never
echoed. Every response carries an `X-Request-ID` header (a safe caller-supplied value is reused).

## Run locally

```powershell
# from the repo root
python -m venv .venv; .\.venv\Scripts\Activate.ps1
pip install -r api/requirements.lock.txt
pip install -e "api[dev]"
uvicorn autosense_api.main:app --reload
python scripts/smoke_api.py http://127.0.0.1:8000
```

Docker: `docker compose -f infra/compose.yaml up --build`.

## Environment variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `APP_ENV` | `development` | `development` or `production` (production = JSON log lines) |
| `LOG_LEVEL` | `INFO` | `DEBUG`, `INFO`, `WARNING`, `ERROR` |
| `CORS_ORIGINS` | `["http://localhost:3000","http://127.0.0.1:3000"]` | JSON list of exact browser origins |
| `CORS_ORIGIN_REGEX` | `https://<name>.vercel.app` or `http://localhost:<port>` / `127.0.0.1` | Full-match regex for extra origins; empty value disables |
| `PLAY_BILLING_ENABLED` | unset | Must be `true` (with the two below) to enable verification |
| `PLAY_PACKAGE_NAME` | unset | Android package name |
| `GOOGLE_APPLICATION_CREDENTIALS` | unset | Service-account JSON path (requires `pip install "api[billing]"`) |

Values may also come from `api/.env` (see `.env.example`). CORS only affects browsers; the native
apps are unaffected. The default regex allows any `*.vercel.app` site: acceptable because the API
has no cookies or auth, but narrow it (or clear it) once a custom domain exists.

## Tests and lint

```powershell
pytest api/tests -q
ruff check api scripts; ruff format --check api scripts
python scripts/export_contracts.py   # regenerate fixture/OpenAPI/seed after contract changes
```

## Deploy (Vercel Hobby, free)

The `api/` folder is a standalone Vercel Python project (`index.py` exposes `app`; dependencies
from `requirements.txt`, no billing extras).

```powershell
cd api
npx vercel login                         # once
npx vercel link --yes --project autosense-api
npx vercel env add APP_ENV production    # value: production
npx vercel deploy --prod --yes
python ../scripts/smoke_api.py https://autosense-api.vercel.app
```

The deployment is stateless (no database), so it fits the free tier. Do not enable paid add-ons.
