# Thailand EV Battery Cell Production

**Thailand - EV Battery Cell Manufacturing (electrode to formation)**
Use case: First-pass yield monitoring and quality-hold risk

> Cell manufacturing operations for a synthetic network of 24 EV battery cell lines across 5 Thai provinces: dynamic tables, a holdout-evaluated quality-hold risk classifier, a first-pass yield forecast and grounded AI answers.

## Why Snowflake

- **Dynamic tables** reconcile first-pass yield, energy per cell and availability from RAW line data, with checks in `run_core.py`
- **Hold-risk classification** gives a holdout-evaluated next-7-day quality-hold probability per line
- **First-pass yield forecast** projects 14 days of network-wide yield with prediction intervals
- **Grounded AI**: the Cortex Agent (Analyst over a semantic view, plus Search over SOPs) shows its SQL and SOP citations
- **Live telemetry**: a native simulator (Snowflake only) or IoT Core, S3 and Snowpipe (AWS build), then an alert and email

## What is built

| | |
|---|---|
| Dimension table | `RAW.LINES` (24 rows) |
| Fact table | `RAW.LINE_DAILY` (2,160 line-days, 90 days) |
| Curated layer | `CURATED.KPI_SUMMARY`, `PERFORMANCE_SUMMARY`, `HOLD_CAUSES`, `TREND_ANALYSIS` |
| ML | `ML.HOLD_RISK_SCORES`, `ML.HOLD_RISK_HOLDOUT_METRICS`, `ML.YIELD_FORECAST`, `ML.CTQ_DEV_ANOMALIES` |

Provinces: Rayong, Chonburi, Chachoengsao, Prachinburi, Ayutthaya (real locations; plants, lines and operators are fictional).
Process stages: Electrode Coating, Calendering, Cell Assembly, Electrolyte Filling, Formation and Aging. Each line runs LFP or NMC cells.

## KPI cards (live from `CURATED.KPI_SUMMARY`; no fallback values)

| Card | Value from the seeded data |
|---|---|
| First-Pass Yield | 95.9% |
| Quality Holds | 132 |
| Energy Intensity | 0.214 kWh/cell |
| Cells Started | 28,426,263 |
| Line Availability | 99.2% |
| Lines Monitored | 24 |
| Critical Spares Coverage | 78.2% |

Values are synthetic. A rebuild reproduces them because the data is HASH-seeded; dates are relative to the build day.

## Demo flow

1. Executive Cockpit: KPIs, daily first-pass yield, cells scrapped by root cause, line table
2. Predictive: holdout metrics, risk bands, 14-day first-pass yield forecast, CTQ deviation anomalies
3. Line Health: availability, critical spares coverage, PM compliance against first-pass yield, then generate the action memo
4. Live IoT: run `CALL APP.SIMULATE_TELEMETRY(20)` (Snowflake only) or `python aws/publish_telemetry.py --count 20` (AWS build). Then run `EXECUTE ALERT APP.LIVE_ALARM_ALERT` and show the alert log and email.
5. Ask AI: the Cortex Agent answers metric questions through the semantic view and cites SOPs from Cortex Search. The SQL is shown.
6. QuickSight (AWS build): the same Snowflake tables through DIRECT_QUERY
7. Architecture: both builds side by side

## Talking points

- Per-line first-pass yield ranges from 93.4% to 97.3%. Prachinburi is the lowest province, at 95.3%.
- Formation and Aging lines have the lowest yield; BL-0009 in Rayong has the most quality holds (22).
- Coating weight drift scraps the most cells of the 14 hold causes.
- The risk model is evaluated on a time-based holdout: precision 0.51 and recall 0.36 at 0.5, against a 0.28 base rate. Present it as triage, not a guarantee.
- Site-wide utility power dips are excluded from hold labels, because they are not line-driven.

## Business impact

Use only the sourced references in `README.md` (Business Impact).
