# World Cup Database & Query Suite

A relational tournament database powered by PostgreSQL, featuring an automated Bash ETL ingestion script and an analytical query engine to aggregate match statistics across the 2014 and 2018 FIFA World Cups.

---

## Architecture & Relational Schema

The database model tracks participating international teams and match outcomes using normalized foreign key constraints:

* **`teams`**: Stores competing national squads with a `UNIQUE(name)` constraint and auto-incrementing `team_id` primary key.
* **`games`**: Records individual match statistics with dual foreign keys referencing the `teams` table:
  * `winner_id` $\rightarrow$ `teams(team_id)`
  * `opponent_id` $\rightarrow$ `teams(team_id)`
  * Includes `year`, `round`, `winner_goals`, and `opponent_goals`.

---

## Ingestion Pipeline (`insert_data.sh`)

An idempotent Bash script automating the extraction, transformation, and loading (ETL) of raw match data from `games.csv` into PostgreSQL:

* **Environment Switching**: Supports production and staging targets via CLI flag evaluation (`$1 == "test"`).
* **Two-Pass Ingestion**:
  * **Pass 1 (Teams)**: Reads all `WINNER` and `OPPONENT` entries, dynamically checking the `teams` table to insert unique records without duplicates.
  * **Pass 2 (Games)**: Resolves surrogate foreign keys (`winner_id`, `opponent_id`) on the fly using subshell queries and inserts game records alongside final scores.
* **Stream Optimization**: Disables psql decorative wrappers using `--no-align` and `-t` (tuples-only) flags for shell-safe variable parsing.

---

## Analytical Query Engine (`queries.sh`)

A dedicated reporting script computing tournament metrics directly via non-aligned SQL subshells:

* **Aggregations & Rounding**: Computes cumulative goals (`SUM`) and scoring distributions (`ROUND(AVG(...), 2)`).
* **Subquery Unions**: Identifies single-game high scores using derived-table unions across winner and opponent columns (`MAX(goals) FROM (... UNION ALL ...)`).
* **Relational Joins**: Correlates tournament champions and finalists by performing multi-table inner joins between `teams` and `games` filtering on championship rounds (`round = 'Final'`).
* **Set Operations & Subqueries**: Resolves stage participants using uncorrelated subqueries (`WHERE team_id IN (...)`) combined with `UNION ALL`.
* **String Pattern Matching**: Filters teams using wildcard prefix expressions (`LIKE 'Co%'`).
