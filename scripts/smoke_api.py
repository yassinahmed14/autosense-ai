"""Smoke check a running local API: python scripts/smoke_api.py [base_url]."""
import json
import sys
import urllib.request

base_url = (sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8000").rstrip("/")


def request(path, payload=None):
    req = urllib.request.Request(base_url + path,
        data=json.dumps(payload).encode() if payload is not None else None,
        headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=10) as response:
        return json.load(response)


assert request("/health")["status"] == "ok"
assert request("/v1/dtc/P0300")["found"] is True
assert request("/v1/dtc/P1234")["entry"] is None
manual = request("/v1/diagnostics", {"codes": ["P0300"], "safety_check_completed": True})
assert manual["simulated"] is False and manual["urgency"] == "urgent"
mock = request("/v1/diagnostics", {"codes": ["P0300"], "source": "mock_obd",
                                   "safety_flags": ["flashing_mil"]})
assert mock["simulated"] is True and mock["urgency"] == "stop_safely"
print("Live HTTP checks passed: health, known/unknown lookup, manual and mock guidance.")
