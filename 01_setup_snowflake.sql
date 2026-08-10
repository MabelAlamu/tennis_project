/* ============================================================================
    01_setup_snowflake.sql
    Purpose: One-time setup of the snowflake objects this project depends on. 
    They are warehouse, database, schema, file formats, and the internal stage
    CSVs get uploaded into before loading
============================================================================*/

-- STEP 1: Create WH, DB and Schema

CREATE WAREHOUSE tennis_wh;
CREATE DATABASE tennis;
CREATE SCHEMA tennis.raw;

/* STEP 2: File formats
   Two formats are needed: one for the PUT/COPY load itself, and a separate
   one for INFER_SCHEMA, which requires PARSE_HEADER = TRUE to read column
   names off the CSV header row.*/

CREATE FILE FORMAT tennis.raw.csv_format
  TYPE = 'CSV'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('', 'NA', 'NULL');

CREATE FILE FORMAT tennis.raw.csv_infer_format
  TYPE = 'CSV'
  SKIP_HEADER = 0
  PARSE_HEADER = TRUE
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';


/* STEP 3: Internal stage
   Landing zone for CSVs uploaded from the local machine via PUT (see 
   below instructions / PUT commands run via SnowSQL).*/

CREATE STAGE tennis.raw.csv_stage
  FILE_FORMAT = tennis.raw.csv_format;

/* STEP 4: Upload local CSVs to the stage
   Run from SnowSQL, not the Snowsight web worksheet. PUT is a client-side
   command that reads from the local filesystem, which the web UI has no
   access to.
 
   Install SnowSQL: docs.snowflake.com/en/user-guide/snowsql-install-config
   Connect:         snowsql -a <your_account_identifier> -u <your_username>
 
   Then, inside the SnowSQL session:
   ---------------------------------------------------------------------------- */
 
-- USE DATABASE tennis;
-- USE SCHEMA raw;
-- PUT file://C:/Users/malamu/tennis_project/tml-data/atp_tour/*.csv @csv_stage/atp_tour/ AUTO_COMPRESS=TRUE;
-- PUT file://C:/Users/malamu/tennis_project/tml-data/wta_tour/*.csv @csv_stage/wta_tour/ AUTO_COMPRESS=TRUE;
-- PUT file://C:/Users/malamu/tennis_project/tml-data/players/*.csv @csv_stage/players/ AUTO_COMPRESS=TRUE;
 
-- Verify the files landed:
-- LIST @tennis.raw.csv_stage;
