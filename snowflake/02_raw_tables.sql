-- Synthetic line-day observations for EV battery cell production lines
-- (electrode to formation). Nothing is seeded as a prediction. Randomness is
-- HASH-seeded, so every rebuild is reproducible: per-line age and quality-hold
-- propensity, wear between maintenance windows, missed PM, stage-weighted hold
-- causes, and two site-wide utility power dips. Plants and lines are fictional.
USE DATABASE IDENTIFIER($DEMO_DB);
USE SCHEMA RAW;
USE WAREHOUSE IDENTIFIER($DEMO_WH);

CREATE TABLE RAW.LINES AS
WITH lines AS (
  SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 AS LINE_INDEX
  FROM TABLE(GENERATOR(ROWCOUNT => 24))
), draws AS (
  SELECT LINE_INDEX,
         MOD(ABS(HASH(LINE_INDEX, 'thevb-age')), 1000000) / 1e6 AS U_AGE,
         MOD(ABS(HASH(LINE_INDEX, 'thevb-rate')), 1000000) / 1e6 AS U_RATE,
         MOD(ABS(HASH(LINE_INDEX, 'thevb-pm')), 1000000) / 1e6 AS U_PM,
         MOD(ABS(HASH(LINE_INDEX, 'thevb-discipline')), 1000000) / 1e6 AS U_DISCIPLINE,
         MOD(ABS(HASH(LINE_INDEX, 'thevb-capacity')), 1000000) / 1e6 AS U_CAPACITY
  FROM lines
)
SELECT 'BL-' || LPAD(LINE_INDEX::VARCHAR, 4, '0') AS ID,
       'Synthetic cell line ' || LPAD(LINE_INDEX::VARCHAR, 4, '0') AS NAME,
       -- Deterministic spread (8 and 5 are coprime): every site and stage is present.
       CASE MOD(LINE_INDEX, 8) WHEN 0 THEN 'Rayong' WHEN 1 THEN 'Rayong' WHEN 2 THEN 'Rayong'
            WHEN 3 THEN 'Chonburi' WHEN 4 THEN 'Chonburi' WHEN 5 THEN 'Chachoengsao' WHEN 6 THEN 'Prachinburi'
            ELSE 'Ayutthaya' END AS REGION,
       CASE MOD(LINE_INDEX, 5) WHEN 0 THEN 'Electrode Coating' WHEN 1 THEN 'Calendering'
            WHEN 2 THEN 'Cell Assembly' WHEN 3 THEN 'Electrolyte Filling' ELSE 'Formation and Aging' END AS CATEGORY,
       IFF(MOD(LINE_INDEX, 3) = 0, 'NMC', 'LFP') AS CHEMISTRY,
       LINE_INDEX,
       ROUND(1 + U_AGE * 7, 1) AS AGE_YEARS,
       -- Base daily hold probability 0.5%-3%; ~15% of lines are chronic (x3).
       (0.005 + U_RATE * 0.025) * IFF(U_RATE > 0.85, 3, 1) AS BASE_HOLD_RATE,
       7 * (1 + FLOOR(U_PM * 3)) AS PM_INTERVAL_DAYS,
       0.55 + U_DISCIPLINE * 0.45 AS PM_COMPLETION_PROB,
       -- Prismatic LFP cells carry more amp-hours than the NMC pouch format.
       ROUND(IFF(MOD(LINE_INDEX, 3) = 0, 60 + U_CAPACITY * 20, 280 + U_CAPACITY * 34)) AS CELL_CAPACITY_AH,
       'Active' AS STATUS
FROM draws;

CREATE TABLE RAW.LINE_DAILY AS
WITH days AS (
  SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 AS DAY_INDEX
  FROM TABLE(GENERATOR(ROWCOUNT => 90))
), power_dips AS (
  -- Two site-wide utility power dips in the window.
  SELECT * FROM VALUES (31, 'Rayong', 2.5), (58, 'Chonburi', 1.5) AS o(DAY_INDEX, REGION, HOURS)
), base AS (
  SELECT l.ID AS ENTITY_ID, l.LINE_INDEX, l.CATEGORY, l.REGION, l.AGE_YEARS,
         l.BASE_HOLD_RATE, l.PM_INTERVAL_DAYS, l.PM_COMPLETION_PROB,
         d.DAY_INDEX,
         DATEADD('day', d.DAY_INDEX - 89, CURRENT_DATE()) AS EVENT_DATE,
         24.0 AS PLANNED_HOURS,
         MOD(d.DAY_INDEX + l.LINE_INDEX * 3, l.PM_INTERVAL_DAYS) AS DAYS_SINCE_PM,
         MOD(ABS(HASH(l.ID, d.DAY_INDEX, 'thevb-hold')), 1000000) / 1e6 AS U_HOLD,
         MOD(ABS(HASH(l.ID, d.DAY_INDEX, 'thevb-down')), 1000000) / 1e6 + 1e-6 AS U_DOWN,
         MOD(ABS(HASH(l.ID, d.DAY_INDEX, 'thevb-cause')), 1000000) / 1e6 AS U_CAUSE,
         MOD(ABS(HASH(l.ID, d.DAY_INDEX, 'thevb-pmdone')), 1000000) / 1e6 AS U_PMDONE,
         MOD(ABS(HASH(l.ID, d.DAY_INDEX, 'thevb-rate')), 1000000) / 1e6 AS U_RATE,
         MOD(ABS(HASH(l.ID, d.DAY_INDEX, 'thevb-noise')), 1000000) / 1e6 AS U_NOISE,
         MOD(ABS(HASH(l.ID, d.DAY_INDEX, 'thevb-hit')), 1000000) / 1e6 AS U_HIT,
         p.HOURS AS DIP_HOURS
  FROM RAW.LINES l CROSS JOIN days d
  LEFT JOIN power_dips p ON p.DAY_INDEX = d.DAY_INDEX AND p.REGION = l.REGION
), pm AS (
  SELECT *,
         IFF(DAYS_SINCE_PM = 0, 1, 0) AS PM_DUE,
         IFF(DAYS_SINCE_PM = 0 AND U_PMDONE < PM_COMPLETION_PROB, 1, 0) AS PM_COMPLETED,
         -- Wear (die shims, rolls, weld horns, nozzles) rises between PM; weak discipline carries it over.
         DAYS_SINCE_PM / PM_INTERVAL_DAYS + (1 - PM_COMPLETION_PROB) AS WEAR
  FROM base
), holds AS (
  SELECT *,
         CASE WHEN DIP_HOURS IS NOT NULL THEN 1
              WHEN U_HOLD < LEAST(0.5, BASE_HOLD_RATE * (0.4 + 1.6 * WEAR) * (1 + AGE_YEARS / 12)) / 4 THEN 2
              WHEN U_HOLD < LEAST(0.5, BASE_HOLD_RATE * (0.4 + 1.6 * WEAR) * (1 + AGE_YEARS / 12)) THEN 1
              ELSE 0 END AS HOLD_COUNT
  FROM pm
), timed AS (
  SELECT *,
         -- Line-down hours: exponential, mean depends on the stage.
         CASE WHEN HOLD_COUNT = 0 THEN 0.0
              WHEN DIP_HOURS IS NOT NULL THEN DIP_HOURS
              ELSE LEAST(20.0, ROUND(HOLD_COUNT * (0.5 - LN(U_DOWN) *
                   CASE CATEGORY WHEN 'Electrode Coating' THEN 3.0 WHEN 'Calendering' THEN 2.0
                                 WHEN 'Cell Assembly' THEN 3.5 WHEN 'Electrolyte Filling' THEN 2.5 ELSE 4.0 END), 1))
         END AS DOWNTIME_HOURS
  FROM holds
), output AS (
  SELECT *,
         PLANNED_HOURS - DOWNTIME_HOURS AS OPERATING_HOURS,
         -- 420-680 cells per hour while running.
         ROUND((PLANNED_HOURS - DOWNTIME_HOURS) * (420 + U_RATE * 260)) AS CELLS_STARTED,
         -- First-pass yield: base by stage, minus wear, age and the hold hit.
         LEAST(0.998, GREATEST(0.60,
           CASE CATEGORY WHEN 'Electrode Coating' THEN 0.985 WHEN 'Calendering' THEN 0.990
                         WHEN 'Cell Assembly' THEN 0.975 WHEN 'Electrolyte Filling' THEN 0.982 ELSE 0.962 END
           - 0.02 * WEAR - 0.004 * AGE_YEARS / 10 - 0.006 * U_NOISE
           - HOLD_COUNT * (0.03 + 0.07 * U_HIT))) AS FIRST_PASS_YIELD,
         -- Energy per cell by stage; wear and holds add losses.
         CASE CATEGORY WHEN 'Electrode Coating' THEN 0.30 WHEN 'Calendering' THEN 0.06
                       WHEN 'Cell Assembly' THEN 0.10 WHEN 'Electrolyte Filling' THEN 0.04 ELSE 0.55 END
           * (1 + 0.08 * WEAR + 0.15 * HOLD_COUNT + 0.04 * U_NOISE) AS KWH_PER_CELL
  FROM timed
)
SELECT ENTITY_ID || '-' || TO_CHAR(EVENT_DATE, 'YYYYMMDD') AS EVENT_ID,
       ENTITY_ID, EVENT_DATE, PLANNED_HOURS, DOWNTIME_HOURS, OPERATING_HOURS,
       HOLD_COUNT,
       CASE WHEN HOLD_COUNT = 0 THEN 'None'
            WHEN DIP_HOURS IS NOT NULL THEN 'Utility power dip'
            WHEN CATEGORY = 'Electrode Coating' THEN IFF(U_CAUSE < 0.5, 'Coating weight drift', IFF(U_CAUSE < 0.8, 'Slurry agglomeration', 'Drying oven temperature excursion'))
            WHEN CATEGORY = 'Calendering' THEN IFF(U_CAUSE < 0.45, 'Roll gap deviation', IFF(U_CAUSE < 0.8, 'Electrode edge cracking', 'Thickness variation'))
            WHEN CATEGORY = 'Cell Assembly' THEN IFF(U_CAUSE < 0.5, 'Separator misalignment', IFF(U_CAUSE < 0.8, 'Tab weld defect', 'Particle contamination'))
            WHEN CATEGORY = 'Electrolyte Filling' THEN IFF(U_CAUSE < 0.6, 'Fill volume deviation', 'Dry room humidity excursion')
            ELSE IFF(U_CAUSE < 0.6, 'Self-discharge out of spec', 'Formation channel fault') END AS ROOT_CAUSE,
       PM_DUE, PM_COMPLETED,
       CELLS_STARTED,
       ROUND(CELLS_STARTED * FIRST_PASS_YIELD) AS CELLS_PASSED,
       ROUND(CELLS_STARTED * KWH_PER_CELL / 1000 + DOWNTIME_HOURS * 0.2, 2) AS ENERGY_MWH,
       ROUND(0.5 + 2.0 * WEAR + 2.4 * HOLD_COUNT + U_NOISE * 0.7, 2) AS CTQ_DEV_PCT,
       ROUND(27 + 3.5 * WEAR + 4 * HOLD_COUNT + U_NOISE * 2, 1) AS CELL_TEMP_C,
       CURRENT_TIMESTAMP() AS LOADED_AT
FROM output;

-- Critical spares coverage per line (snapshot).
CREATE TABLE RAW.CRITICAL_SPARES AS
SELECT ID AS ENTITY_ID,
       CASE CATEGORY WHEN 'Electrode Coating' THEN 'Coating die shim set' WHEN 'Calendering' THEN 'Calender roll bearing'
                     WHEN 'Cell Assembly' THEN 'Ultrasonic weld horn' WHEN 'Electrolyte Filling' THEN 'Fill nozzle assembly'
                     ELSE 'Formation channel board' END AS PART_TYPE,
       1 + MOD(ABS(HASH(ID, 'thevb-req')), 4) AS REQUIRED_QTY,
       MOD(ABS(HASH(ID, 'thevb-hand')), 5) AS ON_HAND_QTY,
       IFF(MOD(ABS(HASH(ID, 'thevb-hand')), 5) < 1 + MOD(ABS(HASH(ID, 'thevb-req')), 4),
           MOD(ABS(HASH(ID, 'thevb-order')), 3), 0) AS ON_ORDER_QTY,
       CURRENT_DATE() AS SNAPSHOT_DATE
FROM RAW.LINES;
