import re
from datetime import datetime
from enum import StrEnum
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

DTC_PATTERN = r"^[PBCU][0-3][0-9A-F]{3}$"


class StrictModel(BaseModel):
    model_config = ConfigDict(extra="forbid")


class Symptom(StrEnum):
    rough_idle = "rough_idle"
    hard_start = "hard_start"
    reduced_power = "reduced_power"
    poor_fuel_economy = "poor_fuel_economy"
    unusual_noise = "unusual_noise"


class SafetyFlag(StrEnum):
    flashing_mil = "flashing_mil"
    overheating = "overheating"
    oil_pressure_warning = "oil_pressure_warning"
    brake_or_steering_issue = "brake_or_steering_issue"
    smoke_or_fuel_smell = "smoke_or_fuel_smell"


class Vehicle(StrictModel):
    make: str = Field(default="", max_length=60)
    model: str = Field(default="", max_length=60)
    year: int | None = Field(default=None, ge=1900, le=2100)


class DiagnosticRequest(StrictModel):
    vehicle: Vehicle = Field(default_factory=Vehicle)
    codes: list[str] = Field(default_factory=list, max_length=20)
    symptoms: list[Symptom] = Field(default_factory=list, max_length=5)
    notes: str = Field(default="", max_length=2000)
    safety_flags: list[SafetyFlag] = Field(default_factory=list, max_length=5)
    safety_check_completed: bool = False
    source: Literal["manual", "mock_obd", "ble_obd", "wifi_obd"] = "manual"

    @field_validator("codes")
    @classmethod
    def validate_codes(cls, codes: list[str]) -> list[str]:
        normalized = list(dict.fromkeys(c.strip().upper() for c in codes))
        if any(not re.fullmatch(DTC_PATTERN, c) for c in normalized):
            raise ValueError("Use 5-character DTCs such as P0300 or U0100")
        return normalized

    @field_validator("notes")
    @classmethod
    def trim_notes(cls, value: str) -> str:
        return value.strip()

    @model_validator(mode="after")
    def require_evidence(self):
        if not (self.codes or self.symptoms or self.notes or self.safety_flags):
            raise ValueError("Enter a DTC, symptom, note, or safety concern")
        return self


class DtcEntry(StrictModel):
    code: str
    title: str
    explanation: str
    possible_causes: list[str]
    next_checks: list[str]
    coverage: Literal["starter_generic"] = "starter_generic"


class DtcLookup(StrictModel):
    code: str
    found: bool
    entry: DtcEntry | None = None
    message: str


class PossibleCause(StrictModel):
    title: str
    evidence: list[str]
    certainty: Literal["unconfirmed"] = "unconfirmed"


class DiagnosticResult(StrictModel):
    id: UUID
    created_at: datetime
    engine: Literal["rules-v1"] = "rules-v1"
    source: Literal["manual", "mock_obd", "ble_obd", "wifi_obd"]
    simulated: bool
    summary: str
    urgency: Literal["unassessed", "inspection", "urgent", "stop_safely"]
    urgency_reasons: list[str]
    dtcs: list[DtcLookup]
    possible_causes: list[PossibleCause]
    next_steps: list[str]
    limitations: list[str]
    safety_message: str
