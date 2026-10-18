"""Tiny adb UI driver for manual-style QA on an emulator or phone.

Usage (after `. .\\scripts\\dev_env.ps1`):
  python adb_ui.py install <apk>          install/replace the APK
  python adb_ui.py launch                 start the app fresh
  python adb_ui.py shot <name>            save screenshot to qa-shots/<name>.png
  python adb_ui.py texts                  list visible texts / content-descs
  python adb_ui.py tap "<text>"           tap element whose text/desc contains <text>
  python adb_ui.py scrolltap "<text>"     scroll down until found, then tap
  python adb_ui.py type "<text>"          type into the focused field
  python adb_ui.py back | scroll | scrollup
  python adb_ui.py crashes                print FATAL/AndroidRuntime errors from logcat
Set ADB_SERIAL to target a specific device (default: first device).
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET
from pathlib import Path

PACKAGE = os.environ.get("APP_PACKAGE", "com.autosense.autosense_ai")
SHOTS = Path(os.environ.get("QA_SHOTS", "qa-shots"))


def adb(*args: str, binary: bool = False) -> bytes | str:
    cmd = ["adb"]
    if os.environ.get("ADB_SERIAL"):
        cmd += ["-s", os.environ["ADB_SERIAL"]]
    out = subprocess.run(cmd + list(args), capture_output=True, check=False)
    return out.stdout if binary else out.stdout.decode("utf-8", "replace")


def nodes() -> list[dict[str, str]]:
    adb("shell", "uiautomator", "dump", "/sdcard/ui.xml")
    xml = adb("shell", "cat", "/sdcard/ui.xml")
    xml = xml[xml.find("<?xml") :] if "<?xml" in xml else xml
    try:
        root = ET.fromstring(xml)
    except ET.ParseError:
        return []
    return [n.attrib for n in root.iter("node")]


def label(n: dict[str, str]) -> str:
    return (n.get("text") or n.get("content-desc") or "").strip()


def center(bounds: str) -> tuple[int, int]:
    x1, y1, x2, y2 = map(int, re.findall(r"\d+", bounds))
    return (x1 + x2) // 2, (y1 + y2) // 2


def find(text: str) -> dict[str, str] | None:
    want = text.lower()
    matches = [n for n in nodes() if want in label(n).lower()]
    exact = [n for n in matches if label(n).lower() == want]
    return (exact or matches or [None])[0]


def tap(text: str) -> bool:
    n = find(text)
    if not n:
        print(f"NOT FOUND: {text}")
        return False
    x, y = center(n["bounds"])
    adb("shell", "input", "tap", str(x), str(y))
    time.sleep(1.2)
    print(f"tapped '{label(n)[:60]}' at {x},{y}")
    return True


def screen_size() -> tuple[int, int]:
    out = str(adb("shell", "wm", "size"))
    m = re.search(r"(\d+)x(\d+)", out)
    return (int(m.group(1)), int(m.group(2))) if m else (1080, 1920)


def scroll(up: bool = False) -> None:
    w, h = screen_size()
    cx = str(w // 2)
    y_high, y_low = str(int(h * 0.75)), str(int(h * 0.25))
    a, b = (y_low, y_high) if up else (y_high, y_low)
    adb("shell", "input", "swipe", cx, a, cx, b, "350")
    time.sleep(0.8)


def main(argv: list[str]) -> int:
    if not argv:
        print(__doc__)
        return 1
    cmd, rest = argv[0], argv[1:]
    if cmd == "install":
        print(adb("install", "-r", "-g", rest[0]))
    elif cmd == "launch":
        adb("shell", "am", "force-stop", PACKAGE)
        adb("logcat", "-c")
        adb("shell", "monkey", "-p", PACKAGE, "-c", "android.intent.category.LAUNCHER", "1")
        time.sleep(4)
    elif cmd == "shot":
        SHOTS.mkdir(exist_ok=True)
        path = SHOTS / f"{rest[0]}.png"
        path.write_bytes(adb("exec-out", "screencap", "-p", binary=True))
        print(path.resolve())
    elif cmd == "texts":
        for n in nodes():
            if label(n):
                flags = "[btn]" if n.get("clickable") == "true" else ""
                print(f"{flags}{label(n)[:90]!r} {n['bounds']}")
    elif cmd == "tap":
        return 0 if tap(rest[0]) else 2
    elif cmd == "scrolltap":
        for _ in range(12):
            if find(rest[0]):
                return 0 if tap(rest[0]) else 2
            scroll()
        print(f"NOT FOUND after scrolling: {rest[0]}")
        return 2
    elif cmd == "type":
        adb("shell", "input", "text", rest[0].replace(" ", "%s"))
        time.sleep(0.5)
    elif cmd == "back":
        adb("shell", "input", "keyevent", "KEYCODE_BACK")
        time.sleep(1)
    elif cmd == "scroll":
        scroll()
    elif cmd == "scrollup":
        scroll(up=True)
    elif cmd == "crashes":
        log = adb("logcat", "-d", "*:E")
        hits = [ln for ln in log.splitlines() if "FATAL" in ln or "AndroidRuntime" in ln]
        print("\n".join(hits) or "no crashes")
    else:
        print(__doc__)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
