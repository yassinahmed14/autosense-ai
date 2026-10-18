"""Runtime configuration loaded from environment variables (and an optional ``.env``)."""

from functools import lru_cache
from typing import Literal

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# Browser previews hosted on Vercel (https://<name>.vercel.app) plus any local dev port.
DEFAULT_CORS_ORIGIN_REGEX = (
    r"https://[a-z0-9]([a-z0-9-]*[a-z0-9])?\.vercel\.app|http://(localhost|127\.0\.0\.1)(:\d+)?"
)


class Settings(BaseSettings):
    """Typed application settings. No auth or remote storage is configured here."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_env: Literal["development", "production"] = "development"
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR"] = "INFO"
    # JSON array of exact origins. Needed only for browser clients; native apps ignore CORS.
    cors_origins: list[str] = ["http://localhost:3000", "http://127.0.0.1:3000"]
    # Full-match regex for additional origins. Set to an empty string to disable.
    cors_origin_regex: str | None = DEFAULT_CORS_ORIGIN_REGEX

    @field_validator("cors_origin_regex")
    @classmethod
    def blank_regex_disables(cls, value: str | None) -> str | None:
        return value or None

    @property
    def is_production(self) -> bool:
        return self.app_env == "production"


@lru_cache
def get_settings() -> Settings:
    """Process-wide cached settings for the default application instance."""
    return Settings()
