"""Pure entitlement logic for Google Play subscription payloads."""

from datetime import UTC, datetime, timedelta

import pytest

from autosense_api.services.billing import enabled, entitlement

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


def test_entitlement_ignores_malformed_and_naive_expiry():
    payload = {
        "subscriptionState": "SUBSCRIPTION_STATE_ACTIVE",
        "lineItems": [
            {"productId": "autosense_pro", "offerDetails": {"basePlanId": "monthly"}},
            {
                "productId": "autosense_pro",
                "offerDetails": {"basePlanId": "monthly"},
                "expiryTime": "2030-01-01T00:00:00",
            },
        ],
    }
    assert entitlement(payload, NOW) == {"active": False, "expires_at": None}


def test_entitlement_picks_latest_expiry():
    later = NOW + timedelta(days=30)
    item = {"productId": "autosense_pro", "offerDetails": {"basePlanId": "annual"}}
    payload = {
        "subscriptionState": "SUBSCRIPTION_STATE_ACTIVE",
        "lineItems": [
            {**item, "expiryTime": (NOW + timedelta(days=1)).isoformat()},
            {**item, "expiryTime": later.isoformat()},
        ],
    }
    assert entitlement(payload, NOW) == {"active": True, "expires_at": later.isoformat()}


def test_enabled_requires_all_variables(monkeypatch):
    monkeypatch.setenv("PLAY_BILLING_ENABLED", "true")
    monkeypatch.setenv("PLAY_PACKAGE_NAME", "com.example")
    monkeypatch.delenv("GOOGLE_APPLICATION_CREDENTIALS", raising=False)
    assert enabled() is False
    monkeypatch.setenv("GOOGLE_APPLICATION_CREDENTIALS", "/tmp/creds.json")
    assert enabled() is True
