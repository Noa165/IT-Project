#!/bin/bash
# Collect one sample of Waze jams (layer 892) and alerts (layer 891)
# from the Tel Aviv Municipality GIS service, and save it as
# raw/YYYY-mm-dd/HHMM.json.gz (UTC), as described in SOURCE.md.
set -euo pipefail

DAY=$(date -u +%Y-%m-%d)
TIME=$(date -u +%H%M)
OUT="raw/$DAY/$TIME.json.gz"

JAMS_URL="https://gisn.tel-aviv.gov.il/arcgis/rest/services/IView2/MapServer/892/query?where=1%3D1&outFields=*&returnGeometry=true&outSR=4326&geometryPrecision=5&f=json"
ALERTS_URL="https://gisn.tel-aviv.gov.il/arcgis/rest/services/IView2/MapServer/891/query?where=1%3D1&outFields=*&returnGeometry=true&outSR=4326&geometryPrecision=5&f=json"

# Never overwrite an existing sample (raw/ is append-only)
if [ -e "$OUT" ]; then
    echo "ERROR: $OUT already exists" >&2
    exit 1
fi

# Download into a temporary folder outside the project
TMP=$(mktemp -d)
curl -sf --max-time 60 "$JAMS_URL" > "$TMP/jams.json"
curl -sf --max-time 60 "$ALERTS_URL" > "$TMP/alerts.json"

# Combine both layers into one compact JSON file
jq -c -n --slurpfile jams "$TMP/jams.json" --slurpfile alerts "$TMP/alerts.json" \
    '{jams: $jams[0], alerts: $alerts[0]}' > "$TMP/sample.json"

# Save compressed into raw/, only after everything succeeded
mkdir -p "raw/$DAY"
gzip -c "$TMP/sample.json" > "$OUT"

rm -r "$TMP"
echo "Saved $OUT"
