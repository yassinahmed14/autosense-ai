"""Run with the backend environment from any directory. No server required."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "backend"))

from app.catalog import CATALOG  # noqa: E402
from app.diagnostics import diagnose  # noqa: E402
from app.main import app  # noqa: E402
from app.models import DiagnosticRequest  # noqa: E402

fixture = diagnose(DiagnosticRequest(codes=["P0300", "P0171"], source="mock_obd",
                                     safety_check_completed=True)).model_dump(mode="json")
# Stable sample metadata keeps regeneration deterministic.
fixture["id"] = "00000000-0000-4000-8000-000000000001"
fixture["created_at"] = "2026-10-12T00:00:00Z"
target = ROOT / "mobile/test/fixtures/result.json"
target.parent.mkdir(parents=True, exist_ok=True)
target.write_text(json.dumps(fixture, indent=2) + "\n", encoding="utf-8")
(ROOT / "docs/openapi.json").write_text(json.dumps(app.openapi(), indent=2) + "\n", encoding="utf-8")


def sql_literal(value):
    return "'" + str(value).replace("'", "''") + "'"


rows = []
for item in CATALOG.values():
    rows.append("(" + ", ".join(sql_literal(value) for value in [
        item.code, item.title, item.explanation, json.dumps(item.possible_causes),
        json.dumps(item.next_checks), item.coverage,
    ]) + ")")
(ROOT / "supabase/seed.sql").write_text(
    "-- Generated demo catalog; run after migration as database admin.\n"
    "insert into public.dtc_catalog(code, title, explanation, possible_causes, next_checks, coverage)\n"
    "values\n" + ",\n".join(rows) + "\non conflict (code) do update set\n"
    "title=excluded.title, explanation=excluded.explanation,\n"
    "possible_causes=excluded.possible_causes, next_checks=excluded.next_checks,\n"
    "coverage=excluded.coverage;\n", encoding="utf-8")
print("Exported OpenAPI, mobile contract fixture, and Supabase demo seed.")
