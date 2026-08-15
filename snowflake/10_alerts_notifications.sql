-- ============================================================================
-- 10_ALERTS_NOTIFICATIONS.SQL — Alerts for EV Battery Production Analytics
-- ============================================================================
USE DATABASE EV_BATTERY_PROD;
USE SCHEMA APP;

-- Notification integration (email)
CREATE OR REPLACE NOTIFICATION INTEGRATION aws_thailand_automotive_ev_battery_EMAIL_INT
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('jonathan.asvestis@snowflake.com');

-- Alert: YIELD_CRITICAL_ALERT
CREATE OR REPLACE ALERT APP.YIELD_CRITICAL_ALERT
  WAREHOUSE = BATTERY_WH
  SCHEDULE = '5 MINUTE'
  COMMENT = 'Cell yield below critical threshold'
IF (EXISTS (
  SELECT 1 FROM CURATED.LINE_YIELD_SUMMARY
  WHERE 1=1 -- Condition: AVG_YIELD_PCT < 90 for any production line
))
THEN
  CALL SYSTEM$SEND_EMAIL(
    'aws_thailand_automotive_ev_battery_EMAIL_INT',
    'jonathan.asvestis@snowflake.com',
    '[ALERT] EV Battery Production Analytics: Cell yield below critical threshold',
    'Cell yield below critical threshold'
  );

ALTER ALERT APP.YIELD_CRITICAL_ALERT RESUME;

-- Alert: THERMAL_RUNAWAY_ALERT
CREATE OR REPLACE ALERT APP.THERMAL_RUNAWAY_ALERT
  WAREHOUSE = BATTERY_WH
  SCHEDULE = '5 MINUTE'
  COMMENT = 'Thermal runaway risk detected in formation'
IF (EXISTS (
  SELECT 1 FROM CURATED.LINE_YIELD_SUMMARY
  WHERE 1=1 -- Condition: MAX_TEMP > 80°C during formation cycling
))
THEN
  CALL SYSTEM$SEND_EMAIL(
    'aws_thailand_automotive_ev_battery_EMAIL_INT',
    'jonathan.asvestis@snowflake.com',
    '[ALERT] EV Battery Production Analytics: Thermal runaway risk detected in formation',
    'Thermal runaway risk detected in formation'
  );

ALTER ALERT APP.THERMAL_RUNAWAY_ALERT RESUME;

