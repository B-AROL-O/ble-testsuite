# extras/BatteryMonitor

(2023-05-11 08:47 CEST)
Contents copied from
<https://github.com/sebromero/ArduinoCore-mbed/tree/sebromero/pmic-fix/libraries/Nicla_System/extras/BatteryMonitor>
using the following script:

```bash
# https://github.com/arduino/ArduinoCore-mbed/pull/680
UPSTREAM_REPO="https://github.com/sebromero/ArduinoCore-mbed"
UPSTREAM_BRANCH="sebromero/pmic-fix"
UPSTREAM_SHA="2871417f6414d8139a08448c496326af460aa903"
SOURCES_PATH="libraries/Nicla_System/extras/BatteryMonitor"
BASE_URL="$UPSTREAM_REPO/blob/$UPSTREAM_SHA"

for f in index.html style.css app.js; do
    curl -fsSL -o "$f" "$BASE_URL/$SOURCES_PATH/$f"
done
```

<!-- EOF -->