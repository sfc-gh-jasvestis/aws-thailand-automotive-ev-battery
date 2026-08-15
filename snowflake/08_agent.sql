-- ============================================================================
-- 08_AGENT.SQL — Cortex Agent for EV Battery Production Analytics
-- ============================================================================
USE DATABASE EV_BATTERY_PROD;
USE SCHEMA APP;

CREATE OR REPLACE CORTEX AGENT APP.BATTERY_INTELLIGENCE_AGENT
  COMMENT = 'EV Battery Production Analytics AI Assistant'
  MODEL = 'claude-opus-4-8'
  TOOLS = (
    SEMANTIC_VIEW_TOOL(SEMANTIC_VIEW => 'EV_BATTERY_PROD.APP.BATTERY_PRODUCTION_ANALYTICS'),    CORTEX_SEARCH_TOOL(CORTEX_SEARCH_SERVICE => 'EV_BATTERY_PROD.SEARCH.BATTERY_QUALITY_SEARCH', TOOL_DESCRIPTION => 'Search documents for Automotive Manufacturing information')
  )
  SYSTEM_PROMPT = 'You are the Battery Intelligence Agent for 6 EV battery gigafactories in Thailand''s Eastern Economic Corridor.';
