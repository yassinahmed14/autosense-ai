"""Deterministic rules engine (``rules-v1``) producing preliminary, unconfirmed guidance."""

from datetime import UTC, datetime
from uuid import uuid4

from ..data.catalog import lookup
from ..schemas.diagnostics import (
    DiagnosticRequest,
    DiagnosticResult,
    PossibleCause,
    SafetyFlag,
    Urgency,
)

SAFETY_MESSAGE = (
    "This is preliminary guidance, not a diagnosis or a determination that driving is safe. "
    "If overheating, oil-pressure warnings, braking/steering trouble, smoke, strong fuel smell, "
    "or a flashing check-engine light occurs, reach a safe stopping place and seek professional "
    "or roadside assistance. Follow your vehicle owner's manual."
)
SUMMARY = "Preliminary possibilities based on supplied information; no failed part confirmed."
ADAPTER_LIMITATION = (
    "Experimental adapter input is client-supplied, not verified by the backend. "
    "Only stored engine/emissions codes were requested; no adapter compatibility "
    "or complete vehicle-health assessment is established."
)


def diagnose(request: DiagnosticRequest) -> DiagnosticResult:
    dtcs = [lookup(code) for code in request.codes]
    causes: dict[str, list[str]] = {}
    checks: list[str] = []
    for result in dtcs:
        if result.entry:
            for cause in result.entry.possible_causes:
                causes.setdefault(cause, []).append(result.code)
            checks.extend(result.entry.next_checks)

    symptom_hypotheses = {
        "rough_idle": ["Ignition system issue", "Unmetered intake air"],
        "hard_start": ["Starting electrical or fuel supply issue"],
        "reduced_power": ["Air/fuel control or drivetrain issue"],
        "poor_fuel_economy": ["Operating conditions or fuel control issue"],
        "unusual_noise": ["Mechanical or accessory issue requiring inspection"],
    }
    for symptom in request.symptoms:
        for cause in symptom_hypotheses[symptom.value]:
            causes.setdefault(cause, []).append(f"Reported symptom: {symptom.value}")

    reasons: list[str] = []
    urgency: Urgency
    if request.safety_flags:
        urgency = "stop_safely"
        reasons = [f"Reported safety concern: {flag.value}" for flag in request.safety_flags]
    elif not request.safety_check_completed or request.notes:
        # Free text is deliberately NOT interpreted by an NLP safety classifier.
        # Even with a completed checklist, notes could contain an unclassified hazard.
        urgency = "unassessed"
        reasons = ["Safety checklist missing or free-text notes require human review."]
    elif any(code.startswith("P030") for code in request.codes):
        urgency = "urgent"
        reasons = ["A reported misfire code warrants prompt professional review."]
    else:
        urgency = "inspection"
        reasons = ["Arrange inspection; the inputs cannot establish whether driving is safe."]

    if urgency == "stop_safely":
        checks.insert(
            0, "Reach a safe stopping place and contact professional or roadside assistance."
        )
    if SafetyFlag.overheating in request.safety_flags:
        checks.insert(0, "Do not open a hot cooling system.")
    if request.notes:
        checks.insert(
            0, "Show your notes to a technician; this starter does not interpret free text."
        )
    if not request.safety_check_completed:
        checks.insert(0, "Complete the safety checklist before relying on the guidance.")
    if any(not item.found for item in dtcs):
        checks.append("Ask for OEM definitions for codes missing from this catalog.")
    checks += [
        "Record when the issue occurs and preserve codes/freeze-frame data.",
        "Have a qualified technician confirm the cause before replacing parts.",
    ]
    return DiagnosticResult(
        id=uuid4(),
        created_at=datetime.now(UTC),
        source=request.source,
        simulated=request.source == "mock_obd",
        summary=SUMMARY,
        urgency=urgency,
        urgency_reasons=reasons,
        dtcs=dtcs,
        possible_causes=[
            PossibleCause(title=title, evidence=evidence) for title, evidence in causes.items()
        ],
        next_steps=list(dict.fromkeys(checks)),
        limitations=[
            "Rule-based demo: no AI model, probabilities, or validated diagnostic accuracy.",
            "Eight generic code definitions; manufacturer-specific coverage is not included.",
            "Vehicle details are context only; rules are not tailored to make/model/year.",
            "No live vehicle measurements were analyzed. Free text requires human review.",
            "No codes does not mean no fault. Mock scans contain simulated evidence.",
            *([ADAPTER_LIMITATION] if request.source in {"ble_obd", "wifi_obd"} else []),
        ],
        safety_message=SAFETY_MESSAGE,
    )
