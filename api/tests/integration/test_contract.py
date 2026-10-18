"""Generated artifacts (Flutter fixture, OpenAPI snapshot) must match the live contract.

Regenerate with ``python scripts/export_contracts.py`` after intentional changes.
"""

import json
from pathlib import Path

from autosense_api.main import create_app
from autosense_api.schemas.diagnostics import DiagnosticRequest, DiagnosticResult
from autosense_api.services.diagnostics import diagnose

REPO_ROOT = Path(__file__).resolve().parents[3]


def test_app_fixture_matches_current_backend_contract():
    fixture_path = REPO_ROOT / "app/test/fixtures/result.json"
    fixture = DiagnosticResult.model_validate_json(fixture_path.read_text(encoding="utf-8"))
    actual = diagnose(
        DiagnosticRequest(codes=["P0300", "P0171"], source="mock_obd", safety_check_completed=True)
    )
    exclude = {"id", "created_at"}
    assert fixture.model_dump(exclude=exclude) == actual.model_dump(exclude=exclude)


def test_openapi_snapshot_is_current():
    snapshot = REPO_ROOT / "docs/architecture/openapi.json"
    assert json.loads(snapshot.read_text(encoding="utf-8")) == create_app().openapi()
