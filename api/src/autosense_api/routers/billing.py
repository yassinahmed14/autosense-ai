"""Billing endpoints. Verification stays disabled unless explicitly configured."""

from typing import Any

from fastapi import APIRouter

from ..schemas.billing import VerifyPurchase
from ..services import billing

router = APIRouter(prefix="/v1/billing", tags=["billing"])


@router.get("/config", response_model=None)
def billing_config() -> dict[str, Any]:
    # Does not publish credentials or service-account details.
    return {"enabled": billing.enabled(), "product_id": billing.PRODUCT}


@router.post("/verify", response_model=None)
def verify_purchase(request: VerifyPurchase) -> dict[str, Any]:
    return billing.verify(request.token)
