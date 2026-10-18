from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")
    # Local development only. No auth or remote storage in this starter.
    cors_origins: list[str] = ["http://localhost:3000", "http://127.0.0.1:3000"]
