-- ============================================================================
-- 03_STAGING.SQL — Generate synthetic data for EV Battery Production Analytics
-- Country: THAILAND | Currency: THB
-- ============================================================================
USE DATABASE EV_BATTERY_PROD;
USE SCHEMA RAW;

-- Data generation scripts are demo-specific.
-- See the handcrafted SQL in the aws-malaysia-semiconductor-yield demo for
-- the full pattern: GENERATOR + UNIFORM + LATERAL for distribution,
-- Cortex Complete for text generation, engineered key demo numbers.

-- Target row counts:
-- GIGAFACTORIES: 6 rows — EV battery manufacturing plants (Rayong, Chonburi, Chachoengsao)
-- PRODUCTION_LINES: 36 rows — Cell production lines across all plants
-- CELL_BATCHES: 8,000 rows — 90 days of cell batch production records with yield and test results
-- CELL_TELEMETRY: 600,000 rows — IoT sensor readings (temperature, pressure, humidity, coating thickness)
-- FORMATION_CYCLING: 200,000 rows — Cell formation and grading data (capacity, impedance, OCV)
-- QUALITY_REPORTS: 120 rows — Lab test reports, audit findings, customer complaints
-- SUPPLIER_MATERIALS: 500 rows — Raw material quality data (cathode, anode, electrolyte, separator)
-- THAI_EV_MARKET: 12 rows — Thailand EV industry context and policy data
