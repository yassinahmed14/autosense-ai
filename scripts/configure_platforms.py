"""Idempotent local networking setup after flutter create.

Only Android debug permits cleartext HTTP. iOS simulator local networking uses
a dedicated Debug Info.plist; release builds need a real HTTPS API URL.
"""

import plistlib
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "app"
android = ROOT / "android/app/src/main/AndroidManifest.xml"
if not android.exists():
    raise SystemExit("Run flutter create --platforms=android,ios,web . in app first.")
text = android.read_text(encoding="utf-8")
text = text.replace('android:label="autosense_ai"', 'android:label="AutoSense AI"')
permission = '    <uses-permission android:name="android.permission.INTERNET"/>\n'
if "android.permission.INTERNET" not in text:
    text = text.replace("    <application", permission + "    <application", 1)
android.write_text(text, encoding="utf-8")

debug = ROOT / "android/app/src/debug/AndroidManifest.xml"
debug.parent.mkdir(parents=True, exist_ok=True)
debug.write_text(
    """<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application android:usesCleartextTraffic="true"/>
</manifest>
""",
    encoding="utf-8",
)

ios_debug = ROOT / "ios/Flutter/Debug.xcconfig"
if ios_debug.exists():
    info = ROOT / "ios/Runner/Info.plist"
    with info.open("rb") as handle:
        data = plistlib.load(handle)
    data["CFBundleDisplayName"] = "AutoSense AI"
    with info.open("wb") as handle:
        plistlib.dump(data, handle)
    data["NSAppTransportSecurity"] = {"NSAllowsLocalNetworking": True}
    with (info.parent / "Info-Debug.plist").open("wb") as handle:
        plistlib.dump(data, handle)
    project = ROOT / "ios/Runner.xcodeproj/project.pbxproj"
    if project.exists():
        project_text = project.read_text(encoding="utf-8")
        pattern = r"\w+ /\* Debug \*/ = \{[\s\S]*?\n\t\t\};"
        project_text = re.sub(
            pattern,
            lambda match: match.group(0).replace(
                "INFOPLIST_FILE = Runner/Info.plist;",
                "INFOPLIST_FILE = Runner/Info-Debug.plist;",
            ),
            project_text,
        )
        project.write_text(project_text, encoding="utf-8")
print(
    "Configured Internet permission and debug-only Android HTTP. Use HTTPS on physical iOS/release."
)
