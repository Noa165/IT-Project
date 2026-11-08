# Data Source Proposals

## Proposal 1: Weather – Forecast Against Reality (MET Norway and Ben Gurion Airport)

**Description.** We want to check how accurate weather forecasts are for the Tel Aviv area.
Every three hours we will save the forecast of the Norwegian Meteorological Institute (MET
Norway, the service behind yr.no) for Ben Gurion Airport, and the real measurements of the
airport's official weather station. Later we can compare what was forecast for a certain hour
with what was measured, and check whether the forecast improves as that hour approaches.
MET Norway publishes only its latest forecast, so earlier forecasts are lost if we do not save them.

- **Content:** forecast – temperature, humidity, pressure, cloud cover, wind and
  precipitation for about the next 10 days (every hour for the first 2–3 days, then every
  6 hours); measurement – observations from the last 3 hours (time,
  temperature, dew point, wind, pressure, clouds, current weather).
- **URL:**
  - Forecast: <https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=32.01&lon=34.89>
  - Measurement: <https://aviationweather.gov/api/data/metar?ids=LLBG&format=json&hours=3>
- **Update frequency:** MET Norway updates its forecast for Israel about every 6 hours; the
  station reports about every 30 minutes. We will sample both every 3 hours (not at XX:00, as
  MET Norway asks).
- **Expected sample size:** about 40 KB + 3 KB per sample (about 25 MB for the semester).
- **API key or password:** not required (MET Norway only asks for a `User-Agent` header).
- **Terms and limitations:** both sources are free public services made for automated access
  (MET Norway's terms only ask for the `User-Agent` header and limited request frequency; the
  measurement comes from the US Aviation Weather Center's public data API). The station
  reports rain only as yes/no (no millimeters), and it is about 13 km from central Tel Aviv, so
  the forecast is requested for the airport itself. We will use `obsTime` (the real observation
  time), because `reportTime` is rounded.
- **Data sample** (shortened from real responses we downloaded on 2026-11-08):

Forecast – first forecast hour:

```json
{"geometry": {"type": "Point", "coordinates": [34.89, 32.01, 41]},
 "properties": {"meta": {"updated_at": "2026-11-08T17:29:51Z"},
  "timeseries": [{"time": "2026-11-08T18:00:00Z",
    "data": {"instant": {"details": {"air_pressure_at_sea_level": 1022.6, "air_temperature": 14.8,
      "cloud_area_fraction": 25.8, "relative_humidity": 97.2, "wind_from_direction": 137.7,
      "wind_speed": 2.3}},
      "next_1_hours": {"summary": {"symbol_code": "fair_night"},
        "details": {"precipitation_amount": 0.0}}}}]}}
```

Measurement – latest observation (the response had 6 observations from the last 3 hours):

```json
[{"icaoId": "LLBG", "obsTime": 1794163800, "reportTime": "2026-11-08T19:00:00.000Z",
  "temp": 17, "dewp": 12, "wdir": 40, "wspd": 4, "altim": 1022, "cover": "FEW",
  "rawOb": "METAR LLBG 081850Z 04004KT 9999 FEW050 17/12 Q1022 NOSIG"}]
```

## Proposal 2: Traffic Jams in Tel Aviv – Live Waze Data (Tel Aviv Municipality GIS)

**Description.** The Tel Aviv Municipality publishes live traffic data from Waze on its public
map service: every current traffic jam in Tel Aviv and nearby cities, with its street, level,
speed and delay. We want to find which streets are most congested, at what hours and days,
and whether rain makes traffic worse. The service shows only current jams; when a jam clears
it disappears and no history is published, so the data is lost if we do not save it.

- **Content:** for each jam: city, street, end street, level (0–5), speed (km/h), length (m),
  delay (seconds), road type, jam ID, first report time and last update time.
- **URL:** <https://gisn.tel-aviv.gov.il/arcgis/rest/services/IView2/MapServer/892/query?where=1%3D1&outFields=city,street,endNode,level,speedKMH,length,delay,roadType,uuid,pubMillis,updateDate&returnGeometry=false&f=json>
- **Update frequency:** about every 10 minutes. We will sample every 30 minutes.
- **Expected sample size:** about 20–30 KB per sample (about 80 records in the evening), roughly
  70–100 MB for the semester before compression, and much less when compressed.
- **API key or password:** not required.
- **Terms and limitations:** a public municipal service with no registration. The data comes
  from Waze users, so quiet streets may be missing. Many records with level 5, speed 0 and
  delay -1 are long-term road closures (reported weeks ago), not regular jams, so we will
  analyse them separately. The time fields are in Israel time written as if they were UTC (about 2 hours ahead),
  so we will convert them to real UTC.
  Rain data will come from a weather source we connect in week 7.
- **Data sample** (shortened from a real response we downloaded on 2026-11-08; 2 of about 80
  records – a regular jam and a road closure):

```json
{"features": [
  {"attributes": {"city": "תל אביב - יפו", "street": "מיטב", "endNode": "קרמניצקי",
    "level": 2, "speedKMH": 3.57, "length": 222, "delay": 112, "roadType": 1,
    "uuid": "1278365732", "pubMillis": "1794163627211", "updateDate": 1794171183520}},
  {"attributes": {"city": "תל אביב - יפו", "street": "אלנבי", "endNode": "רוטשילד",
    "level": 5, "speedKMH": 0, "length": 88, "delay": -1, "roadType": 2,
    "uuid": "1146601566", "pubMillis": "1790772429253", "updateDate": 1794171183517}}]}
```

## Ranking

1. **Weather – Forecast Against Reality** (our first choice)
2. **Traffic Jams in Tel Aviv – Live Waze Data**

We prefer the weather proposal because it compares a forecast with a real measurement, which
gives the clearest findings, and every sample contains data. The traffic proposal is local and
changes often, but at night there are few jams and the data depends on Waze users.
