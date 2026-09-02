-- Generated from generator/demo_specs/aws-thailand-automotive-ev-battery.json
-- Regenerate with: python3 generator/gen_repo_docs.py aws-thailand-automotive-ev-battery
-- This is the schema that is actually deployed for THAILAND_AUTOMOTIVE_EV_BATTERY.

-- THAILAND_AUTOMOTIVE_EV_BATTERY  (EV Battery Production Analytics)
-- generated from generator/demo_specs/aws-thailand-automotive-ev-battery.json - do not hand-edit
CREATE DATABASE IF NOT EXISTS THAILAND_AUTOMOTIVE_EV_BATTERY;
CREATE SCHEMA IF NOT EXISTS THAILAND_AUTOMOTIVE_EV_BATTERY.RAW;
CREATE SCHEMA IF NOT EXISTS THAILAND_AUTOMOTIVE_EV_BATTERY.CURATED;
CREATE SCHEMA IF NOT EXISTS THAILAND_AUTOMOTIVE_EV_BATTERY.APP;
USE DATABASE THAILAND_AUTOMOTIVE_EV_BATTERY;

-- 5 real regions; entity names carry their region so the two always agree
