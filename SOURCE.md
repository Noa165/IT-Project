# Data Source – Traffic Jams and Traffic Alerts in Tel Aviv (Waze via the Tel Aviv Municipality)

## 1. The source

| | |
|---|---|
| **Name** | Tel Aviv Municipality GIS map service (IView2) – live Waze traffic layers |
| **Address – jams (layer 892)** | <https://gisn.tel-aviv.gov.il/arcgis/rest/services/IView2/MapServer/892/query?where=1%3D1&outFields=*&returnGeometry=true&outSR=4326&geometryPrecision=5&f=json> |
| **Address – alerts (layer 891)** | <https://gisn.tel-aviv.gov.il/arcgis/rest/services/IView2/MapServer/891/query?where=1%3D1&outFields=*&returnGeometry=true&outSR=4326&geometryPrecision=5&f=json> |
| **Data format** | JSON (ArcGIS REST "query" response). We save both layers of one collection together in one JSON file: `{"jams": ..., "alerts": ...}` |
| **Key / username** | Not required |
| **License** | Public service of the Tel Aviv Municipality, open without registration; no `robots.txt` restrictions. We did not find a written license for these layers. The municipality's open-data policy encourages reuse. The data itself comes from Waze users |
| **Collection frequency** | Every 30 minutes (the service is refreshed about every 10 minutes) |

## 2. What we collect

Once automatic collection starts (`collect.sh` with `cron`), every 30 minutes we will save two
lists from the same moment. Our first 4 samples were collected manually, one per day.

- **Jams (layer 892):** every traffic jam Waze currently reports in Tel Aviv and nearby cities
  (Ramat Gan, Bnei Brak, Givatayim, Holon, Ramat HaSharon). For each jam: street, the street
  where it ends, jam level, speed, length, delay and the line of the jam on the map. In our 4
  manual samples there were between 131 and 196 jams.
- **Alerts (layer 891):** every report Waze users currently show on the map: accidents,
  hazards, road closures and jam reports, with a location point. In our 4 manual samples there
  were between 88 and 126 alerts (e.g. on 2026-11-16: 4 accidents, 14 hazards, 52 road closures,
  56 jam reports).

The jams tell us **where** the traffic is heavy; the alerts help explain **why** (an accident,
a hazard or a closure nearby). Neither list is archived anywhere: when a jam or an alert ends,
it disappears from the service.

## 3. The schema (`data/dataset.csv`)

All samples are combined into one CSV file. **Each row is one jam or one alert, in one sample.**
The column `record_type` says which one; columns that do not apply to that type are left empty.
All times are in UTC (ISO 8601, e.g. `2026-11-16T13:12:00Z`).

| # | Column | Meaning | Unit / values | Jam | Alert |
|---|---|---|---|---|---|
| 1 | `sample_time_utc` | When we collected the sample (taken from the file path `raw/YYYY-mm-dd/HHMM.json`) | UTC time | ✓ | ✓ |
| 2 | `record_type` | Type of row | `jam` / `alert` | ✓ | ✓ |
| 3 | `waze_id` | Waze's ID of the jam or alert; stays the same across samples, so we can follow it over time | text | ✓ | ✓ |
| 4 | `alert_type` | Kind of alert | `ACCIDENT`, `HAZARD`, `ROAD_CLOSED`, `JAM` | | ✓ |
| 5 | `alert_subtype` | More detail on the alert (often empty) | e.g. `ACCIDENT_MAJOR`, `HAZARD_ON_ROAD_LANE_CLOSED`, `JAM_STAND_STILL_TRAFFIC` | | ✓ |
| 6 | `city` | City | text (Hebrew) | ✓ | ✓ |
| 7 | `street` | Street (sometimes empty) | text (Hebrew) | ✓ | ✓ |
| 8 | `end_street` | The street where the jam ends (often empty) | text (Hebrew) | ✓ | |
| 9 | `road_type` | Waze road type code | number (e.g. 1 = street, 2 = main street, 3 = highway) | ✓ | ✓ |
| 10 | `jam_level` | How heavy the jam is | 0 (free flow) – 5 (standstill / blocked) | ✓ | |
| 11 | `speed_kmh` | Average speed in the jam | km/h | ✓ | |
| 12 | `length_m` | Length of the jam | meters | ✓ | |
| 13 | `delay_sec` | Extra time compared to free flow | seconds; `-1` = road blocked | ✓ | |
| 14 | `reliability` | How reliable Waze considers the alert | 0–10 | | ✓ |
| 15 | `confidence` | How strongly other users confirmed the alert | 0–10 (0–5 in our sample) | | ✓ |
| 16 | `report_rating` | Waze rank of the reporting user | number (0–5 in our sample) | | ✓ |
| 17 | `direction_deg` | Direction of travel of the reporting user | degrees, 0–359 | | ✓ |
| 18 | `lat` | Latitude – the alert point, or the start of the jam | degrees (WGS84), 5 decimals | ✓ | ✓ |
| 19 | `lon` | Longitude – the alert point, or the start of the jam | degrees (WGS84), 5 decimals | ✓ | ✓ |
| 20 | `end_lat` | Latitude of the end of the jam | degrees (WGS84) | ✓ | |
| 21 | `end_lon` | Longitude of the end of the jam | degrees (WGS84) | ✓ | |
| 22 | `first_reported_utc` | When Waze first reported the jam or alert | UTC time | ✓ | ✓ |
| 23 | `updated_utc` | When the service last updated the record (converted to real UTC, see below) | UTC time | ✓ | ✓ |

**Time zones.** In all 4 samples, `pubMillis` is real UTC (e.g. the newest jam was reported at
13:12 UTC, just before we collected at 13:12 UTC), but `updateDate` is Israel time written as if it
were UTC (in the same sample it showed 15:13). We therefore subtract 2 hours from `updateDate` (Israel winter time; the
semester ends before summer time starts at the end of March).

## 4. Why these columns

- **We kept** everything needed to answer our questions: where and how heavy the jams are
  (street, level, speed, delay, length, location), why they happen (alert type and subtype, and
  the alert's location so we can find alerts near a jam), and when (sample time, first report
  time). `waze_id` lets us follow the same jam or closure across samples and measure how long it
  lasts. `reliability` and `confidence` let us ignore weak alerts.
- **One table for both jams and alerts** keeps the dataset in a single CSV, as the project
  requires, and keeps a jam and the alerts of the same moment together by `sample_time_utc`.
- **Long-term closures:** in all 4 samples every jam with level 5 (49–52 per sample) had speed 0
  and delay `-1`, and many were first reported weeks ago (the oldest on 2026-09-30); 34 of the
  52 closures from 2026-11-16 were still there, with the same `uuid`, on 2026-11-19. These are road closures, not
  regular jams. We keep them, and will separate them in the analysis using `delay_sec = -1` and
  `first_reported_utc`.
- **We did not keep:**
  - `OBJECTID` – an internal row number of the map service that changes on every refresh (the
    same closure had a different `OBJECTID` on each day), so it cannot identify a jam; `uuid` can.
  - `country` – always `IL`.
  - `turnType` – always `NONE`; jam `type` – always empty.
  - `SHAPE_Length` – the same as `length` (only more decimals).
  - `nThumbsUp` – always 0; `reportByMunicipalityUser` – always `false`.
  - The full line of each jam (2–149 points, about 12 on average) – we keep only its start and
    end points, which is enough to find nearby alerts and events. The full line stays in `raw/`.
  - Response metadata (`fields`, `fieldAliases`, `displayFieldName`, `geometryType`,
    `spatialReference`) – the same in every sample.

## 5. Field name translation (source → schema)

| Source layer | Source field | Schema column |
|---|---|---|
| file path | `raw/YYYY-mm-dd/HHMM.json` | `sample_time_utc` |
| – | which list the record is in (`jams` / `alerts`) | `record_type` |
| both | `uuid` | `waze_id` |
| 891 | `type` | `alert_type` |
| 891 | `subtype` | `alert_subtype` |
| both | `city` | `city` |
| both | `street` | `street` |
| 892 | `endNode` | `end_street` |
| both | `roadType` | `road_type` |
| 892 | `level` | `jam_level` |
| 892 | `speedKMH` | `speed_kmh` |
| 892 | `length` | `length_m` |
| 892 | `delay` | `delay_sec` |
| 891 | `reliability` | `reliability` |
| 891 | `confidence` | `confidence` |
| 891 | `reportRating` | `report_rating` |
| 891 | `magvar` | `direction_deg` |
| 891 | `geometry.y` | `lat` |
| 891 | `geometry.x` | `lon` |
| 892 | `geometry.paths` – first point (y, x) | `lat`, `lon` |
| 892 | `geometry.paths` – last point (y, x) | `end_lat`, `end_lon` |
| both | `pubMillis` (milliseconds, UTC) | `first_reported_utc` |
| both | `updateDate` (milliseconds, Israel time) | `updated_utc` (minus 2 hours) |
| both | `OBJECTID`, `country` | not kept |
| 892 | `turnType`, `type`, `SHAPE_Length` | not kept |
| 891 | `nThumbsUp`, `reportByMunicipalityUser` | not kept |

## 6. Expected size after one semester

Based on our 4 manual samples (morning, noon and evening, 2026-11-16 to 2026-11-19: on average
about 150 jams and 110 alerts per sample), and assuming about 10 weeks of collection (70 days)
every 30 minutes = 48 samples a day = about 3,360 samples:

| | Per sample (average) | Semester |
|---|---|---|
| `raw/` – uncompressed | about 135 KB | about 450 MB – too close to the 500 MB limit |
| `raw/` – compressed with `gzip` | about 26 KB | **about 90 MB** |
| `data/dataset.csv` | about 260 rows, about 57 KB | **about 900,000 rows, about 190 MB** |

We will therefore compress every raw file with `gzip` in `collect.sh` (as the project rules
allow), and `normalise.sh` will read the compressed files. Raw plus dataset come to about 280 MB,
under the 500 MB limit. Our samples were all taken during the day; at night there are fewer jams,
so the real numbers will probably be a little lower. If space runs short, we can lower the
collection frequency to once an hour.

**Note on our first sample.** The first manual sample (`raw/2026-11-16/1312.json`) is about
407 KB, three times larger than the others. When we combined the two layers with `jq`, it wrote
the JSON "pretty-printed", with spaces and line breaks. From the second sample on we use `jq -c`
(compact output) and `geometryPrecision=5` for the alerts as well. The content is the same, and
`normalise.sh` reads both formats. We did not change the first file, because files in `raw/` must
not be edited.
