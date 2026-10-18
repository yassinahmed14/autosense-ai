import 'package:autosense_ai/features/diagnostics/domain/diagnostic_model.dart';

/// Metadata for a built-in generic SAE J2012 DTC entry available offline.
class OfflineDtcRecord {
  const OfflineDtcRecord({
    required this.code,
    required this.title,
    required this.explanation,
    required this.causes,
    required this.checks,
  });

  final String code;
  final String title;
  final String explanation;
  final List<String> causes;
  final List<String> checks;

  /// Returns the SAE J2012 system prefix (`P`, `B`, `C`, or `U`).
  String get systemPrefix => code.isNotEmpty ? code[0] : 'P';

  /// Human-readable vehicle system category.
  String get systemLabel => switch (systemPrefix) {
        'P' => 'Powertrain',
        'C' => 'Chassis / ABS',
        'B' => 'Body / SRS',
        'U' => 'Network / CAN',
        _ => 'General',
      };
}

/// Instant on-device diagnostic engine (`rules-v1`) and 56-code generic
/// SAE J2012 catalog for zero-latency underground garage and offline use.
class OfflineDiagnosticEngine {
  const OfflineDiagnosticEngine._();

  static const String safetyMessage =
      'This is preliminary guidance, not a diagnosis or a determination that driving is safe. '
      'If overheating, oil-pressure warnings, braking/steering trouble, smoke, strong fuel smell, '
      'or a flashing check-engine light occurs, reach a safe stopping place and seek professional '
      "or roadside assistance. Follow your vehicle owner's manual.";

  static const String summaryText =
      'Preliminary possibilities based on supplied information; no failed part confirmed.';

  static const String adapterLimitation =
      'Experimental adapter input is client-supplied, not verified by the backend. '
      'Only stored engine/emissions codes were requested; no adapter compatibility '
      'or complete vehicle-health assessment is established.';

  static const Map<String, OfflineDtcRecord> catalog = {
    'P0300': OfflineDtcRecord(
      code: 'P0300',
      title: 'Random/multiple cylinder misfire detected',
      explanation:
          'The controller reported irregular combustion across multiple cylinders.',
      causes: [
        'Ignition system issue',
        'Fuel delivery issue',
        'Intake air leak or mechanical issue',
      ],
      checks: [
        'Ask a technician to review freeze-frame and misfire counters',
        'Have ignition, fuel delivery and compression tested before replacing parts',
      ],
    ),
    'P0301': OfflineDtcRecord(
      code: 'P0301',
      title: 'Cylinder 1 misfire detected',
      explanation:
          'The controller reported a misfire associated with cylinder 1.',
      causes: ['Ignition system issue', 'Injector or compression issue'],
      checks: [
        'Confirm cylinder numbering in OEM service information',
        'Have cylinder-specific ignition, injector and compression tests performed',
      ],
    ),
    'P0171': OfflineDtcRecord(
      code: 'P0171',
      title: 'System too lean (bank 1)',
      explanation:
          'Fuel control reported a lean condition on bank 1; this does not identify a failed part.',
      causes: [
        'Unmetered intake air',
        'Fuel delivery issue',
        'Air/fuel sensor measurement issue',
      ],
      checks: [
        'Have fuel trims reviewed under multiple operating conditions',
        'Ask for intake leak and fuel pressure checks',
      ],
    ),
    'P0420': OfflineDtcRecord(
      code: 'P0420',
      title: 'Catalyst system efficiency below threshold (bank 1)',
      explanation:
          'The controller reported catalyst monitor results outside its threshold.',
      causes: [
        'Catalyst deterioration',
        'Exhaust leak or sensor issue',
        'Upstream combustion issue',
      ],
      checks: [
        'Resolve related misfire/fuel codes first',
        'Have exhaust leaks and sensor behavior checked before catalyst replacement',
      ],
    ),
    'P0442': OfflineDtcRecord(
      code: 'P0442',
      title: 'Evaporative emission system leak detected (small leak)',
      explanation: 'The evaporative emissions monitor reported a small leak.',
      causes: ['Fuel cap seal issue', 'EVAP hose or valve leak'],
      checks: [
        "With the engine off, check the fuel cap is seated per the owner's manual",
        'Ask a technician for an approved EVAP leak test',
      ],
    ),
    'P0455': OfflineDtcRecord(
      code: 'P0455',
      title: 'Evaporative emission system leak detected (large leak)',
      explanation:
          'The evaporative emissions monitor reported a large leak or lack of flow.',
      causes: ['Missing or loose fuel cap', 'EVAP hose or valve issue'],
      checks: [
        'Check cap seating with the engine off',
        'Have the EVAP system inspected; fuel smell takes priority',
      ],
    ),
    'P0128': OfflineDtcRecord(
      code: 'P0128',
      title: 'Coolant temperature below thermostat regulating temperature',
      explanation:
          "Warm-up behavior did not meet the controller's expected temperature profile.",
      causes: [
        'Thermostat regulation issue',
        'Coolant level or temperature sensor issue',
      ],
      checks: [
        'Review coolant temperature data with a technician',
        'Never open a hot cooling system; follow OEM inspection instructions',
      ],
    ),
    'U0100': OfflineDtcRecord(
      code: 'U0100',
      title: 'Lost communication with ECM/PCM A',
      explanation:
          'A controller reported loss of communication with the engine/powertrain module.',
      causes: [
        'Power supply or wiring issue',
        'Network communication issue',
      ],
      checks: [
        'Have battery supply, grounds and network communication checked',
        'Do not assume the control module itself has failed',
      ],
    ),
    'P0101': OfflineDtcRecord(
      code: 'P0101',
      title: 'Mass or volume air flow A circuit range/performance',
      explanation:
          'Measured mass air flow differed from the expected range for current engine load and RPM.',
      causes: [
        'Intake duct leak or restriction',
        'Contaminated or faulty MAF sensor',
        'Wiring issue',
      ],
      checks: [
        'Inspect air filter housing and intake boot for leaks or debris',
        'Compare live MAF grams/sec readings at idle and under load',
      ],
    ),
    'P0102': OfflineDtcRecord(
      code: 'P0102',
      title: 'Mass or volume air flow A circuit low input',
      explanation:
          'The controller detected an abnormally low signal from the mass air flow sensor circuit.',
      causes: [
        'Unplugged or open MAF harness',
        'MAF sensor supply voltage issue',
        'Sensor fault',
      ],
      checks: [
        'Verify MAF connector seating and reference voltage with a multimeter',
        'Inspect intake tract and sensor element',
      ],
    ),
    'P0106': OfflineDtcRecord(
      code: 'P0106',
      title:
          'Manifold absolute pressure/barometric pressure circuit range/performance',
      explanation:
          'MAP sensor signal did not correlate with throttle angle or barometric reference.',
      causes: [
        'Vacuum hose leak or blockage',
        'MAP sensor or connector fault',
        'Exhaust restriction',
      ],
      checks: [
        'Compare key-on engine-off MAP reading with local barometric pressure',
        'Inspect vacuum port and wiring harness',
      ],
    ),
    'P0113': OfflineDtcRecord(
      code: 'P0113',
      title: 'Intake air temperature sensor 1 circuit high (bank 1)',
      explanation:
          'The IAT sensor circuit reported a high voltage (typically indicating an open circuit).',
      causes: [
        'Disconnected IAT sensor plug',
        'Open wire in IAT harness',
        'Faulty IAT sensor',
      ],
      checks: [
        'Check live intake air temperature reading with key on',
        'Inspect the IAT/MAF connector pins and wiring',
      ],
    ),
    'P0118': OfflineDtcRecord(
      code: 'P0118',
      title: 'Engine coolant temperature sensor 1 circuit high',
      explanation:
          'The ECT sensor circuit reported a high voltage (often an open circuit or cold reading).',
      causes: [
        'Open ECT sensor circuit or unplugged connector',
        'Faulty coolant temperature sensor',
      ],
      checks: [
        'Compare cold key-on ECT reading with ambient temperature',
        'Never open a hot cooling system; inspect sensor wiring safely',
      ],
    ),
    'P0122': OfflineDtcRecord(
      code: 'P0122',
      title: 'Throttle/pedal position sensor/switch A circuit low',
      explanation:
          'Throttle position sensor A reported voltage below the minimum calibrated threshold.',
      causes: [
        'TPS signal or 5V reference wiring fault',
        'Throttle body sensor issue',
      ],
      checks: [
        'Review live throttle position percentage with ignition on and engine off',
        'Have throttle body connector and 5V reference inspected',
      ],
    ),
    'P0130': OfflineDtcRecord(
      code: 'P0130',
      title: 'O2 sensor circuit (bank 1, sensor 1)',
      explanation:
          'The upstream oxygen or air-fuel ratio sensor signal on bank 1 was out of expected range.',
      causes: [
        'Exhaust leak upstream of sensor',
        'O2 sensor wiring or element issue',
        'Fuel trim fault',
      ],
      checks: [
        'Inspect sensor wiring near hot exhaust manifolds',
        'Have live upstream O2 sensor switching or current waveform tested',
      ],
    ),
    'P0135': OfflineDtcRecord(
      code: 'P0135',
      title: 'O2 sensor heater circuit (bank 1, sensor 1)',
      explanation:
          'Current or resistance in the bank 1 upstream O2 sensor heater circuit was out of range.',
      causes: [
        'Blown O2 heater fuse',
        'Open heater element in sensor',
        'Harness or relay issue',
      ],
      checks: [
        'Check the O2 heater fuse and power supply first',
        'Measure heater element resistance per OEM specification',
      ],
    ),
    'P0141': OfflineDtcRecord(
      code: 'P0141',
      title: 'O2 sensor heater circuit (bank 1, sensor 2)',
      explanation:
          'The downstream oxygen sensor heater circuit on bank 1 reported abnormal current or voltage.',
      causes: [
        'Downstream O2 sensor heater open circuit',
        'Blown fuse or damaged underbody wiring',
      ],
      checks: [
        'Inspect underbody wiring harness for road damage',
        'Verify heater power, ground and sensor resistance',
      ],
    ),
    'P0172': OfflineDtcRecord(
      code: 'P0172',
      title: 'System too rich (bank 1)',
      explanation:
          'Fuel control had to remove fuel beyond normal limits on bank 1.',
      causes: [
        'Leaking fuel injector or high fuel pressure',
        'Contaminated MAF sensor',
        'EVAP purge stuck open',
      ],
      checks: [
        'Review short-term and long-term fuel trims at idle vs. cruise',
        'Check EVAP purge valve operation and fuel pressure regulator',
      ],
    ),
    'P0174': OfflineDtcRecord(
      code: 'P0174',
      title: 'System too lean (bank 2)',
      explanation: 'Fuel control reported a lean condition on bank 2.',
      causes: [
        'Unmetered intake air leak',
        'Weak fuel delivery',
        'Bank 2 exhaust leak or sensor issue',
      ],
      checks: [
        'Compare bank 1 and bank 2 fuel trims to see if the issue affects both banks',
        'Perform an intake smoke test and fuel pressure test',
      ],
    ),
    'P0175': OfflineDtcRecord(
      code: 'P0175',
      title: 'System too rich (bank 2)',
      explanation:
          'Fuel control reported an overly rich air-fuel mixture on bank 2.',
      causes: [
        'Fuel injector leakage on bank 2',
        'Air metering or upstream O2 sensor fault',
      ],
      checks: [
        'Compare bank 1 and bank 2 fuel trim values',
        'Check injector balance and upstream sensor response',
      ],
    ),
    'P0201': OfflineDtcRecord(
      code: 'P0201',
      title: 'Injector circuit/open - cylinder 1',
      explanation:
          'The controller detected an electrical fault in the cylinder 1 fuel injector driver circuit.',
      causes: [
        'Unplugged or damaged injector connector',
        'Open injector coil',
        'Wiring harness fault',
      ],
      checks: [
        'Check injector coil resistance and power supply with a multimeter',
        'Inspect harness routing for chafing',
      ],
    ),
    'P0217': OfflineDtcRecord(
      code: 'P0217',
      title: 'Engine coolant over temperature condition',
      explanation:
          'The controller detected dangerously high engine coolant temperature.',
      causes: [
        'Low coolant or cooling leak',
        'Cooling fan or relay failure',
        'Stuck thermostat or water pump issue',
      ],
      checks: [
        'Stop safely and let the engine cool completely before any inspection',
        'Never remove a radiator or expansion tank cap while hot',
      ],
    ),
    'P0299': OfflineDtcRecord(
      code: 'P0299',
      title: 'Turbocharger/supercharger A underboost condition',
      explanation:
          'Measured boost pressure remained below the target commanded by the engine controller.',
      causes: [
        'Charge air hose or intercooler leak',
        'Wastegate actuator or boost solenoid fault',
        'Turbo wear',
      ],
      checks: [
        'Pressure-test charge pipes and intercooler connections for leaks',
        'Inspect wastegate linkage, vacuum lines and boost control solenoid',
      ],
    ),
    'P0302': OfflineDtcRecord(
      code: 'P0302',
      title: 'Cylinder 2 misfire detected',
      explanation:
          'The controller reported a misfire associated with cylinder 2.',
      causes: [
        'Spark plug or ignition coil issue',
        'Fuel injector or compression issue',
      ],
      checks: [
        'Confirm cylinder 2 location in OEM service manual',
        'Test spark plug, ignition coil, injector and cylinder compression',
      ],
    ),
    'P0303': OfflineDtcRecord(
      code: 'P0303',
      title: 'Cylinder 3 misfire detected',
      explanation:
          'The controller reported a misfire associated with cylinder 3.',
      causes: [
        'Spark plug or ignition coil issue',
        'Fuel injector or compression issue',
      ],
      checks: [
        'Confirm cylinder 3 location in OEM service manual',
        'Test spark plug, ignition coil, injector and cylinder compression',
      ],
    ),
    'P0304': OfflineDtcRecord(
      code: 'P0304',
      title: 'Cylinder 4 misfire detected',
      explanation:
          'The controller reported a misfire associated with cylinder 4.',
      causes: [
        'Spark plug or ignition coil issue',
        'Fuel injector or compression issue',
      ],
      checks: [
        'Confirm cylinder 4 location in OEM service manual',
        'Test spark plug, ignition coil, injector and cylinder compression',
      ],
    ),
    'P0305': OfflineDtcRecord(
      code: 'P0305',
      title: 'Cylinder 5 misfire detected',
      explanation:
          'The controller reported a misfire associated with cylinder 5.',
      causes: [
        'Spark plug or ignition coil issue',
        'Fuel injector or compression issue',
      ],
      checks: [
        'Confirm cylinder 5 location in OEM service manual',
        'Test spark plug, ignition coil, injector and cylinder compression',
      ],
    ),
    'P0306': OfflineDtcRecord(
      code: 'P0306',
      title: 'Cylinder 6 misfire detected',
      explanation:
          'The controller reported a misfire associated with cylinder 6.',
      causes: [
        'Spark plug or ignition coil issue',
        'Fuel injector or compression issue',
      ],
      checks: [
        'Confirm cylinder 6 location in OEM service manual',
        'Test spark plug, ignition coil, injector and cylinder compression',
      ],
    ),
    'P0325': OfflineDtcRecord(
      code: 'P0325',
      title: 'Knock sensor 1 circuit (bank 1 or single sensor)',
      explanation:
          'The knock sensor signal remained outside expected voltage or frequency bounds.',
      causes: [
        'Knock sensor wiring or connector corrosion',
        'Loose or over-torqued knock sensor',
      ],
      checks: [
        'Inspect knock sensor harness and connector',
        'Verify mounting torque and fuel octane requirements',
      ],
    ),
    'P0335': OfflineDtcRecord(
      code: 'P0335',
      title: 'Crankshaft position sensor A circuit',
      explanation:
          'The controller lost or received an invalid crankshaft position pulse signal.',
      causes: [
        'Crankshaft sensor or connector fault',
        'Damaged reluctor ring or wiring',
      ],
      checks: [
        'Check RPM signal during cranking and inspect sensor air gap/wiring',
        'Test power, ground and signal waveform with an oscilloscope',
      ],
    ),
    'P0340': OfflineDtcRecord(
      code: 'P0340',
      title: 'Camshaft position sensor A circuit (bank 1 or single sensor)',
      explanation:
          'The camshaft position signal was missing or out of correlation during cranking/running.',
      causes: [
        'Camshaft position sensor or wiring issue',
        'Timing chain/belt stretch or phaser fault',
      ],
      checks: [
        'Inspect camshaft sensor connector for oil intrusion or damage',
        'Check cam/crank synchronization with a diagnostic scope',
      ],
    ),
    'P0351': OfflineDtcRecord(
      code: 'P0351',
      title: 'Ignition coil A primary/secondary circuit',
      explanation:
          'The controller detected an electrical fault in the ignition coil A trigger or feedback circuit.',
      causes: [
        'Faulty ignition coil A',
        'Damaged coil connector or wiring harness',
      ],
      checks: [
        'Inspect coil A connector locking tab, pins and wiring',
        'Test primary power, ground and trigger pulse',
      ],
    ),
    'P0401': OfflineDtcRecord(
      code: 'P0401',
      title: 'Exhaust gas recirculation A flow insufficient detected',
      explanation:
          'Measured manifold pressure or temperature change indicated restricted EGR flow.',
      causes: [
        'Carbon buildup in EGR passages',
        'Stuck EGR valve or faulty control solenoid',
      ],
      checks: [
        'Inspect EGR passages and valve pintle for carbon blockage',
        'Test EGR command vs. manifold/flow sensor response',
      ],
    ),
    'P0404': OfflineDtcRecord(
      code: 'P0404',
      title: 'Exhaust gas recirculation A control circuit range/performance',
      explanation:
          'Actual EGR valve position did not match the position commanded by the controller.',
      causes: [
        'Carbon sticking in EGR valve',
        'EGR position sensor or wiring fault',
      ],
      checks: [
        'Clean or inspect EGR valve pintle movement with engine off',
        'Verify EGR connector pins and position feedback signal',
      ],
    ),
    'P0430': OfflineDtcRecord(
      code: 'P0430',
      title: 'Catalyst system efficiency below threshold (bank 2)',
      explanation:
          'The bank 2 catalytic converter oxygen storage monitor reported reduced efficiency.',
      causes: [
        'Bank 2 catalyst aging',
        'Exhaust leak near bank 2 sensors',
        'Upstream misfire or fuel issue',
      ],
      checks: [
        'Fix any misfire or fuel trim codes on bank 2 before condemning the converter',
        'Check for exhaust leaks and verify downstream O2 sensor integrity',
      ],
    ),
    'P0440': OfflineDtcRecord(
      code: 'P0440',
      title: 'Evaporative emission system',
      explanation:
          'The EVAP system failed to hold vacuum or purge vapor as expected.',
      causes: [
        'Loose or worn fuel filler cap',
        'Cracked EVAP vapor hose or faulty purge/vent valve',
      ],
      checks: [
        'Inspect the fuel cap seal with the engine off',
        'Have a technician perform a regulated EVAP smoke test',
      ],
    ),
    'P0446': OfflineDtcRecord(
      code: 'P0446',
      title: 'Evaporative emission system vent control circuit',
      explanation:
          'The EVAP canister vent valve circuit or airflow path reported a restriction or electrical fault.',
      causes: [
        'Blocked EVAP vent filter or spider web restriction',
        'Faulty vent solenoid or corroded wiring',
      ],
      checks: [
        'Inspect the EVAP vent solenoid harness and filter near the charcoal canister',
        'Verify 12V supply and ground control to the vent valve',
      ],
    ),
    'P0456': OfflineDtcRecord(
      code: 'P0456',
      title: 'Evaporative emission system leak detected (very small leak)',
      explanation:
          'The EVAP monitor detected a pinhole-sized vapor leak (approx. 0.020 inch equivalent).',
      causes: [
        'Slightly worn fuel cap o-ring',
        'Hairline crack in EVAP hose or purge valve seepage',
      ],
      checks: [
        'Clean and reseat the fuel cap o-ring with the engine off',
        'If the code returns, request an EVAP smoke test',
      ],
    ),
    'P0500': OfflineDtcRecord(
      code: 'P0500',
      title: 'Vehicle speed sensor A',
      explanation:
          'The powertrain controller lost or received an implausible vehicle speed signal.',
      causes: [
        'Wheel speed/ABS signal fault',
        'Output shaft speed sensor or wiring issue',
      ],
      checks: [
        'Check whether the ABS warning light is also illuminated',
        'Compare live OBD vehicle speed with wheel speed sensor data',
      ],
    ),
    'P0505': OfflineDtcRecord(
      code: 'P0505',
      title: 'Idle air control system',
      explanation:
          'The engine controller could not regulate idle speed within the target RPM window.',
      causes: [
        'Carbon deposits in throttle body or IAC valve',
        'Vacuum leak',
        'IAC actuator electrical fault',
      ],
      checks: [
        'Inspect throttle bore and idle air passages for carbon buildup',
        'Check for intake vacuum leaks and perform idle relearn if required',
      ],
    ),
    'P0507': OfflineDtcRecord(
      code: 'P0507',
      title: 'Idle air control system RPM higher than expected',
      explanation:
          'Warm engine idle speed remained significantly above the programmed target RPM.',
      causes: [
        'Unmetered vacuum leak after throttle plate',
        'Throttle body carbon or unlearned idle stop',
      ],
      checks: [
        'Check PCV hoses, intake gaskets and brake booster line for vacuum leaks',
        'Perform throttle body idle relearn procedure after cleaning',
      ],
    ),
    'P0562': OfflineDtcRecord(
      code: 'P0562',
      title: 'System voltage low',
      explanation:
          'Battery/charging voltage supplied to the engine controller dropped below threshold.',
      causes: [
        'Weak battery or corroded battery terminals',
        'Alternator charging fault',
        'High-resistance ground',
      ],
      checks: [
        'Measure battery voltage at rest (~12.6V) and charging (~13.8-14.5V)',
        'Clean battery terminals and check main chassis/engine ground straps',
      ],
    ),
    'P0606': OfflineDtcRecord(
      code: 'P0606',
      title: 'ECM/PCM processor',
      explanation:
          'An internal self-check in the powertrain controller reported a processor or power-supply anomaly.',
      causes: [
        'Severe battery voltage drop or jump-start spike',
        'Poor ECM power/ground',
        'Internal module fault',
      ],
      checks: [
        'Test battery health, alternator ripple and all ECM power/ground pins first',
        'Check OEM technical service bulletins for software updates before replacing modules',
      ],
    ),
    'P0700': OfflineDtcRecord(
      code: 'P0700',
      title: 'Transmission control system (MIL request)',
      explanation:
          'The transmission controller requested illumination of the check-engine light.',
      causes: [
        'Specific transmission fault stored in TCM',
        'Valve body, solenoid or speed sensor issue',
      ],
      checks: [
        'Scan the transmission control module (TCM) for specific P07xx sub-codes',
        'Verify transmission fluid level and condition per OEM procedure',
      ],
    ),
    'P0715': OfflineDtcRecord(
      code: 'P0715',
      title: 'Input/turbine speed sensor A circuit',
      explanation:
          'The transmission controller detected an invalid or missing turbine shaft speed signal.',
      causes: [
        'Input speed sensor fault',
        'Transmission harness or connector issue',
      ],
      checks: [
        'Inspect the external transmission wiring harness and connector',
        'Compare input RPM and output RPM in live transmission data',
      ],
    ),
    'P0741': OfflineDtcRecord(
      code: 'P0741',
      title: 'Torque converter clutch circuit performance/stuck off',
      explanation:
          'Measured slip across the torque converter clutch exceeded expected limits when lockup was commanded.',
      causes: [
        'Low or degraded transmission fluid',
        'TCC solenoid or valve body wear',
        'Torque converter wear',
      ],
      checks: [
        'Check transmission fluid level and condition first',
        'Have a transmission specialist monitor TCC slip RPM under steady cruise',
      ],
    ),
    'P0A80': OfflineDtcRecord(
      code: 'P0A80',
      title: 'Replace hybrid/EV battery pack',
      explanation:
          'The hybrid/EV battery management module detected block voltage divergence beyond threshold.',
      causes: [
        'Aging high-voltage battery module',
        'Corroded voltage sense busbars',
        'Blocked battery cooling fan',
      ],
      checks: [
        'Check hybrid battery cooling fan and intake filter for blockage',
        'Never touch orange high-voltage cables; have a certified HV technician inspect block voltages',
      ],
    ),
    'B0001': OfflineDtcRecord(
      code: 'B0001',
      title: 'Driver frontal stage 1 deployment control',
      explanation:
          'The supplemental restraint (airbag) module detected high or low resistance in the driver airbag squib circuit.',
      causes: [
        'Steering column clockspring wear',
        'Loose yellow SRS connector under seat/column',
      ],
      checks: [
        'Do not probe airbag circuits with a standard multimeter (risk of deployment)',
        'Have a qualified technician inspect the clockspring and SRS harness with battery disconnected',
      ],
    ),
    'B0028': OfflineDtcRecord(
      code: 'B0028',
      title: 'Right side airbag deployment control',
      explanation:
          'The SRS module detected an open or short circuit in the passenger side-impact airbag loop.',
      causes: [
        'Under-seat SRS yellow connector movement',
        'Seat wiring harness chafing',
      ],
      checks: [
        'Have a technician inspect under-seat SRS connectors with the 12V battery isolated',
        'Never attempt DIY electrical testing on airbag igniter circuits',
      ],
    ),
    'C0031': OfflineDtcRecord(
      code: 'C0031',
      title: 'Left front wheel speed sensor',
      explanation:
          'The ABS/stability module reported an erratic or missing left-front wheel speed signal.',
      causes: [
        'Dirty or damaged wheel speed sensor tip',
        'Broken sensor wire at steering knuckle',
        'Wheel bearing tone ring issue',
      ],
      checks: [
        'Inspect the left-front wheel speed sensor wire and magnetic tone ring',
        'Compare all four wheel speeds at low speed on a scan tool',
      ],
    ),
    'C0034': OfflineDtcRecord(
      code: 'C0034',
      title: 'Right front wheel speed sensor',
      explanation:
          'The ABS/stability module reported an erratic or missing right-front wheel speed signal.',
      causes: [
        'Right-front ABS sensor or harness damage',
        'Metallic debris on sensor or tone ring',
      ],
      checks: [
        'Inspect the right-front sensor harness routing along the strut and knuckle',
        'Verify wheel bearing play and tone ring cleanliness',
      ],
    ),
    'C0040': OfflineDtcRecord(
      code: 'C0040',
      title: 'Brake pedal switch A',
      explanation:
          'The ABS/chassis module detected implausible correlation from the brake pedal switch.',
      causes: [
        'Misadjusted or worn brake light switch',
        'Blown stop-lamp fuse or corroded connector',
      ],
      checks: [
        'Verify whether the rear brake lights illuminate when pressing the pedal',
        'Inspect brake pedal switch adjustment and connector',
      ],
    ),
    'U0101': OfflineDtcRecord(
      code: 'U0101',
      title: 'Lost communication with TCM',
      explanation:
          'A module on the CAN bus stopped receiving scheduled frames from the transmission control module.',
      causes: [
        'Blown TCM fuse or power relay',
        'Loose ground strap',
        'CAN High/Low wiring fault',
      ],
      checks: [
        'Check TCM fuses and battery voltage before suspecting module failure',
        'Inspect CAN bus termination resistance (nominally 60 ohms with battery disconnected)',
      ],
    ),
    'U0121': OfflineDtcRecord(
      code: 'U0121',
      title:
          'Lost communication with anti-lock brake system (ABS) control module',
      explanation:
          'The powertrain or gateway module lost CAN bus communication with the ABS controller.',
      causes: [
        'ABS fuse or main power feed issue',
        'Corroded ABS module connector or ground',
      ],
      checks: [
        'Check ABS fuses in the engine bay fuse box and inspect chassis grounds',
        'Verify whether the ABS module responds directly to a diagnostic scan',
      ],
    ),
    'U0140': OfflineDtcRecord(
      code: 'U0140',
      title: 'Lost communication with body control module (BCM)',
      explanation:
          'A controller reported missing CAN messages from the body control module.',
      causes: [
        'Low 12V battery voltage during cranking',
        'BCM fuse or water intrusion at interior fuse box',
      ],
      checks: [
        'Test 12V battery state of charge and inspect interior fuse box for moisture',
        'Clear historical low-voltage network codes after charging/testing battery',
      ],
    ),
    'U0155': OfflineDtcRecord(
      code: 'U0155',
      title:
          'Lost communication with instrument panel cluster (IPC) control module',
      explanation: 'A module lost CAN communication with the gauge cluster.',
      causes: [
        'Loose cluster connector or blown instrument fuse',
        'Low battery voltage event',
      ],
      checks: [
        'Check instrument cluster fuses and battery terminal tightness',
        'Verify whether gauges and warning lamps self-test at key-on',
      ],
    ),
  };

  /// Filters the built-in 56-code catalog by system prefix (`ALL`, `P`, `C`, `B`, `U`)
  /// and optional case-insensitive search query (matches code, title, or explanation).
  static List<OfflineDtcRecord> filterCatalog({
    String query = '',
    String system = 'ALL',
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return catalog.values.where((record) {
      if (system != 'ALL' && record.systemPrefix != system) return false;
      if (normalizedQuery.isEmpty) return true;
      return record.code.toLowerCase().contains(normalizedQuery) ||
          record.title.toLowerCase().contains(normalizedQuery) ||
          record.explanation.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  /// Looks up a single DTC code on-device in <1ms.
  static DtcLookup lookup(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    final record = catalog[code];
    return DtcLookup.fromJson({
      'code': code,
      'found': record != null,
      'entry': record == null
          ? null
          : {
              'code': record.code,
              'title': record.title,
              'explanation': record.explanation,
            },
      'message': record != null
          ? 'Generic demo definition; verify against OEM service information.'
          : 'Not in the starter catalog. Obtain the vehicle-specific definition.',
    });
  }

  /// Runs the deterministic `rules-v1` diagnostic engine on-device when offline.
  static DiagnosticResult diagnose(DiagnosticInput input) {
    final normalizedCodes = parseCodes(input.codes.join(', '));
    final dtcs = normalizedCodes.map(lookup).toList();
    final causes = <String, List<String>>{};
    final checks = <String>[];

    for (final code in normalizedCodes) {
      final record = catalog[code];
      if (record != null) {
        for (final cause in record.causes) {
          causes.putIfAbsent(cause, () => <String>[]).add(code);
        }
        checks.addAll(record.checks);
      }
    }

    const symptomHypotheses = <String, List<String>>{
      'rough_idle': ['Ignition system issue', 'Unmetered intake air'],
      'hard_start': ['Starting electrical or fuel supply issue'],
      'reduced_power': ['Air/fuel control or drivetrain issue'],
      'poor_fuel_economy': ['Operating conditions or fuel control issue'],
      'unusual_noise': ['Mechanical or accessory issue requiring inspection'],
    };

    for (final symptom in input.symptoms) {
      final list = symptomHypotheses[symptom];
      if (list != null) {
        for (final cause in list) {
          causes
              .putIfAbsent(cause, () => <String>[])
              .add('Reported symptom: $symptom');
        }
      }
    }

    late final String urgency;
    late final List<String> reasons;
    if (input.safetyFlags.isNotEmpty) {
      urgency = 'stop_safely';
      reasons = [
        for (final flag in input.safetyFlags) 'Reported safety concern: $flag',
      ];
    } else if (!input.safetyCheckCompleted || input.notes.trim().isNotEmpty) {
      urgency = 'unassessed';
      reasons = [
        'Safety checklist missing or free-text notes require human review.',
      ];
    } else if (normalizedCodes.any((code) => code.startsWith('P030'))) {
      urgency = 'urgent';
      reasons = [
        'A reported misfire code warrants prompt professional review.',
      ];
    } else {
      urgency = 'inspection';
      reasons = [
        'Arrange inspection; the inputs cannot establish whether driving is safe.',
      ];
    }

    if (urgency == 'stop_safely') {
      checks.insert(
        0,
        'Reach a safe stopping place and contact professional or roadside assistance.',
      );
    }
    if (input.safetyFlags.contains('overheating')) {
      checks.insert(0, 'Do not open a hot cooling system.');
    }
    if (input.notes.trim().isNotEmpty) {
      checks.insert(
        0,
        'Show your notes to a technician; this starter does not interpret free text.',
      );
    }
    if (!input.safetyCheckCompleted) {
      checks.insert(
        0,
        'Complete the safety checklist before relying on the guidance.',
      );
    }
    if (dtcs.any((item) => !item.found)) {
      checks
          .add('Ask for OEM definitions for codes missing from this catalog.');
    }
    checks.addAll([
      'Record when the issue occurs and preserve codes/freeze-frame data.',
      'Have a qualified technician confirm the cause before replacing parts.',
    ]);

    final dedupedChecks = checks.toSet().toList();
    final limitations = <String>[
      'Rule-based demo: no AI model, probabilities, or validated diagnostic accuracy.',
      'On-device offline fallback used: 56 generic SAE J2012 code definitions; manufacturer-specific coverage is not included.',
      'Vehicle details are context only; rules are not tailored to make/model/year.',
      'No live vehicle measurements were analyzed. Free text requires human review.',
      'No codes does not mean no fault. Mock scans contain simulated evidence.',
      if (input.source == 'ble_obd' || input.source == 'wifi_obd')
        adapterLimitation,
    ];

    return DiagnosticResult.fromJson({
      'id': 'offline-${DateTime.now().toUtc().microsecondsSinceEpoch}',
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'source': input.source,
      'simulated': input.source == 'mock_obd',
      'summary': summaryText,
      'urgency': urgency,
      'urgency_reasons': reasons,
      'dtcs': [
        for (final item in dtcs)
          {
            'code': item.code,
            'found': item.found,
            'entry': item.title == null
                ? null
                : {
                    'code': item.code,
                    'title': item.title,
                    'explanation': item.explanation,
                  },
            'message': item.message,
          },
      ],
      'possible_causes': [
        for (final entry in causes.entries)
          {
            'title': entry.key,
            'certainty': 'unconfirmed',
            'evidence': entry.value,
          },
      ],
      'next_steps': dedupedChecks,
      'limitations': limitations,
      'safety_message': safetyMessage,
    });
  }
}
