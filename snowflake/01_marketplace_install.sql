-- ============================================================================
-- 01_MARKETPLACE_INSTALL.SQL — Install marketplace data for EV Battery Production Analytics
-- ============================================================================
USE DATABASE EV_BATTERY_PROD;
USE SCHEMA RAW;

-- Free listings to install from Snowflake Marketplace:
-- Install: Snowflake Public Data (Free)
--   https://app.snowflake.com/marketplace/listing/GZTSZ290BV255

-- Paid listing (mock): CEIC ASEAN Macro
--   Real data: https://app.snowflake.com/marketplace/listing/GZTSZRC7HPI
--   Using mock table: THAI_EV_MARKET
CREATE TABLE IF NOT EXISTS RAW.THAI_EV_MARKET (
  ID INT AUTOINCREMENT, DATA VARIANT, LOADED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Paid listing (mock): OnPoint Historical Weather
--   Real data: https://app.snowflake.com/marketplace/listing/GZSOZBT22EH
--   Using mock table: WEATHER_RAYONG
CREATE TABLE IF NOT EXISTS RAW.WEATHER_RAYONG (
  ID INT AUTOINCREMENT, DATA VARIANT, LOADED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

