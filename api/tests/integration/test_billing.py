"""Billing endpoints over HTTP: disabled by default and never echo purchase tokens."""

from fastapi.testclient import TestClient

from autosense_api.core.settings import Settings
from autosense_api.main import create_app


def test_billing_disabled_without_credentials(monkeypatch):
    monkeypatch.delenv("PLAY_BILLING_ENABLED", raising=False)
    with TestClient(create_app(Settings(_env_file=None))) as client:
        assert client.get("/v1/billing/config").json()["enabled"] is False
        response = client.post("/v1/billing/verify", json={"token": "test-token-not-a-purchase"})
        assert response.status_code == 503
        assert "test-token" not in response.text


def test_invalid_purchase_token_not_echoed():
    with TestClient(create_app(Settings(_env_file=None))) as client:
        response = client.post("/v1/billing/verify", json={"token": "secret"})
        assert response.status_code == 422
        assert "secret" not in response.text


def test_billing_config_shape(client):
    assert client.get("/v1/billing/config").json() == {
        "enabled": False,
        "product_id": "autosense_pro",
    }
