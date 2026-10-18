"""Settings parsing from environment variables."""

import pytest
from pydantic import ValidationError

from autosense_api.core.settings import DEFAULT_CORS_ORIGIN_REGEX, Settings, get_settings


def test_defaults(monkeypatch):
    for name in ("APP_ENV", "CORS_ORIGINS", "CORS_ORIGIN_REGEX", "LOG_LEVEL"):
        monkeypatch.delenv(name, raising=False)
    settings = Settings(_env_file=None)
    assert settings.app_env == "development"
    assert settings.is_production is False
    assert settings.cors_origins == ["http://localhost:3000", "http://127.0.0.1:3000"]
    assert settings.cors_origin_regex == DEFAULT_CORS_ORIGIN_REGEX
    assert settings.log_level == "INFO"


def test_env_overrides(monkeypatch):
    monkeypatch.setenv("APP_ENV", "production")
    monkeypatch.setenv("CORS_ORIGINS", '["https://a.example","https://b.example"]')
    monkeypatch.setenv("CORS_ORIGIN_REGEX", r"https://.*\.example\.org")
    monkeypatch.setenv("LOG_LEVEL", "WARNING")
    settings = Settings(_env_file=None)
    assert settings.is_production is True
    assert settings.cors_origins == ["https://a.example", "https://b.example"]
    assert settings.cors_origin_regex == r"https://.*\.example\.org"
    assert settings.log_level == "WARNING"


def test_empty_regex_disables(monkeypatch):
    monkeypatch.setenv("CORS_ORIGIN_REGEX", "")
    assert Settings(_env_file=None).cors_origin_regex is None


def test_invalid_app_env_rejected(monkeypatch):
    monkeypatch.setenv("APP_ENV", "staging")
    with pytest.raises(ValidationError):
        Settings(_env_file=None)


def test_get_settings_is_cached():
    assert get_settings() is get_settings()
