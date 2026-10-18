"""Expanded generic SAE J2012 editorial catalog (56 codes across P, B, C, U systems).

Verify OEM definitions before real-world use. Not a licensed SAE/OEM database,
and not complete manufacturer coverage.
"""

from ..schemas.diagnostics import DtcEntry, DtcLookup


def entry(
    code: str, title: str, explanation: str, causes: list[str], checks: list[str]
) -> DtcEntry:
    return DtcEntry(
        code=code, title=title, explanation=explanation, possible_causes=causes, next_checks=checks
    )


CATALOG: dict[str, DtcEntry] = {
    # --- Original 8 core codes (preserved verbatim for contract compatibility) ---
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
    # --- Expanded Powertrain: Air/Fuel & Sensors (P01xx - P02xx) ---
    "P0101": entry(
        "P0101",
        "Mass or volume air flow A circuit range/performance",
        "Measured mass air flow differed from expected range for current engine load and RPM.",
        ["Intake duct leak or restriction", "Contaminated or faulty MAF sensor", "Wiring issue"],
        [
            "Inspect air filter housing and intake boot for leaks or debris",
            "Compare live MAF grams/sec readings at idle and under load",
        ],
    ),
    "P0102": entry(
        "P0102",
        "Mass or volume air flow A circuit low input",
        "The controller detected an abnormally low signal from the mass air flow sensor circuit.",
        ["Unplugged or open MAF harness", "MAF sensor supply voltage issue", "Sensor fault"],
        [
            "Verify MAF connector seating and reference voltage with a multimeter",
            "Inspect intake tract and sensor element",
        ],
    ),
    "P0106": entry(
        "P0106",
        "Manifold absolute pressure/barometric pressure circuit range/performance",
        "MAP sensor signal did not correlate with throttle angle or barometric reference.",
        ["Vacuum hose leak or blockage", "MAP sensor or connector fault", "Exhaust restriction"],
        [
            "Compare key-on engine-off MAP reading with local barometric pressure",
            "Inspect vacuum port and wiring harness",
        ],
    ),
    "P0113": entry(
        "P0113",
        "Intake air temperature sensor 1 circuit high (bank 1)",
        "The IAT sensor circuit reported a high voltage (typically indicating an open circuit).",
        ["Disconnected IAT sensor plug", "Open wire in IAT harness", "Faulty IAT sensor"],
        [
            "Check live intake air temperature reading with key on",
            "Inspect the IAT/MAF connector pins and wiring",
        ],
    ),
    "P0118": entry(
        "P0118",
        "Engine coolant temperature sensor 1 circuit high",
        "The ECT sensor circuit reported a high voltage (often an open circuit or cold reading).",
        ["Open ECT sensor circuit or unplugged connector", "Faulty coolant temperature sensor"],
        [
            "Compare cold key-on ECT reading with ambient temperature",
            "Never open a hot cooling system; inspect sensor wiring safely",
        ],
    ),
    "P0122": entry(
        "P0122",
        "Throttle/pedal position sensor/switch A circuit low",
        "Throttle position sensor A reported voltage below the minimum calibrated threshold.",
        ["TPS signal or 5V reference wiring fault", "Throttle body sensor issue"],
        [
            "Review live throttle position percentage with ignition on and engine off",
            "Have throttle body connector and 5V reference inspected",
        ],
    ),
    "P0130": entry(
        "P0130",
        "O2 sensor circuit (bank 1, sensor 1)",
        "The upstream oxygen or air-fuel sensor signal on bank 1 was out of expected range.",
        ["Exhaust leak upstream of sensor", "O2 sensor wiring or element issue", "Fuel trim fault"],
        [
            "Inspect sensor wiring near hot exhaust manifolds",
            "Have live upstream O2 sensor switching or current waveform tested",
        ],
    ),
    "P0135": entry(
        "P0135",
        "O2 sensor heater circuit (bank 1, sensor 1)",
        "Current or resistance in the bank 1 upstream O2 sensor heater circuit was out of range.",
        ["Blown O2 heater fuse", "Open heater element in sensor", "Harness or relay issue"],
        [
            "Check the O2 heater fuse and power supply first",
            "Measure heater element resistance per OEM specification",
        ],
    ),
    "P0141": entry(
        "P0141",
        "O2 sensor heater circuit (bank 1, sensor 2)",
        "The downstream oxygen sensor heater circuit on bank 1 reported abnormal current.",
        ["Downstream O2 sensor heater open circuit", "Blown fuse or damaged underbody wiring"],
        [
            "Inspect underbody wiring harness for road damage",
            "Verify heater power, ground and sensor resistance",
        ],
    ),
    "P0172": entry(
        "P0172",
        "System too rich (bank 1)",
        "Fuel control had to remove fuel beyond normal limits on bank 1.",
        [
            "Leaking fuel injector or high fuel pressure",
            "Contaminated MAF sensor",
            "EVAP purge stuck open",
        ],
        [
            "Review short-term and long-term fuel trims at idle vs. cruise",
            "Check EVAP purge valve operation and fuel pressure regulator",
        ],
    ),
    "P0174": entry(
        "P0174",
        "System too lean (bank 2)",
        "Fuel control reported a lean condition on bank 2.",
        ["Unmetered intake air leak", "Weak fuel delivery", "Bank 2 exhaust leak or sensor issue"],
        [
            "Compare bank 1 and bank 2 fuel trims to see if the issue affects both banks",
            "Perform an intake smoke test and fuel pressure test",
        ],
    ),
    "P0175": entry(
        "P0175",
        "System too rich (bank 2)",
        "Fuel control reported an overly rich air-fuel mixture on bank 2.",
        ["Fuel injector leakage on bank 2", "Air metering or upstream O2 sensor fault"],
        [
            "Compare bank 1 and bank 2 fuel trim values",
            "Check injector balance and upstream sensor response",
        ],
    ),
    "P0201": entry(
        "P0201",
        "Injector circuit/open - cylinder 1",
        "The controller detected an electrical fault in cylinder 1 fuel injector driver circuit.",
        ["Unplugged or damaged injector connector", "Open injector coil", "Wiring harness fault"],
        [
            "Check injector coil resistance and power supply with a multimeter",
            "Inspect harness routing for chafing",
        ],
    ),
    "P0217": entry(
        "P0217",
        "Engine coolant over temperature condition",
        "The controller detected dangerously high engine coolant temperature.",
        [
            "Low coolant or cooling leak",
            "Cooling fan or relay failure",
            "Stuck thermostat or water pump issue",
        ],
        [
            "Stop safely and let the engine cool completely before any inspection",
            "Never remove a radiator or expansion tank cap while hot",
        ],
    ),
    "P0299": entry(
        "P0299",
        "Turbocharger/supercharger A underboost condition",
        "Measured boost pressure remained below target commanded by the engine controller.",
        [
            "Charge air hose or intercooler leak",
            "Wastegate actuator or boost solenoid fault",
            "Turbo wear",
        ],
        [
            "Pressure-test charge pipes and intercooler connections for leaks",
            "Inspect wastegate linkage, vacuum lines and boost control solenoid",
        ],
    ),
    # --- Expanded Powertrain: Ignition & Misfire (P03xx) ---
    "P0302": entry(
        "P0302",
        "Cylinder 2 misfire detected",
        "The controller reported a misfire associated with cylinder 2.",
        ["Spark plug or ignition coil issue", "Fuel injector or compression issue"],
        [
            "Confirm cylinder 2 location in OEM service manual",
            "Test spark plug, ignition coil, injector and cylinder compression",
        ],
    ),
    "P0303": entry(
        "P0303",
        "Cylinder 3 misfire detected",
        "The controller reported a misfire associated with cylinder 3.",
        ["Spark plug or ignition coil issue", "Fuel injector or compression issue"],
        [
            "Confirm cylinder 3 location in OEM service manual",
            "Test spark plug, ignition coil, injector and cylinder compression",
        ],
    ),
    "P0304": entry(
        "P0304",
        "Cylinder 4 misfire detected",
        "The controller reported a misfire associated with cylinder 4.",
        ["Spark plug or ignition coil issue", "Fuel injector or compression issue"],
        [
            "Confirm cylinder 4 location in OEM service manual",
            "Test spark plug, ignition coil, injector and cylinder compression",
        ],
    ),
    "P0305": entry(
        "P0305",
        "Cylinder 5 misfire detected",
        "The controller reported a misfire associated with cylinder 5.",
        ["Spark plug or ignition coil issue", "Fuel injector or compression issue"],
        [
            "Confirm cylinder 5 location in OEM service manual",
            "Test spark plug, ignition coil, injector and cylinder compression",
        ],
    ),
    "P0306": entry(
        "P0306",
        "Cylinder 6 misfire detected",
        "The controller reported a misfire associated with cylinder 6.",
        ["Spark plug or ignition coil issue", "Fuel injector or compression issue"],
        [
            "Confirm cylinder 6 location in OEM service manual",
            "Test spark plug, ignition coil, injector and cylinder compression",
        ],
    ),
    "P0325": entry(
        "P0325",
        "Knock sensor 1 circuit (bank 1 or single sensor)",
        "The knock sensor signal remained outside expected voltage or frequency bounds.",
        ["Knock sensor wiring or connector corrosion", "Loose or over-torqued knock sensor"],
        [
            "Inspect knock sensor harness and connector",
            "Verify mounting torque and fuel octane requirements",
        ],
    ),
    "P0335": entry(
        "P0335",
        "Crankshaft position sensor A circuit",
        "The controller lost or received an invalid crankshaft position pulse signal.",
        ["Crankshaft sensor or connector fault", "Damaged reluctor ring or wiring"],
        [
            "Check RPM signal during cranking and inspect sensor air gap/wiring",
            "Test power, ground and signal waveform with an oscilloscope",
        ],
    ),
    "P0340": entry(
        "P0340",
        "Camshaft position sensor A circuit (bank 1 or single sensor)",
        "The camshaft position signal was missing or out of correlation during cranking.",
        ["Camshaft position sensor or wiring issue", "Timing chain/belt stretch or phaser fault"],
        [
            "Inspect camshaft sensor connector for oil intrusion or damage",
            "Check cam/crank synchronization with a diagnostic scope",
        ],
    ),
    "P0351": entry(
        "P0351",
        "Ignition coil A primary/secondary circuit",
        "The controller detected an electrical fault in ignition coil A trigger/feedback circuit.",
        ["Faulty ignition coil A", "Damaged coil connector or wiring harness"],
        [
            "Inspect coil A connector locking tab, pins and wiring",
            "Test primary power, ground and trigger pulse",
        ],
    ),
    # --- Expanded Powertrain: Emissions, Speed, Idle & Voltage (P04xx - P06xx) ---
    "P0401": entry(
        "P0401",
        "Exhaust gas recirculation A flow insufficient detected",
        "Measured manifold pressure or temperature change indicated restricted EGR flow.",
        ["Carbon buildup in EGR passages", "Stuck EGR valve or faulty control solenoid"],
        [
            "Inspect EGR passages and valve pintle for carbon blockage",
            "Test EGR command vs. manifold/flow sensor response",
        ],
    ),
    "P0404": entry(
        "P0404",
        "Exhaust gas recirculation A control circuit range/performance",
        "Actual EGR valve position did not match the position commanded by the controller.",
        ["Carbon sticking in EGR valve", "EGR position sensor or wiring fault"],
        [
            "Clean or inspect EGR valve pintle movement with engine off",
            "Verify EGR connector pins and position feedback signal",
        ],
    ),
    "P0430": entry(
        "P0430",
        "Catalyst system efficiency below threshold (bank 2)",
        "The bank 2 catalytic converter oxygen storage monitor reported reduced efficiency.",
        [
            "Bank 2 catalyst aging",
            "Exhaust leak near bank 2 sensors",
            "Upstream misfire or fuel issue",
        ],
        [
            "Fix any misfire or fuel trim codes on bank 2 before condemning the converter",
            "Check for exhaust leaks and verify downstream O2 sensor integrity",
        ],
    ),
    "P0440": entry(
        "P0440",
        "Evaporative emission system",
        "The EVAP system failed to hold vacuum or purge vapor as expected.",
        ["Loose or worn fuel filler cap", "Cracked EVAP vapor hose or faulty purge/vent valve"],
        [
            "Inspect the fuel cap seal with the engine off",
            "Have a technician perform a regulated EVAP smoke test",
        ],
    ),
    "P0446": entry(
        "P0446",
        "Evaporative emission system vent control circuit",
        "The EVAP canister vent valve circuit or airflow path reported a restriction or fault.",
        [
            "Blocked EVAP vent filter or spider web restriction",
            "Faulty vent solenoid or corroded wiring",
        ],
        [
            "Inspect the EVAP vent solenoid harness and filter near the charcoal canister",
            "Verify 12V supply and ground control to the vent valve",
        ],
    ),
    "P0456": entry(
        "P0456",
        "Evaporative emission system leak detected (very small leak)",
        "The EVAP monitor detected a pinhole-sized vapor leak (approx. 0.020 inch equivalent).",
        ["Slightly worn fuel cap o-ring", "Hairline crack in EVAP hose or purge valve seepage"],
        [
            "Clean and reseat the fuel cap o-ring with the engine off",
            "If the code returns, request an EVAP smoke test",
        ],
    ),
    "P0500": entry(
        "P0500",
        "Vehicle speed sensor A",
        "The powertrain controller lost or received an implausible vehicle speed signal.",
        ["Wheel speed/ABS signal fault", "Output shaft speed sensor or wiring issue"],
        [
            "Check whether the ABS warning light is also illuminated",
            "Compare live OBD vehicle speed with wheel speed sensor data",
        ],
    ),
    "P0505": entry(
        "P0505",
        "Idle air control system",
        "The engine controller could not regulate idle speed within the target RPM window.",
        [
            "Carbon deposits in throttle body or IAC valve",
            "Vacuum leak",
            "IAC actuator electrical fault",
        ],
        [
            "Inspect throttle bore and idle air passages for carbon buildup",
            "Check for intake vacuum leaks and perform idle relearn if required",
        ],
    ),
    "P0507": entry(
        "P0507",
        "Idle air control system RPM higher than expected",
        "Warm engine idle speed remained significantly above the programmed target RPM.",
        [
            "Unmetered vacuum leak after throttle plate",
            "Throttle body carbon or unlearned idle stop",
        ],
        [
            "Check PCV hoses, intake gaskets and brake booster line for vacuum leaks",
            "Perform throttle body idle relearn procedure after cleaning",
        ],
    ),
    "P0562": entry(
        "P0562",
        "System voltage low",
        "Battery/charging voltage supplied to the engine controller dropped below threshold.",
        [
            "Weak battery or corroded battery terminals",
            "Alternator charging fault",
            "High-resistance ground",
        ],
        [
            "Measure battery voltage at rest (~12.6V) and charging (~13.8-14.5V)",
            "Clean battery terminals and check main chassis/engine ground straps",
        ],
    ),
    "P0606": entry(
        "P0606",
        "ECM/PCM processor",
        "An internal self-check in the powertrain controller reported a power or processor fault.",
        [
            "Severe battery voltage drop or jump-start spike",
            "Poor ECM power/ground",
            "Internal module fault",
        ],
        [
            "Test battery health, alternator ripple and all ECM power/ground pins first",
            "Check OEM technical service bulletins for software updates before replacing modules",
        ],
    ),
    # --- Expanded Powertrain: Transmission & Hybrid/EV (P07xx / P0Axx) ---
    "P0700": entry(
        "P0700",
        "Transmission control system (MIL request)",
        "The transmission controller requested illumination of the check-engine light.",
        ["Specific transmission fault stored in TCM", "Valve body, solenoid or speed sensor issue"],
        [
            "Scan the transmission control module (TCM) for specific P07xx sub-codes",
            "Verify transmission fluid level and condition per OEM procedure",
        ],
    ),
    "P0715": entry(
        "P0715",
        "Input/turbine speed sensor A circuit",
        "The transmission controller detected an invalid or missing turbine shaft speed signal.",
        ["Input speed sensor fault", "Transmission harness or connector issue"],
        [
            "Inspect the external transmission wiring harness and connector",
            "Compare input RPM and output RPM in live transmission data",
        ],
    ),
    "P0741": entry(
        "P0741",
        "Torque converter clutch circuit performance/stuck off",
        "Measured slip across the torque converter clutch exceeded expected limits on lockup.",
        [
            "Low or degraded transmission fluid",
            "TCC solenoid or valve body wear",
            "Torque converter wear",
        ],
        [
            "Check transmission fluid level and condition first",
            "Have a transmission specialist monitor TCC slip RPM under steady cruise",
        ],
    ),
    "P0A80": entry(
        "P0A80",
        "Replace hybrid/EV battery pack",
        "The hybrid/EV battery module detected block voltage divergence beyond threshold.",
        [
            "Aging high-voltage battery module",
            "Corroded voltage sense busbars",
            "Blocked battery cooling fan",
        ],
        [
            "Check hybrid battery cooling fan and intake filter for blockage",
            "Never touch orange HV cables; have a certified HV technician inspect block voltages",
        ],
    ),
    # --- Body / SRS & Safety Systems (B0xxx) ---
    "B0001": entry(
        "B0001",
        "Driver frontal stage 1 deployment control",
        "The airbag module detected abnormal resistance in the driver airbag squib circuit.",
        ["Steering column clockspring wear", "Loose yellow SRS connector under seat/column"],
        [
            "Do not probe airbag circuits with a standard multimeter (risk of deployment)",
            "Have a qualified technician inspect the clockspring and SRS harness safely",
        ],
    ),
    "B0028": entry(
        "B0028",
        "Right side airbag deployment control",
        "The SRS module detected an open or short circuit in the passenger side airbag loop.",
        ["Under-seat SRS yellow connector movement", "Seat wiring harness chafing"],
        [
            "Have a technician inspect under-seat SRS connectors with the 12V battery isolated",
            "Never attempt DIY electrical testing on airbag igniter circuits",
        ],
    ),
    # --- Chassis / ABS & Stability Control (C0xxx) ---
    "C0031": entry(
        "C0031",
        "Left front wheel speed sensor",
        "The ABS/stability module reported an erratic or missing left-front wheel speed signal.",
        [
            "Dirty or damaged wheel speed sensor tip",
            "Broken sensor wire at steering knuckle",
            "Wheel bearing tone ring issue",
        ],
        [
            "Inspect the left-front wheel speed sensor wire and magnetic tone ring",
            "Compare all four wheel speeds at low speed on a scan tool",
        ],
    ),
    "C0034": entry(
        "C0034",
        "Right front wheel speed sensor",
        "The ABS/stability module reported an erratic or missing right-front wheel speed signal.",
        ["Right-front ABS sensor or harness damage", "Metallic debris on sensor or tone ring"],
        [
            "Inspect the right-front sensor harness routing along the strut and knuckle",
            "Verify wheel bearing play and tone ring cleanliness",
        ],
    ),
    "C0040": entry(
        "C0040",
        "Brake pedal switch A",
        "The ABS/chassis module detected implausible correlation from the brake pedal switch.",
        ["Misadjusted or worn brake light switch", "Blown stop-lamp fuse or corroded connector"],
        [
            "Verify whether the rear brake lights illuminate when pressing the pedal",
            "Inspect brake pedal switch adjustment and connector",
        ],
    ),
    # --- Network / CAN Bus Communication (U0xxx) ---
    "U0101": entry(
        "U0101",
        "Lost communication with TCM",
        "A module on the CAN bus stopped receiving scheduled frames from the transmission module.",
        ["Blown TCM fuse or power relay", "Loose ground strap", "CAN High/Low wiring fault"],
        [
            "Check TCM fuses and battery voltage before suspecting module failure",
            "Inspect CAN bus termination resistance (nominally 60 ohms with battery disconnected)",
        ],
    ),
    "U0121": entry(
        "U0121",
        "Lost communication with anti-lock brake system (ABS) control module",
        "The powertrain or gateway module lost CAN bus communication with the ABS controller.",
        ["ABS fuse or main power feed issue", "Corroded ABS module connector or ground"],
        [
            "Check ABS fuses in the engine bay fuse box and inspect chassis grounds",
            "Verify whether the ABS module responds directly to a diagnostic scan",
        ],
    ),
    "U0140": entry(
        "U0140",
        "Lost communication with body control module (BCM)",
        "A controller reported missing CAN messages from the body control module.",
        [
            "Low 12V battery voltage during cranking",
            "BCM fuse or water intrusion at interior fuse box",
        ],
        [
            "Test 12V battery state of charge and inspect interior fuse box for moisture",
            "Clear historical low-voltage network codes after charging/testing battery",
        ],
    ),
    "U0155": entry(
        "U0155",
        "Lost communication with instrument panel cluster (IPC) control module",
        "A module lost CAN communication with the gauge cluster.",
        ["Loose cluster connector or blown instrument fuse", "Low battery voltage event"],
        [
            "Check instrument cluster fuses and battery terminal tightness",
            "Verify whether gauges and warning lamps self-test at key-on",
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
