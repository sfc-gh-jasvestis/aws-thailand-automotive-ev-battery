-- ============================================================================
-- 07_SEMANTIC_VIEW.SQL — Semantic View for EV Battery Production Analytics
-- ============================================================================
USE DATABASE EV_BATTERY_PROD;
USE SCHEMA APP;

CREATE OR REPLACE SEMANTIC VIEW APP.BATTERY_PRODUCTION_ANALYTICS
  COMMENT = 'EV battery production yield, quality, and equipment analytics'
AS
  TABLES (
    CURATED.LINE_YIELD_SUMMARY AS line_yield_summary,CURATED.YIELD_TIMESERIES AS yield_timeseries,CURATED.CELL_HEALTH_SCORES AS cell_health_scores,CURATED.MATERIAL_QUALITY_TRENDS AS material_quality_trends
  );
