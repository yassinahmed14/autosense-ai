"""Rule engine and catalog behavior without HTTP."""

import json
import logging

from autosense_api.core.logging import JsonFormatter
from autosense_api.data.catalog import CATALOG, lookup
from autosense_api.schemas.diagnostics import DiagnosticRequest
from autosense_api.services.diagnostics import SAFETY_MESSAGE, diagnose


def test_catalog_keys_match_entries():
    assert len(CATALOG) == 56
    assert all(code == entry.code for code, entry in CATALOG.items())
    assert {"P0300", "P0420", "P0A80", "B0001", "C0031", "U0100", "U0101"}.issubset(CATALOG.keys())
    assert "P1234" not in CATALOG


def test_lookup_normalizes_and_does_not_invent():
    assert lookup(" p0420 ").found is True
    unknown = lookup("P1234")
    assert unknown.found is False
    assert unknown.entry is None


def test_overheating_puts_cooling_warning_first():
    result = diagnose(DiagnosticRequest(safety_flags=["overheating"], safety_check_completed=True))
    assert result.urgency == "stop_safely"
    assert result.next_steps[0] == "Do not open a hot cooling system."
    assert result.safety_message == SAFETY_MESSAGE


def test_adapter_limitation_only_for_hardware_sources():
    manual = diagnose(DiagnosticRequest(codes=["P0420"], safety_check_completed=True))
    ble = diagnose(
        DiagnosticRequest(codes=["P0420"], source="ble_obd", safety_check_completed=True)
    )
    assert len(ble.limitations) == len(manual.limitations) + 1


def test_json_formatter_emits_known_fields_only():
    record = logging.LogRecord("autosense_api", logging.INFO, __file__, 1, "request", None, None)
    record.request_id = "abc"
    record.status = 200
    payload = json.loads(JsonFormatter().format(record))
    assert payload["msg"] == "request"
    assert payload["request_id"] == "abc"
    assert payload["status"] == 200
    assert "method" not in payload
