"""DTC catalog lookup endpoint."""

import re

from fastapi import APIRouter, HTTPException

from ..data.catalog import lookup
from ..schemas.diagnostics import DTC_PATTERN, DtcLookup

router = APIRouter()


@router.get("/v1/dtc/{code}", response_model=DtcLookup)
def dtc_lookup(code: str) -> DtcLookup:
    code = code.strip().upper()
    if not re.fullmatch(DTC_PATTERN, code):
        raise HTTPException(status_code=422, detail="Invalid DTC format")
    return lookup(code)
