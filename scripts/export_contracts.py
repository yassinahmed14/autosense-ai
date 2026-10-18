"""Regenerate contract artifacts from the API package. No server required.

Run from any directory with the API environment: python scripts/export_contracts.py

Writes the Flutter contract fixture, the OpenAPI snapshot and the Supabase demo seed.
"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "app/test/fixtures/result.json"
OPENAPI = ROOT / "docs/architecture/openapi.json"
SEED = ROOT / "infra/supabase/seed.sql"

# Works without `pip install -e api` by falling back to the src layout.
sys.path.insert(0, str(ROOT / "api/src"))

from autosense_api.data.catalog import CATALOG
from autosense_api.main import create_app
from autosense_api.schemas.diagnostics import DiagnosticRequest
from autosense_api.services.diagnostics import diagnose


def sql_literal(value: object) -> str:
    return "'" + str(value).replace("'", "''") + "'"


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def main() -> None:
    fixture = diagnose(
        DiagnosticRequest(
            codes=["P0300", "P0171"], source="mock_obd", safety_check_completed=True
        )
    ).model_dump(mode="json")
    # Stable sample metadata keeps regeneration deterministic.
    fixture["id"] = "00000000-0000-4000-8000-000000000001"
    fixture["created_at"] = "2026-10-12T00:00:00Z"
    write(FIXTURE, json.dumps(fixture, indent=2) + "\n")
    write(OPENAPI, json.dumps(create_app().openapi(), indent=2) + "\n")

    rows = []
    for item in CATALOG.values():
        values = [
            item.code,
            item.title,
            item.explanation,
            json.dumps(item.possible_causes),
            json.dumps(item.next_checks),
            item.coverage,
        ]
        rows.append("(" + ", ".join(sql_literal(value) for value in values) + ")")
    write(
        SEED,
        "-- Generated demo catalog; run after migration as database admin.\n"
        "insert into public.dtc_catalog(code, title, explanation, possible_causes, next_checks, "
        "coverage)\n"
        "values\n" + ",\n".join(rows) + "\non conflict (code) do update set\n"
        "title=excluded.title, explanation=excluded.explanation,\n"
        "possible_causes=excluded.possible_causes, next_checks=excluded.next_checks,\n"
        "coverage=excluded.coverage;\n",
    )
    print("Exported OpenAPI, app contract fixture, and Supabase demo seed.")


if __name__ == "__main__":
    main()
