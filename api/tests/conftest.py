"""Shared fixtures."""

import pytest
from fastapi.testclient import TestClient

from autosense_api.core.settings import Settings
from autosense_api.main import create_app


@pytest.fixture
def settings() -> Settings:
    # Explicit values so tests never depend on a developer's .env file.
    return Settings(_env_file=None, app_env="development")


@pytest.fixture
def client(settings: Settings) -> TestClient:
    with TestClient(create_app(settings)) as test_client:
        yield test_client
