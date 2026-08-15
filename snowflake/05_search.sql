-- ============================================================================
-- 05_SEARCH.SQL — Cortex Search for EV Battery Production Analytics
-- ============================================================================
USE DATABASE EV_BATTERY_PROD;
USE SCHEMA SEARCH;

CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH.BATTERY_QUALITY_SEARCH
  ON CONTENT
  ATTRIBUTES REPORT_TYPE, PLANT_ID, SEVERITY
  WAREHOUSE = BATTERY_WH
  TARGET_LAG = '1 hour'
AS (
  SELECT * FROM RAW.QUALITY_REPORTS
);
