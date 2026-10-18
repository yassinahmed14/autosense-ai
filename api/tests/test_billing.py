from datetime import UTC, datetime, timedelta

import pytest
from fastapi.testclient import TestClient

from app.billing import entitlement
from app.main import create_app

NOW = datetime(2026, 10, 15, tzinfo=UTC)


@pytest.mark.parametrize(
    "state,days,product,plan,expected",
    [
        ("ACTIVE", 1, "autosense_pro", "monthly", True),
        ("CANCELED", 1, "autosense_pro", "annual", True),
        ("IN_GRACE_PERIOD", 1, "autosense_pro", "monthly", True),
        ("ACTIVE", -1, "autosense_pro", "monthly", False),
        ("ON_HOLD", 1, "autosense_pro", "monthly", False),
        ("PENDING", 1, "autosense_pro", "monthly", False),
        ("EXPIRED", 1, "autosense_pro", "monthly", False),
        ("ACTIVE", 1, "another_product", "monthly", False),
        ("ACTIVE", 1, "autosense_pro", "unknown", False),
    ],
)
def test_entitlement_state_and_expiry(state, days, product, plan, expected):
    payload = {
        "subscriptionState": f"SUBSCRIPTION_STATE_{state}",
        "lineItems": [
            {
                "productId": product,
                "offerDetails": {"basePlanId": plan},
                "expiryTime": (NOW + timedelta(days=days)).isoformat(),
            }
        ],
    }
    assert entitlement(payload, NOW)["active"] is expected


def test_billing_disabled_without_credentials(monkeypatch):
    monkeypatch.delenv("PLAY_BILLING_ENABLED", raising=False)
    with TestClient(create_app()) as client:
        assert client.get("/v1/billing/config").json()["enabled"] is False
        response = client.post("/v1/billing/verify", json={"token": "test-token-not-a-purchase"})
        assert response.status_code == 503
        assert "test-token" not in response.text


def test_invalid_purchase_token_not_echoed():
    with TestClient(create_app()) as client:
        response = client.post("/v1/billing/verify", json={"token": "secret"})
        assert response.status_code == 422
        assert "secret" not in response.text
