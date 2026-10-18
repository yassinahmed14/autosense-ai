"""Opt-in Google Play verification; disabled without explicit deployment configuration."""

import os
from datetime import UTC, datetime
from urllib.parse import quote

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

router = APIRouter(prefix="/v1/billing", tags=["billing"])
PRODUCT = "autosense_pro"


class VerifyPurchase(BaseModel):
    token: str = Field(min_length=10, max_length=4096, repr=False)


def enabled() -> bool:
    return (
        os.getenv("PLAY_BILLING_ENABLED") == "true"
        and bool(os.getenv("GOOGLE_APPLICATION_CREDENTIALS"))
        and bool(os.getenv("PLAY_PACKAGE_NAME"))
    )


def entitlement(payload: dict, now: datetime) -> dict:
    allowed_states = {
        "SUBSCRIPTION_STATE_ACTIVE",
        "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
        "SUBSCRIPTION_STATE_CANCELED",
    }
    if payload.get("subscriptionState") not in allowed_states:
        return {"active": False, "expires_at": None}
    expiries = []
    for item in payload.get("lineItems", []):
        if item.get("productId") != PRODUCT:
            continue
        if item.get("offerDetails", {}).get("basePlanId") not in {"monthly", "annual"}:
            continue
        try:
            expiry = datetime.fromisoformat(item["expiryTime"])
        except (KeyError, ValueError, TypeError):
            continue
        if expiry.tzinfo is not None and expiry > now:
            expiries.append(expiry)
    expiry = max(expiries) if expiries else None
    return {"active": expiry is not None, "expires_at": expiry.isoformat() if expiry else None}


@router.get("/config")
def billing_config():
    # Does not publish credentials or service-account details.
    return {"enabled": enabled(), "product_id": PRODUCT}


@router.post("/verify")
def verify_purchase(request: VerifyPurchase):
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
        token = quote(request.token, safe="")
        url = (
            f"https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{package}"
            f"/purchases/subscriptionsv2/tokens/{token}"
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
                    f"{package}/purchases/subscriptions/{PRODUCT}/tokens/{token}:acknowledge"
                )
                ack = session.post(ack_url, json={}, timeout=15)
                ack.raise_for_status()
            return result
    except Exception:  # noqa: BLE001 -- prevent purchase-token leakage from upstream errors
        # Upstream exceptions can contain bearer purchase tokens: never echo/log them.
        raise HTTPException(503, "Google Play verification temporarily unavailable") from None
