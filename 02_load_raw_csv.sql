/* ============================================================================
   02_load_raw_csv.sql
   Purpose: Load raw ATP, WTA match and player bio CSVs (from tennismylife.org) into 
            Snowflake's raw (Bronze) layer, unmodified from source.

   Principle followed throughout: the raw layer preserves exactly what was downloaded from source, 
   including its errors and quirks. Any cleaning/correction will
   happen downstream in the dbt staging layer, where the logic is visible, 
   version-controlled, and testable.

   All three tables are defined manually (not via INFER_SCHEMA +
   CREATE TABLE ... USING TEMPLATE). Inference was tried first and abandoned
   for two reasons documented below: it guesses column types from a limited
   sample and gets some wrong (#1, #2), and it stores inferred columns as
   quoted, case-preserved identifiers, which then requires every future
   reference to that column to be double-quoted.

   Summary of data quality issues discovered while building this script:
   1. WTA seed columns ('winner_seed'/'loser_seed') contain non-numeric 
      values ('Q', 'ALT', 'WC', 'LL') for qualifiers/alternates/wildcards,
      not just seed numbers. Snowflake's INFER_SCHEMA guessed these as 
      NUMBER based on a sample file that happened to only contain numeric 
      seeds, which broke on every other file. Fixed by defining the table 
      manually rather than trusting inference. I believe these actually belong
      in the winner_entry/loser_columns and will investigate and address in staging layer. 
   2. WTA rank/rank_points and stat columns (aces, break points, etc.) were 
      inferred with too narrow a numeric precision from the same limited 
      sample, causing "out of range" errors on historical files with larger 
      values. Fixed the same way as #1 i.e generously-sized column types.
   3. ATP's 1967 file has 49 columns instead of 50. 
      The indoor column simply wasn't tracked.
      It's handled with ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE, 
      which lets those columns load as NULL (correctly meaning "not 
      recorded") rather than 0 (which would incorrectly mean "recorded as 
      zero" and skew data).
   4. WTA's 2026 file (current, in-progress season) has one row with 49 
      fields instead of the expected 50. Not really sure why I encountered an error on 
      this file but handled with ON_ERROR = 'CONTINUE' so the rest 
      of the file loads; the specific bad row still needs isolating with a 
      script for a permanent fix upstream.
   5. atp_tour originally contained a player biographical file
      (ATP_Database.csv) mixed in with the yearly match files. This was
      caught when an early INFER_SCHEMA-based atp_matches table came back
      with unrelated columns (birthdate, height, coaches, etc.) alongside
      match columns. A sign that two different grains (one row per match
      vs. one row per player) were being merged into one table. Fixed by
      moving the file to its own players folder and building a
      separate players table (Step 3 below).
   ============================================================================ */

USE DATABASE tennis;
USE SCHEMA raw;


-- STEP 1: Create and load atp_matches
CREATE TABLE tennis.raw.atp_matches (
    tourney_id          VARCHAR,
    tourney_name        VARCHAR,
    surface             VARCHAR,
    draw_size           NUMBER(10,0),
    tourney_level       VARCHAR,
    indoor              VARCHAR,
    tourney_date        NUMBER(10,0),
    match_num           NUMBER(10,0),
    winner_id           VARCHAR,
    winner_seed         VARCHAR,   -- holds 'Q'/'ALT'/'WC'/'LL' as well as numeric seeds
    winner_entry        VARCHAR,
    winner_name         VARCHAR,
    winner_hand         VARCHAR,
    winner_ht           NUMBER(10,0),
    winner_ioc          VARCHAR,
    winner_age          FLOAT,    
    winner_rank         NUMBER(10,0),   -- widened: inference capped this too low for historical data
    winner_rank_points  NUMBER(10,0),
    loser_id            VARCHAR,
    loser_seed          VARCHAR,   -- holds 'Q'/'ALT'/'WC'/'LL' as well as numeric seeds
    loser_entry         VARCHAR,
    loser_name          VARCHAR,
    loser_hand          VARCHAR,
    loser_ht            NUMBER(10,0),
    loser_ioc           VARCHAR,
    loser_age           FLOAT,
    loser_rank          NUMBER(10,0),
    loser_rank_points   NUMBER(10,0),
    score               VARCHAR,
    best_of             NUMBER(10,0),
    round               VARCHAR,
    minutes             NUMBER(10,0),
    w_ace               NUMBER(10,0),
    w_df                NUMBER(10,0),
    w_svpt              NUMBER(10,0),
    w_1stIn             NUMBER(10,0),
    w_1stWon            NUMBER(10,0),  
    w_2ndWon            NUMBER(10,0),
    w_SvGms             NUMBER(10,0),
    w_bpSaved           NUMBER(10,0),
    w_bpFaced           NUMBER(10,0),
    l_ace               NUMBER(10,0),
    l_df                NUMBER(10,0),
    l_svpt              NUMBER(10,0),
    l_1stIn             NUMBER(10,0),
    l_1stWon            NUMBER(10,0),
    l_2ndWon            NUMBER(10,0),
    l_SvGms             NUMBER(10,0),
    l_bpSaved           NUMBER(10,0),
    l_bpFaced           NUMBER(10,0)
);

/*-- Intial inference method
CREATE TABLE tennis.raw.atp_matches
USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION => '@csv_stage/atp_tour/',
      FILE_FORMAT => 'tennis.raw.csv_infer_format'
    )
  )
); */

-- ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE handles the 1967 file (49 cols vs 50)
-- by loading it with NULLs in the missing stat columns, since the indoor stat
-- wasn't tracked. See note #3 above.
COPY INTO tennis.raw.atp_matches
FROM @csv_stage/atp_tour/
FILE_FORMAT = (FORMAT_NAME = 'tennis.raw.csv_infer_format', ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';


-- STEP 2: Create and load wta_matches
CREATE TABLE tennis.raw.wta_matches (
    tourney_id          VARCHAR,
    tourney_name        VARCHAR,
    surface             VARCHAR,
    draw_size           NUMBER(10,0),
    tourney_level       VARCHAR,
    indoor              VARCHAR,
    tourney_date        NUMBER(10,0),
    match_num           NUMBER(10,0),
    winner_id           VARCHAR,
    winner_seed         VARCHAR,   -- holds 'Q'/'ALT'/'WC'/'LL' as well as numeric seeds
    winner_entry        VARCHAR,
    winner_name         VARCHAR,
    winner_hand         VARCHAR,
    winner_ht           NUMBER(10,0),
    winner_ioc          VARCHAR,
    winner_age          FLOAT,    -- float to maintain source data
    winner_rank         NUMBER(10,0),   -- widened: inference capped this too low for historical data
    winner_rank_points  NUMBER(10,0),
    loser_id            VARCHAR,
    loser_seed          VARCHAR,   -- holds 'Q'/'ALT'/'WC'/'LL' as well as numeric seeds
    loser_entry         VARCHAR,
    loser_name          VARCHAR,
    loser_hand          VARCHAR,
    loser_ht            NUMBER (10,0),
    loser_ioc           VARCHAR,
    loser_age           FLOAT,
    loser_rank          NUMBER(10,0),
    loser_rank_points   NUMBER(10,0),
    score               VARCHAR,
    best_of             NUMBER(10,0),
    round               VARCHAR,
    minutes             NUMBER(10,0),
    w_ace               NUMBER(10,0),
    w_df                NUMBER(10,0),
    w_svpt              NUMBER(10,0),
    w_1stIn             NUMBER(10,0),
    w_1stWon            NUMBER(10,0),  -- flagged for a future dbt test: a raw value of 28 and 351 was
                                       -- observed, which seems unlikely for a single match
                                       -- (typical match totals run ~60-150 points). Worth a
                                       -- w_1stWon <= w_svpt sanity test once in dbt.
    w_2ndWon            NUMBER(10,0),
    w_SvGms             NUMBER(10,0),
    w_bpSaved           NUMBER(10,0),
    w_bpFaced           NUMBER(10,0),
    l_ace               NUMBER(10,0),
    l_df                NUMBER(10,0),
    l_svpt              NUMBER(10,0),
    l_1stIn             NUMBER(10,0),
    l_1stWon            NUMBER(10,0),
    l_2ndWon            NUMBER(10,0),
    l_SvGms             NUMBER(10,0),
    l_bpSaved           NUMBER(10,0),
    l_bpFaced           NUMBER(10,0)
);

-- ON_ERROR = 'CONTINUE' because 2026_wta.csv (current, in-progress season) has
-- at least one malformed row with a missing column value. See note #4 above.
-- TODO: isolate the exact bad row with a local Python script and decide 
-- whether to hand-fix or permanently exclude it.
COPY INTO tennis.raw.wta_matches
FROM @csv_stage/wta_tour/
FILE_FORMAT = (FORMAT_NAME = 'tennis.raw.csv_infer_format')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';


-- STEP 3: Create and load players
CREATE TABLE tennis.raw.players(
    id         VARCHAR,
    player     VARCHAR,
    atpname    VARCHAR,
    birthdate  NUMBER(10,0),
    weight     NUMBER (10,0),
    height     FLOAT,
    turnedpro  NUMBER (10,0), -- year turned pro; used to derive years-as-pro downstream if needed
    birthplace VARCHAR,
    coaches    VARCHAR,
    hand       VARCHAR,
    backhand   VARCHAR,
    ioc        VARCHAR
);

COPY INTO tennis.raw.players
FROM @csv_stage/players/
FILE_FORMAT = (FORMAT_NAME = 'tennis.raw.csv_infer_format')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'CONTINUE';

/*  STEP 4: Verify the loads
   COPY_HISTORY shows per-file load status, row counts, and the first error
   hit in any partially-loaded file -- the fastest way to confirm nothing
   unexpected slipped through.
*/

SELECT * FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME=>'TENNIS.RAW.ATP_MATCHES',
  START_TIME=>DATEADD(hours, -48, CURRENT_TIMESTAMP())
))
ORDER BY LAST_LOAD_TIME DESC;

SELECT * FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME=>'TENNIS.RAW.WTA_MATCHES',
  START_TIME=>DATEADD(hours, -48, CURRENT_TIMESTAMP())
))
ORDER BY LAST_LOAD_TIME DESC;

-- Spot check that data was read in correctly
SELECT COUNT(*) AS atp_row_count FROM tennis.raw.atp_matches;
SELECT COUNT(*) AS wta_row_count FROM tennis.raw.wta_matches;
SELECT COUNT(*) AS players_row_count FROM tennis.raw.players;

-- Confirms how far back detailed stat tracking goes
SELECT tourney_date, COUNT(*) AS matches, COUNT(w_ace) AS matches_with_ace_data
FROM tennis.raw.atp_matches
GROUP BY tourney_date
ORDER BY tourney_date
LIMIT 30;

SELECT tourney_date, COUNT(*) AS matches, COUNT(w_1stWon) AS matches_with_1stServe_data
FROM tennis.raw.wta_matches
GROUP BY tourney_date
ORDER BY tourney_date
LIMIT 30;
