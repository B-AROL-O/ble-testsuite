# extras/BatteryMonitor

(2023-09-19 11:40 CEST)
Contents copied from
<https://github.com/arduino/ArduinoCore-mbed/tree/4.0.6/libraries/Nicla_System/extras/BatteryMonitor>
using the following script:

```bash
# https://github.com/arduino/ArduinoCore-mbed/releases/tag/4.0.6
GITHUB_REPO="arduino/ArduinoCore-mbed
GITHUB_BRANCH="4.0.6"
UPSTREAM_REPO="https://github.com/$GITHUB_REPO"
# UPSTREAM_SHA="2871417f6414d8139a08448c496326af460aa903"
SOURCES_PATH="libraries/Nicla_System/extras/BatteryMonitor"
# BASE_URL="$UPSTREAM_REPO/blob/$UPSTREAM_SHA"
BASE_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$UPSTREAM_SHA"

for f in index.html style.css app.js; do
    curl -fsSL -o "$f" "$BASE_URL/$SOURCES_PATH/$f"
done
```

<!-- EOF -->