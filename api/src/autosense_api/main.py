"""Application factory and ASGI entrypoint (``uvicorn autosense_api.main:app``)."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import __version__
from .core.errors import register_error_handlers
from .core.logging import configure_logging
from .core.middleware import REQUEST_ID_HEADER, RequestIdMiddleware
from .core.settings import Settings, get_settings
from .routers import billing, diagnostics, dtc, health


def create_app(settings: Settings | None = None) -> FastAPI:
    """Build a configured FastAPI application."""
    settings = settings or get_settings()
    configure_logging(settings.log_level, json_output=settings.is_production)
    api = FastAPI(
        title="AutoSense AI Starter",
        version=__version__,
        description="Local rule-based guidance. No authentication or persistence yet.",
    )
    api.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_origin_regex=settings.cors_origin_regex,
        allow_methods=["GET", "POST"],
        allow_headers=["Content-Type"],
        expose_headers=[REQUEST_ID_HEADER],
    )
    # Added last so it is outermost: every response (including CORS preflight) gets an id.
    api.add_middleware(RequestIdMiddleware)
    register_error_handlers(api)

    api.include_router(billing.router)
    api.include_router(health.router)
    api.include_router(dtc.router)
    api.include_router(diagnostics.router)
    return api


app = create_app()
