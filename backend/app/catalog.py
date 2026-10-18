"""Small editorial demo catalog. Verify OEM definitions before real-world use.

Not a licensed SAE/OEM database, and not complete manufacturer coverage.
"""

from .models import DtcEntry, DtcLookup


def entry(code, title, explanation, causes, checks):
    return DtcEntry(
        code=code, title=title, explanation=explanation, possible_causes=causes, next_checks=checks
    )


CATALOG = {
    "P0300": entry(
        "P0300",
        "Random/multiple cylinder misfire detected",
        "The controller reported irregular combustion across multiple cylinders.",
        ["Ignition system issue", "Fuel delivery issue", "Intake air leak or mechanical issue"],
        [
            "Ask a technician to review freeze-frame and misfire counters",
            "Have ignition, fuel delivery and compression tested before replacing parts",
        ],
    ),
    "P0301": entry(
        "P0301",
        "Cylinder 1 misfire detected",
        "The controller reported a misfire associated with cylinder 1.",
        ["Ignition system issue", "Injector or compression issue"],
        [
            "Confirm cylinder numbering in OEM service information",
            "Have cylinder-specific ignition, injector and compression tests performed",
        ],
    ),
    "P0171": entry(
        "P0171",
        "System too lean (bank 1)",
        "Fuel control reported a lean condition on bank 1; this does not identify a failed part.",
        ["Unmetered intake air", "Fuel delivery issue", "Air/fuel sensor measurement issue"],
        [
            "Have fuel trims reviewed under multiple operating conditions",
            "Ask for intake leak and fuel pressure checks",
        ],
    ),
    "P0420": entry(
        "P0420",
        "Catalyst system efficiency below threshold (bank 1)",
        "The controller reported catalyst monitor results outside its threshold.",
        ["Catalyst deterioration", "Exhaust leak or sensor issue", "Upstream combustion issue"],
        [
            "Resolve related misfire/fuel codes first",
            "Have exhaust leaks and sensor behavior checked before catalyst replacement",
        ],
    ),
    "P0442": entry(
        "P0442",
        "Evaporative emission system leak detected (small leak)",
        "The evaporative emissions monitor reported a small leak.",
        ["Fuel cap seal issue", "EVAP hose or valve leak"],
        [
            "With the engine off, check the fuel cap is seated per the owner's manual",
            "Ask a technician for an approved EVAP leak test",
        ],
    ),
    "P0455": entry(
        "P0455",
        "Evaporative emission system leak detected (large leak)",
        "The evaporative emissions monitor reported a large leak or lack of flow.",
        ["Missing or loose fuel cap", "EVAP hose or valve issue"],
        [
            "Check cap seating with the engine off",
            "Have the EVAP system inspected; fuel smell takes priority",
        ],
    ),
    "P0128": entry(
        "P0128",
        "Coolant temperature below thermostat regulating temperature",
        "Warm-up behavior did not meet the controller's expected temperature profile.",
        ["Thermostat regulation issue", "Coolant level or temperature sensor issue"],
        [
            "Review coolant temperature data with a technician",
            "Never open a hot cooling system; follow OEM inspection instructions",
        ],
    ),
    "U0100": entry(
        "U0100",
        "Lost communication with ECM/PCM A",
        "A controller reported loss of communication with the engine/powertrain module.",
        ["Power supply or wiring issue", "Network communication issue"],
        [
            "Have battery supply, grounds and network communication checked",
            "Do not assume the control module itself has failed",
        ],
    ),
}


def lookup(code: str) -> DtcLookup:
    code = code.strip().upper()
    record = CATALOG.get(code)
    return DtcLookup(
        code=code,
        found=record is not None,
        entry=record,
        message="Generic demo definition; verify against OEM service information."
        if record
        else "Not in the starter catalog. Obtain the vehicle-specific definition.",
    )
