"""Vercel Python entrypoint: exposes the ASGI ``app`` from the src-layout package."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "src"))

from autosense_api.main import app

__all__ = ["app"]
