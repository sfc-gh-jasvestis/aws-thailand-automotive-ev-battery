-- ============================================================================
-- EV Battery Production Analytics
-- Real-time monitoring of EV battery cell production across 6 Thai gigafactories — Snowflake ML detects quality excursions, forecasts cell degradation, and alerts production engineers before defective packs reach assembly.
-- ============================================================================
USE ROLE ACCOUNTADMIN;
CREATE DATABASE IF NOT EXISTS EV_BATTERY_PROD;
CREATE WAREHOUSE IF NOT EXISTS BATTERY_WH WAREHOUSE_SIZE = 'MEDIUM' AUTO_SUSPEND = 120 AUTO_RESUME = TRUE;
USE DATABASE EV_BATTERY_PROD;
CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS CURATED;
CREATE SCHEMA IF NOT EXISTS ML;
CREATE SCHEMA IF NOT EXISTS AI;
CREATE SCHEMA IF NOT EXISTS SEARCH;
CREATE SCHEMA IF NOT EXISTS APP;

USE WAREHOUSE BATTERY_WH;
