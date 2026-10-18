import json
from pathlib import Path

from app.diagnostics import diagnose
from app.models import DiagnosticRequest, DiagnosticResult


def test_mobile_fixture_matches_current_backend_contract():
    fixture_path = Path(__file__).resolve().parents[2] / "mobile/test/fixtures/result.json"
    fixture = DiagnosticResult.model_validate_json(fixture_path.read_text(encoding="utf-8"))
    actual = diagnose(
        DiagnosticRequest(codes=["P0300", "P0171"], source="mock_obd", safety_check_completed=True)
    )
    exclude = {"id", "created_at"}
    assert fixture.model_dump(exclude=exclude) == actual.model_dump(exclude=exclude)


def test_openapi_snapshot_is_current():
    from app.main import app

    snapshot = Path(__file__).resolve().parents[2] / "docs/openapi.json"
    assert json.loads(snapshot.read_text(encoding="utf-8")) == app.openapi()
