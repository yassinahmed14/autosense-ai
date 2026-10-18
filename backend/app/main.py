import re

from fastapi import FastAPI, HTTPException
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .billing import router as billing_router
from .catalog import lookup
from .config import Settings
from .diagnostics import diagnose
from .models import DTC_PATTERN, DiagnosticRequest, DiagnosticResult, DtcLookup


def create_app() -> FastAPI:
    settings = Settings()
    api = FastAPI(
        title="AutoSense AI Starter",
        version="0.1.0",
        description="Local rule-based guidance. No authentication or persistence yet.",
    )
    api.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_methods=["GET", "POST"],
        allow_headers=["Content-Type"],
    )
    api.include_router(billing_router)

    @api.exception_handler(RequestValidationError)
    async def validation_error(_request, error):
        # Validation errors must not echo purchase tokens or user-provided notes.
        return JSONResponse(
            status_code=422,
            content={
                "detail": [
                    {"loc": item["loc"], "msg": item["msg"], "type": item["type"]}
                    for item in error.errors()
                ]
            },
        )

    @api.get("/health")
    def health():
        return {"status": "ok", "engine": "rules-v1", "storage": "none"}

    @api.get("/v1/dtc/{code}", response_model=DtcLookup)
    def dtc_lookup(code: str):
        code = code.strip().upper()
        if not re.fullmatch(DTC_PATTERN, code):
            raise HTTPException(status_code=422, detail="Invalid DTC format")
        return lookup(code)

    @api.post("/v1/diagnostics", response_model=DiagnosticResult)
    def diagnostics(request: DiagnosticRequest):
        return diagnose(request)

    return api


app = create_app()
