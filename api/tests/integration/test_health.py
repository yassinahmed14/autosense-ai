"""Health endpoint, request-id propagation and error handling over HTTP."""

from fastapi.testclient import TestClient

from autosense_api.core.settings import Settings
from autosense_api.main import create_app


def test_health_shape(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "engine": "rules-v1", "storage": "none"}


def test_request_id_generated(client):
    request_id = client.get("/health").headers["x-request-id"]
    assert len(request_id) == 32


def test_safe_request_id_is_propagated(client):
    response = client.get("/health", headers={"X-Request-ID": "abc-123"})
    assert response.headers["x-request-id"] == "abc-123"


def test_unsafe_request_id_is_replaced(client):
    response = client.get("/health", headers={"X-Request-ID": "<script>" * 20})
    assert response.headers["x-request-id"] != "<script>" * 20
    assert len(response.headers["x-request-id"]) == 32


def test_unhandled_error_returns_generic_json(settings):
    app = create_app(settings)

    @app.get("/boom")
    def boom():
        raise RuntimeError("sensitive user text")

    with TestClient(app, raise_server_exceptions=False) as client:
        response = client.get("/boom")
    assert response.status_code == 500
    assert response.json() == {"detail": "Internal server error"}
    assert "sensitive" not in response.text


def test_production_app_builds_with_json_logs():
    app = create_app(Settings(_env_file=None, app_env="production"))
    with TestClient(app) as client:
        assert client.get("/health").status_code == 200


def test_privacy_and_terms_html_endpoints(client):
    privacy = client.get("/privacy")
    assert privacy.status_code == 200
    assert "text/html" in privacy.headers["content-type"]
    assert "AutoSense AI Privacy Policy" in privacy.text
    assert "youssefahmed4010@gmail.com" in privacy.text

    terms = client.get("/terms")
    assert terms.status_code == 200
    assert "text/html" in terms.headers["content-type"]
    assert "AutoSense AI Subscription &amp; Service Terms" in terms.text
    assert "EGP 99.00/month" in terms.text
