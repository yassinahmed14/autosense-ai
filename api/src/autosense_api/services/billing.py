"""Opt-in Google Play verification; disabled without explicit deployment configuration."""

import os
from datetime import UTC, datetime
from typing import Any
from urllib.parse import quote

from fastapi import HTTPException

PRODUCT = "autosense_pro"
ALLOWED_STATES = frozenset(
    {
        "SUBSCRIPTION_STATE_ACTIVE",
        "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
        "SUBSCRIPTION_STATE_CANCELED",
    }
)
ALLOWED_BASE_PLANS = frozenset({"monthly", "annual"})


def enabled() -> bool:
    """Billing is active only when explicitly enabled AND credentials/package are present.

    Read at call time so deployments (and tests) can toggle it via the environment.
    """
    return (
        os.getenv("PLAY_BILLING_ENABLED") == "true"
        and bool(os.getenv("GOOGLE_APPLICATION_CREDENTIALS"))
        and bool(os.getenv("PLAY_PACKAGE_NAME"))
    )


def entitlement(payload: dict[str, Any], now: datetime) -> dict[str, Any]:
    """Derive the Pro entitlement from a Play ``subscriptionsv2`` payload."""
    if payload.get("subscriptionState") not in ALLOWED_STATES:
        return {"active": False, "expires_at": None}
    expiries = []
    for item in payload.get("lineItems", []):
        if item.get("productId") != PRODUCT:
            continue
        if item.get("offerDetails", {}).get("basePlanId") not in ALLOWED_BASE_PLANS:
            continue
        try:
            expiry = datetime.fromisoformat(item["expiryTime"])
        except (KeyError, ValueError, TypeError):
            continue
        if expiry.tzinfo is not None and expiry > now:
            expiries.append(expiry)
    expiry = max(expiries) if expiries else None
    return {"active": expiry is not None, "expires_at": expiry.isoformat() if expiry else None}


def verify(token: str) -> dict[str, Any]:
    """Verify (and acknowledge if pending) a purchase token with Google Play."""
    if not enabled():
        raise HTTPException(503, "Subscription verification is not configured")
    try:
        from google.auth.transport.requests import AuthorizedSession
        from google.oauth2 import service_account

        credentials = service_account.Credentials.from_service_account_file(
            os.environ["GOOGLE_APPLICATION_CREDENTIALS"],
            scopes=["https://www.googleapis.com/auth/androidpublisher"],
        )
        package = quote(os.environ["PLAY_PACKAGE_NAME"], safe="")
        quoted_token = quote(token, safe="")
        url = (
            f"https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{package}"
            f"/purchases/subscriptionsv2/tokens/{quoted_token}"
        )
        with AuthorizedSession(credentials) as session:
            response = session.get(url, timeout=15)
            if response.status_code in {400, 404, 410}:
                return {"active": False, "expires_at": None}
            response.raise_for_status()
            payload = response.json()
            result = entitlement(payload, datetime.now(UTC))
            if result["active"] and payload.get("acknowledgementState") == (
                "ACKNOWLEDGEMENT_STATE_PENDING"
            ):
                ack_url = (
                    "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/"
                    f"{package}/purchases/subscriptions/{PRODUCT}/tokens/{quoted_token}:acknowledge"
                )
                ack = session.post(ack_url, json={}, timeout=15)
                ack.raise_for_status()
            return result
    except Exception:  # noqa: BLE001 -- prevent purchase-token leakage from upstream errors
        # Upstream exceptions can contain bearer purchase tokens: never echo/log them.
        raise HTTPException(503, "Google Play verification temporarily unavailable") from None
