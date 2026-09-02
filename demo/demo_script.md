# EV Battery Production Analytics

**Thailand - Automotive Manufacturing**
Use case: EV Battery Quality & Production

> Real-time monitoring of EV battery cell production across 6 Thai gigafactories — Snowflake ML detects quality excursions, forecasts cell degradation, and alerts production engineers before defective packs reach assembly.

## Why Snowflake

Snowflake detects battery cell anomalies across 6 gigafactories, classifies defect patterns with AI, forecasts production yield, and alerts engineers — all native SQL, replacing SageMaker and custom ML pipelines

- **ML.ANOMALY_DETECTION on battery cell yield** - Only demo using anomaly detection for EV battery formation cycling data
- **Material-to-yield traceability via Dynamic Tables** - Real-time correlation between supplier material quality and cell performance
- **IoT Core → Snowpipe Streaming for formation data** - Sub-second ingestion of battery formation cycling telemetry
- **Thai EEC gigafactory context** - Thailand's ฿500B EV investment with real factory locations and Thai company names
- **Thermal runaway early warning** - ML.ANOMALY_DETECTION on temperature profiles during formation cycling
- **Cortex Search on battery quality standards** - Searchable index of Thai Industrial Standards Institute (TISI) battery regulations

## What is deployed

| | |
|---|---|
| Database | `THAILAND_AUTOMOTIVE_EV_BATTERY` |
| Service | `THAILAND_AUTOMOTIVE_EV_BATTERY_APP` |
| Compute pool | `SEA_DEMOS_THAILAND_POOL` |
| Dimension table | `RAW.GIGAFACTORIES` (20 rows) |
| Fact table | `RAW.CELL_TELEMETRY` (250,000 rows, 90 days) |
| Curated layer | `CURATED.PERFORMANCE_SUMMARY`, `CURATED.TREND_ANALYSIS`, `CURATED.KPI_SUMMARY` |
| Currency | THB (฿) |

Regions in play: Bangkok, Chonburi, Rayong, Chiang Mai, Songkhla
Segments: Cell, Module, Pack, Battery Management System

Dynamic tables are created suspended and refreshed on demand:

```bash
./refresh_demo_data.sh THAILAND_AUTOMOTIVE_EV_BATTERY
```

## KPI cards

Every card below is served live from `CURATED.KPI_SUMMARY`. The app keeps the
original literal as a fallback, so it still renders if Snowflake is unreachable.

| Card | Value | Backed by |
|---|---|---|
| Battery Yield | `97.8%` | average per event |
| Cell Defect Rate | `0.12%` | average per event |
| Thermal Events (MTD) | `0` | total across Gigafactories |
| Packs Produced | `8,420` | total across Gigafactories |
| Avg Impedance | `12.4 mΩ` | average per event |
| Formation Efficiency | `99.1%` | average per event |
| Cycle Life Pred. | `1,847` | total across Gigafactories |


## Demo flow

1. Executive Cockpit
2. Cell Yield Analytics
3. Material & Supplier Quality
4. Ask AI
5. Architecture & Data

## Talking points

- **฿850M** - annual scrap cost across 6 gigafactories (US$24M)
- **3 of 36 lines** - below 90% yield target (CRITICAL status)
- **12 thermal events** - flagged in the last 72 hours
- **9 of 14 days** - anomalous for Line-03 (ML.ANOMALY_DETECTION)
- **600K readings** - ingested daily via IoT Core → Snowpipe Streaming
- **5-day forecast** - yield collapse predicted without intervention (ML.FORECAST)

## Business impact

- Thailand targets 725,000 EV production by 2030, investing ฿500B in EEC battery plants (BOI Thailand)
- AI-powered battery quality monitoring reduces scrap rates by 15-25% in cell manufacturing (McKinsey Battery 2030)
- Predictive quality in battery production prevents $2-5M per recall event (Deloitte EV Manufacturing)
- BYD Thailand factory in Rayong produces 150,000 EVs annually since 2024 (Bangkok Post)

---
Generated from `generator/demo_specs/aws-thailand-automotive-ev-battery.json`. Do not hand-edit: run
`python3 generator/gen_repo_docs.py aws-thailand-automotive-ev-battery` instead.
