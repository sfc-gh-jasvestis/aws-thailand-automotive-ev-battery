# Demo Script: EV Battery Production Analytics
## ~4-Minute Recorded Walkthrough
**Format**: Screen recording with voiceover
**Target**: Customer meeting / booth loop / social share
**Narrative**: "Snowflake detects battery cell anomalies across 6 gigafactories, classifies defect patterns with AI, forecasts production yield, and alerts engineers — all native SQL, replacing SageMaker and custom ML pipelines"
**Demo Mode**: Open app with `?demo=true` for presenter notes

---

## Two Personas

| Persona | Role | Tool | What they care about |
|---|---|---|---|
| **Somchai Wongsurawat** | VP Battery Manufacturing | React App (SPCS) | Cell yield rates, defect cost, capacity utilization, pack failure rates |
| **Kanokwan Lertpanichkul** | Battery Process Engineer | Amazon QuickSight | Electrode coating uniformity, electrolyte fill accuracy, formation cycling anomalies, thermal runaway risk |

---

## What's Built

| Layer | Component | Detail |
|---|---|---|
| **RAW** | 8 tables | GIGAFACTORIES (6), PRODUCTION_LINES (36), CELL_BATCHES (8000), CELL_TELEMETRY (600000), FORMATION_CYCLING (200000), QUALITY_REPORTS (120), SUPPLIER_MATERIALS (500), THAI_EV_MARKET (12) |
| **CURATED** | 4 Dynamic Tables | LINE_YIELD_SUMMARY, YIELD_TIMESERIES, CELL_HEALTH_SCORES, MATERIAL_QUALITY_TRENDS |
| **ML** | ML.FORECAST + ML.ANOMALY_DETECTION | Forecasting + anomaly detection |
| **AI** | COMPLETE, AI_CLASSIFY, SUMMARIZE | Classification + extraction |
| **Search** | Cortex Search | 120 documents indexed |
| **Agent** | BATTERY_INTELLIGENCE_AGENT | Semantic View + Search tools |


---

## The Story

Thailand's Eastern Economic Corridor hosts 6 EV battery gigafactories producing cells for BYD, Great Wall Motor, and MG. A 3.8% yield degradation across 3 production lines is generating ฿850M in annual scrap — the root cause spans electrode coating variance, electrolyte fill accuracy, and cathode material purity that traditional QC catches too late.

---

## Script

### [0:00–0:45] EXECUTIVE COCKPIT

**Show**: Executive Cockpit tab

> "Eight hundred fifty million baht in annual scrap cost across 6 gigafactories in the EEC."

**Action**: Point at the ฿850M scrap cost KPI card

### [0:45–1:30] CELL YIELD ANALYTICS

**Show**: Cell Yield Analytics tab

> "Line-03 in Rayong producing NCM811 cells — yield at 87.2%, below 90% target."

**Action**: Click Line-03 in the line list

### [1:30–2:15] MATERIAL & SUPPLIER QUALITY

**Show**: Material & Supplier Quality tab

> "Supplier material quality correlates with yield drops — cathode Batch-CH2847 showing purity variance."

**Action**: Show material-to-yield correlation chart

### [2:15–3:00] ASK AI

**Show**: Ask AI tab

> "Somchai asks: 'What is our total scrap cost this quarter by plant?'"

**Action**: Type: 'Total scrap cost by plant this quarter'

### [3:00–3:45] ARCHITECTURE & DATA

**Show**: Architecture & Data tab

> "Eight Snowflake capabilities, six AWS services."

**Action**: Walk through architecture diagram


---

## Key Demo Differentiators

1. **ML.ANOMALY_DETECTION on battery cell yield** — Only demo using anomaly detection for EV battery formation cycling data
2. **Material-to-yield traceability via Dynamic Tables** — Real-time correlation between supplier material quality and cell performance
3. **IoT Core → Snowpipe Streaming for formation data** — Sub-second ingestion of battery formation cycling telemetry
4. **Thai EEC gigafactory context** — Thailand's ฿500B EV investment with real factory locations and Thai company names
5. **Thermal runaway early warning** — ML.ANOMALY_DETECTION on temperature profiles during formation cycling
6. **Cortex Search on battery quality standards** — Searchable index of Thai Industrial Standards Institute (TISI) battery regulations


---

## Demo Prep Checklist

### Data Verification
- [ ] `SELECT COUNT(*) FROM EV_BATTERY_PROD.RAW.CELL_BATCHES` → 8000
- [ ] `SELECT COUNT(*) FROM EV_BATTERY_PROD.RAW.CELL_TELEMETRY` → 600000
- [ ] `SELECT COUNT(DISTINCT LINE_ID) FROM EV_BATTERY_PROD.CURATED.LINE_YIELD_SUMMARY WHERE YIELD_STATUS = 'CRITICAL'` → 3

### ML Model Verification
- [ ] `SELECT COUNT(*) FROM EV_BATTERY_PROD.ML.BATTERY_YIELD_FORECAST_RESULTS` → >0
- [ ] `SELECT SUM(CASE WHEN IS_ANOMALY THEN 1 ELSE 0 END) FROM EV_BATTERY_PROD.ML.CELL_QUALITY_ANOMALY_RESULTS WHERE SERIES = 'LINE-03'` → >=7

### AI/Agent Verification
- [ ] `SELECT COUNT(*) FROM EV_BATTERY_PROD.AI.QUALITY_REPORT_SUMMARIES` → 120

