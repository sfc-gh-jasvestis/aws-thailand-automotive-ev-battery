-- ============================================================================
-- 11_TASK_PIPELINE.SQL — Task DAG for EV Battery Production Analytics
-- ============================================================================
USE DATABASE EV_BATTERY_PROD;
USE SCHEMA APP;

CREATE OR REPLACE TASK APP.TASK_RETRAIN_MODELS
  WAREHOUSE = BATTERY_WH
  SCHEDULE = 'USING CRON 0 */4 * * * UTC'
  COMMENT = 'Retrain battery ML models'
AS
  SELECT 1; -- Replace with actual refresh logic

CREATE OR REPLACE TASK APP.TASK_REFRESH_QUALITY_AI
  WAREHOUSE = BATTERY_WH
  AFTER APP.TASK_RETRAIN_MODELS
  COMMENT = 'Refresh AI defect classifications'
AS
  SELECT 1; -- Replace with actual refresh logic

CREATE OR REPLACE TASK APP.TASK_REFRESH_ICEBERG
  WAREHOUSE = BATTERY_WH
  AFTER APP.TASK_REFRESH_QUALITY_AI
  COMMENT = 'Export to Iceberg for QuickSight'
AS
  SELECT 1; -- Replace with actual refresh logic

ALTER TASK APP.TASK_REFRESH_ICEBERG RESUME;
ALTER TASK APP.TASK_REFRESH_QUALITY_AI RESUME;
ALTER TASK APP.TASK_RETRAIN_MODELS RESUME;
