"""Smoke check a running API over HTTP: python scripts/smoke_api.py [base_url]."""

import json
import sys
import urllib.request
from typing import Any

base_url = (sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8000").rstrip("/")


def request(path: str, payload: dict[str, Any] | None = None) -> Any:
    req = urllib.request.Request(
        base_url + path,
        data=json.dumps(payload).encode() if payload is not None else None,
        headers={
            "Content-Type": "application/json",
            "User-Agent": "autosense-smoke/1.0",
        },
    )
    with urllib.request.urlopen(req, timeout=20) as response:
        return json.load(response)


assert request("/health")["status"] == "ok"
assert request("/v1/dtc/P0300")["found"] is True
assert request("/v1/dtc/P0420")["entry"]["code"] == "P0420"
assert request("/v1/dtc/P1234")["entry"] is None
manual = request(
    "/v1/diagnostics", {"codes": ["P0300"], "safety_check_completed": True}
)
assert manual["simulated"] is False and manual["urgency"] == "urgent"
mock = request(
    "/v1/diagnostics",
    {"codes": ["P0300"], "source": "mock_obd", "safety_flags": ["flashing_mil"]},
)
assert mock["simulated"] is True and mock["urgency"] == "stop_safely"
print(
    f"Live HTTP checks passed against {base_url}: health, lookups, manual and mock guidance."
)
