-- ============================================================================
-- 04_DYNAMIC_TABLES.SQL — Curated layer for EV Battery Production Analytics
-- ============================================================================
USE DATABASE EV_BATTERY_PROD;
USE SCHEMA CURATED;

-- LINE_YIELD_SUMMARY: Production line yield performance and scrap cost
-- Source: GIGAFACTORIES, CELL_BATCHES
CREATE OR REPLACE DYNAMIC TABLE CURATED.LINE_YIELD_SUMMARY
  TARGET_LAG = '5 minutes'
  WAREHOUSE = BATTERY_WH
AS
SELECT * FROM RAW.GIGAFACTORIES;
-- TODO: Replace with actual join/aggregation logic per demo

-- YIELD_TIMESERIES: Daily yield by line for ML.FORECAST input
-- Source: CELL_BATCHES
CREATE OR REPLACE DYNAMIC TABLE CURATED.YIELD_TIMESERIES
  TARGET_LAG = '5 minutes'
  WAREHOUSE = BATTERY_WH
AS
SELECT * FROM RAW.CELL_BATCHES;
-- TODO: Replace with actual join/aggregation logic per demo

-- CELL_HEALTH_SCORES: Cell quality scoring with impedance and capacity metrics
-- Source: FORMATION_CYCLING, CELL_BATCHES
CREATE OR REPLACE DYNAMIC TABLE CURATED.CELL_HEALTH_SCORES
  TARGET_LAG = '5 minutes'
  WAREHOUSE = BATTERY_WH
AS
SELECT * FROM RAW.FORMATION_CYCLING;
-- TODO: Replace with actual join/aggregation logic per demo

-- MATERIAL_QUALITY_TRENDS: Supplier material quality correlation to cell yield
-- Source: SUPPLIER_MATERIALS, CELL_BATCHES
CREATE OR REPLACE DYNAMIC TABLE CURATED.MATERIAL_QUALITY_TRENDS
  TARGET_LAG = '5 minutes'
  WAREHOUSE = BATTERY_WH
AS
SELECT * FROM RAW.SUPPLIER_MATERIALS;
-- TODO: Replace with actual join/aggregation logic per demo

