"""Browser CORS policy: explicit allowlist plus the configurable origin regex."""

import pytest
from fastapi.testclient import TestClient

from autosense_api.core.settings import Settings
from autosense_api.main import create_app


def preflight(client: TestClient, origin: str):
    return client.options(
        "/v1/diagnostics",
        headers={"Origin": origin, "Access-Control-Request-Method": "POST"},
    )


@pytest.mark.parametrize(
    "origin",
    [
        "http://localhost:3000",
        "http://localhost:51234",
        "http://127.0.0.1:8080",
        "https://autosense-app.vercel.app",
        "https://autosense-app-git-main-team.vercel.app",
    ],
)
def test_default_policy_allows_local_and_vercel(client, origin):
    response = preflight(client, origin)
    assert response.status_code == 200
    assert response.headers["access-control-allow-origin"] == origin


@pytest.mark.parametrize(
    "origin",
    [
        "https://unknown.example",
        "http://autosense.vercel.app",
        "https://vercel.app.evil.example",
        "https://evil.example/.vercel.app",
        "http://localhost.evil.example",
    ],
)
def test_default_policy_denies_others(client, origin):
    assert preflight(client, origin).status_code == 400


def test_explicit_origins_and_disabled_regex():
    settings = Settings(_env_file=None, cors_origins=["https://app.example"], cors_origin_regex="")
    with TestClient(create_app(settings)) as client:
        assert preflight(client, "https://app.example").status_code == 200
        assert preflight(client, "https://autosense-app.vercel.app").status_code == 400
        assert preflight(client, "http://localhost:3000").status_code == 400


def test_simple_request_exposes_request_id(client):
    response = client.get("/health", headers={"Origin": "https://autosense-app.vercel.app"})
    assert response.headers["access-control-allow-origin"] == "https://autosense-app.vercel.app"
    assert "x-request-id" in response.headers["access-control-expose-headers"].lower()
