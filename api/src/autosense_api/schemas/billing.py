"""Billing request/response schemas."""

from pydantic import BaseModel, Field


class VerifyPurchase(BaseModel):
    # repr=False keeps the bearer purchase token out of logs and tracebacks.
    token: str = Field(min_length=10, max_length=4096, repr=False)
