"""Exception handlers that keep error responses free of sensitive input."""

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from .logging import get_logger

_log = get_logger("errors")


async def validation_error(_request: Request, error: RequestValidationError) -> JSONResponse:
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


async def unhandled_error(request: Request, error: Exception) -> JSONResponse:
    # Log only the exception type and request id; messages may contain user input.
    _log.error(
        "unhandled %s",
        type(error).__name__,
        extra={"request_id": request.scope.get("state", {}).get("request_id")},
    )
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})


def register_error_handlers(app: FastAPI) -> None:
    """Install the application's exception handlers."""
    app.add_exception_handler(RequestValidationError, validation_error)  # type: ignore[arg-type]
    app.add_exception_handler(Exception, unhandled_error)
