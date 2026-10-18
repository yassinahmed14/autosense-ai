"""Diagnostic guidance endpoint."""

from fastapi import APIRouter

from ..schemas.diagnostics import DiagnosticRequest, DiagnosticResult
from ..services.diagnostics import diagnose

router = APIRouter()


@router.post("/v1/diagnostics", response_model=DiagnosticResult)
def diagnostics(request: DiagnosticRequest) -> DiagnosticResult:
    return diagnose(request)
