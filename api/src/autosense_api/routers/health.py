"""Liveness endpoint."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/health", response_model=None)
def health() -> dict[str, str]:
    return {"status": "ok", "engine": "rules-v1", "storage": "none"}
