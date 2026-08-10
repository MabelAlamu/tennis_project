# 🎾 Tennis Analytics Engineering Project

This project uses ATP and WTA tennis match data to build a structured, analysis-ready data model in Snowflake. I'm using it to practise data warehouse design, dimensional modelling, dbt transformations, data quality testing, and documentation, as part of my transition from **Data Analysis to Analytics Engineering**.

> **Current stage:** Snowflake setup and raw data load complete. The fact table grain has been defined and its design finalized. Next: building the transformation layer in dbt.


## Project Goals

I want to gain practical, hands-on experience with:

* Snowflake
* dbt
* SQL transformations
* Data warehouse architecture
* Dimensional modelling (grain, facts, dimensions)
* Data quality testing
* Data documentation
* Git and GitHub
* AI-assisted development workflows
* Building reusable, analysis-ready data models

This is primarily a **learning and portfolio project**, rather than a production application.


## Data Source

The project uses historical **ATP and WTA tennis match data** from Tennis My Life.

**Source:** [Tennis My Life – Tennis Match Database](https://stats.tennismylife.org/tennis-match-database)

The data contains information about tennis matches, players, tournaments, rankings, match results, and player performance statistics.

### Downloading the Raw Data

The raw files were downloaded locally using PowerShell and the Tennis My Life API:

```powershell
New-Item -ItemType Directory -Force -Path .\tml-data | Out-Null

Invoke-RestMethod -Uri 'https://stats.tennismylife.org/api/data-files' |
    Select-Object -ExpandProperty files |
    ForEach-Object {
        $outPath = Join-Path -Path '.\tml-data' -ChildPath $_.name
        $outDir = Split-Path -Path $outPath -Parent

        if (-not (Test-Path $outDir)) {
            New-Item -ItemType Directory -Force -Path $outDir | Out-Null
        }

        Invoke-WebRequest -Uri $_.url -OutFile $outPath
    }
```


## Snowflake Setup

* `01_setup_snowflake.sql` — creates the Snowflake warehouse, database, schema, file formats, and internal stage for the CSVs.
* `02_load_raw_csv.sql` — creates the raw tables and loads the CSVs into Snowflake.

Both scripts are commented throughout with the data quality issues encountered during loading and the reasoning behind each fix, a few examples: a player biography file discovered mixed in with the match files at the wrong grain, historical files with fewer columns than modern ones due to stats that weren't tracked yet, and column types Snowflake's schema inference guessed wrong from a limited sample. I've kept these decisions documented inline, since the reasoning is as much a part of this project as the final model.

At this stage, raw ATP, WTA, and player biographical data are loaded and available in Snowflake, providing the starting point for the dbt transformation layer.


## Data Modelling

### Grain

The grain of the fact table is **one player in one tennis match**.

Each row represents a single player's performance in a specific match. For a match between two players, there are therefore two records:

```text
Match 123
│
├── Player A → Win
└── Player B → Lose
```


## Fact Table

### `fact_player_match`

| Column                 | Description                                |
| ----------------------- | ------------------------------------------ |
| `match_id`              | Identifier for the tennis match            |
| `player_id`             | Foreign key identifying the player         |
| `tourney_id`            | Foreign key identifying the tournament     |
| `date_id`               | Foreign key identifying the match date     |
| `round`                 | Tournament round                           |
| `win_or_lose`           | Match result from the player's perspective |
| `player_rank_at_match`  | Player ranking at the time of the match    |
| `player_age_at_match`   | Player age at the time of the match        |
| `score`                 | Final match score (set by set)             |
| `duration`              | Match duration in minutes                  |
| `aces`                  | Number of aces                             |
| `double_faults`         | Number of double faults                    |
| `service_points`        | Number of service points                   |
| `first_serve_in`        | First serves successfully made             |
| `first_serve_won`       | First-serve points won                     |
| `second_serve_won`      | Second-serve points won                    |
| `service_games`         | Service games played                       |
| `break_points_saved`    | Break points saved                         |
| `break_points_faced`    | Break points faced                         |


## dbt

The next stage is building the transformation layer in dbt:

```text
Raw Data
   │
   ▼
Snowflake Raw Layer
   │
   ▼
dbt Staging Models
   │
   ▼
Intermediate Transformations
   │
   ▼
Fact & Dimension Models
   │
   ▼
Analysis-Ready Data
```


## Data Quality & Testing

**Status: Not yet implemented.** Planned: dbt generic tests (`unique`, `not_null`, `relationships`) on primary/foreign keys, plus custom tests for known issues already flagged in `02_load_raw_csv.sql` (e.g. a sanity check that `first_serve_won <= service_points`).


## Documentation

**Status: Not yet implemented.** Planned: dbt model and column documentation, generated docs site, and a written account of the key design decisions made in this project (grain selection, ATP/WTA integration approach, raw layer data quality handling).


## Tech Stack

| Technology              | Purpose                                     |
| ----------------------  | --------------------------------------------|
| **Snowflake**           | Cloud data warehouse                        |
| **dbt**                 | Data transformation and modelling           |
| **SQL**                 | Data transformation and querying            |
| **PowerShell**          | Downloading raw data                        |
| **Git & GitHub**        | Version control                             |
| **Claude**              | AI-assisted development and debugging       |


## Project Roadmap

### Completed

* [x] Identify and download ATP/WTA tennis data
* [x] Set up Snowflake warehouse, database, and schemas
* [x] Load raw CSV data into Snowflake, resolving data quality issues along the way
* [x] Define the grain of the fact table
* [x] Design the `fact_player_match` table

### In Progress

* [ ] Build `fact_player_match` using dbt

### Planned

* [ ] Build staging models
* [ ] Build dimension tables (`dim_player`, `dim_tournament`, `dim_date`)
* [ ] Add dbt data quality tests
* [ ] Add dbt model and column documentation
* [ ] Build additional analytical models/marts
* [ ] Explore dbt macros where appropriate
* [ ] Add CI/CD using GitHub Actions
* [ ] Connect the final models to a BI/visualisation tool
* [ ] Document lessons learned and design decisions


## Why I Built This Project

My background is in Data Analysis, which includes extraction, analysis, reporting, and visualisation. I'm now moving toward Analytics Engineering, and I wanted a project that would let me practise the skills behind building and maintaining the data layer that analysts and other data users actually work from, rather than just producing the final analysis.

This repository is both a learning project and a practical record of that transition, including the messier parts: data quality issues found and fixed, design decisions reconsidered, and the reasoning behind each one, documented as I went rather than cleaned up after the fact.
