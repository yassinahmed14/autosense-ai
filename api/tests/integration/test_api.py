"""End-to-end HTTP behavior of the diagnostics and DTC endpoints."""

import pytest
from fastapi.testclient import TestClient

from autosense_api.core.settings import Settings
from autosense_api.main import create_app

client = TestClient(create_app(Settings(_env_file=None)))


def test_health():
    assert client.get("/health").json()["storage"] == "none"


@pytest.mark.parametrize("source", ["ble_obd", "wifi_obd"])
def test_adapter_source_is_preserved_with_unverified_limitations(source):
    response = client.post(
        "/v1/diagnostics",
        json={
            "source": source,
            "codes": ["P0300"],
            "safety_check_completed": True,
        },
    )
    assert response.status_code == 200
    result = response.json()
    assert result["source"] == source
    assert result["simulated"] is False
    assert any("not verified by the backend" in line for line in result["limitations"])
    assert all(c["certainty"] == "unconfirmed" for c in result["possible_causes"])


def test_code_normalization_and_deduplication():
    response = client.post(
        "/v1/diagnostics", json={"codes": [" p0300 ", "P0300"], "safety_check_completed": True}
    )
    assert response.status_code == 200
    body = response.json()
    assert len(body["dtcs"]) == 1
    assert body["dtcs"][0]["code"] == "P0300"
    assert body["urgency"] == "urgent"
    assert all(c["certainty"] == "unconfirmed" for c in body["possible_causes"])


@pytest.mark.parametrize(
    "payload",
    [
        {},
        {"codes": ["P9999"]},
        {"codes": ["bad"]},
        {"symptoms": ["other"]},
        {"source": "ble"},
        {"notes": " "},
        {"notes": "x" * 2001},
        {"codes": ["P0300"] * 21},
        {"unexpected": True},
        {"vehicle": {"year": 1800}, "notes": "noise"},
    ],
)
def test_invalid_input(payload):
    assert client.post("/v1/diagnostics", json=payload).status_code == 422


def test_unknown_code_is_not_invented():
    body = client.get("/v1/dtc/P1234").json()
    assert body["found"] is False
    assert body["entry"] is None
    assert client.get("/v1/dtc/P9999").status_code == 422


@pytest.mark.parametrize(
    "flag",
    [
        "flashing_mil",
        "overheating",
        "oil_pressure_warning",
        "brake_or_steering_issue",
        "smoke_or_fuel_smell",
    ],
)
def test_safety_concern_overrides_known_code(flag):
    body = client.post("/v1/diagnostics", json={"codes": ["P0442"], "safety_flags": [flag]}).json()
    assert body["urgency"] == "stop_safely"


def test_free_text_cannot_be_treated_as_safe():
    body = client.post(
        "/v1/diagnostics", json={"notes": "smoke while driving", "safety_check_completed": True}
    ).json()
    assert body["urgency"] == "unassessed"
    assert body["possible_causes"] == []
    assert any("notes" in step for step in body["next_steps"])


def test_missing_checklist_is_unassessed():
    body = client.post("/v1/diagnostics", json={"codes": ["P0442"]}).json()
    assert body["urgency"] == "unassessed"


def test_symptom_only_and_mock_provenance():
    body = client.post(
        "/v1/diagnostics",
        json={"symptoms": ["rough_idle"], "source": "mock_obd", "safety_check_completed": True},
    ).json()
    assert body["simulated"] is True
    assert body["possible_causes"]
    assert body["dtcs"] == []
    assert body["engine"] == "rules-v1"


def test_browser_cors_allowlist():
    allowed = client.options(
        "/v1/diagnostics",
        headers={"Origin": "http://localhost:3000", "Access-Control-Request-Method": "POST"},
    )
    denied = client.options(
        "/v1/diagnostics",
        headers={"Origin": "https://unknown.example", "Access-Control-Request-Method": "POST"},
    )
    assert allowed.status_code == 200
    assert denied.status_code == 400


def test_lookup_case_and_empty_known_fault_claim():
    assert client.get("/v1/dtc/p0420").json()["entry"]["code"] == "P0420"
    body = client.post(
        "/v1/diagnostics", json={"codes": ["P1234"], "safety_check_completed": True}
    ).json()
    assert body["possible_causes"] == []
    assert body["urgency"] == "inspection"
