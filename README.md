# Cat Breeds Catalog (The Cat API → MySQL, via Postman)

A hands-on portfolio project demonstrating **REST API consumption** and
**SQL**. It is intentionally done without automation code: the goal is to
understand every step of a data integration manually before automating it.

## Skills demonstrated

- Exploring a REST API in Postman, including header-based authentication
  (`x-api-key`) and safe credential handling with environment variables
- Reading a JSON response and modeling a relational table from it
- Creating a MySQL schema and tables (`CREATE DATABASE`, `CREATE TABLE`,
  primary keys, character set)
- Idempotent loads with upsert (`INSERT ... ON DUPLICATE KEY UPDATE`)
- Import traceability with a sync log whose counts are calculated, not typed
- Batch updates with `CASE WHEN`
- Cleaning free-text fields into numbers (`SUBSTRING_INDEX` + `CAST`)
- Validating the result after a data load

## The simulated problem

A technical implementation specialist often needs to **explore a partner's
API in Postman before any automation** — understanding endpoints, returned
fields, and authentication — and only then design how that data will flow
into the internal system. This project reproduces exactly that first stage:
exploring the API, understanding the JSON response, and manually loading
the data into a database via plain SQL.

## Requirements

- **MySQL 8.0.19 or later** — the `INSERT ... AS new_row` alias syntax used
  in `02_insert_breeds.sql` is not available in older versions
- **Postman**
- A free API key from [The Cat API](https://thecatapi.com/)

## Project files

- `cat_breeds_api_response.json` — the full raw response from
  `GET /v1/breeds`, saved from Postman, documenting exactly what the partner
  API returns
- `Cat Breeds Catalog.postman_collection.json` — exported Postman collection
  with the configured request. The API key is referenced as the
  `{{api_key}}` variable and is never stored in the file
- `01_create_database.sql` — creates the `cats_catalog` schema and the
  `breeds` / `sync_log` tables
- `02_insert_breeds.sql` — loads the 10 breeds and logs the import round
- `03_update_wikipedia_urls.sql` — enriches the data with Wikipedia links
- `04_analysis_queries.sql` — exploratory SQL queries over the data, plus
  validation queries to confirm the whole process worked

## Step-by-step

### 1. Get an API key and store it safely

Sign up at [thecatapi.com](https://thecatapi.com/) and generate a free API
key. This key is required on every request and identifies you to the
partner API — the same kind of credential you'd configure for any real
integration.

In Postman, create an **environment** (e.g. `Cat API`) with a variable
named `api_key` holding your key, and select that environment in the
dropdown at the top right. Keeping the key in an environment means it never
ends up in the exported collection — the same care you'd take with a real
client's credentials.

### 2. Call the GET endpoint to retrieve the JSON response

Import `Cat Breeds Catalog.postman_collection.json` into Postman, or build
the request yourself:

- Method: `GET`
- URL: `https://api.thecatapi.com/v1/breeds`
- **Headers** tab: `x-api-key` → `{{api_key}}`

Send it. The response is a JSON array of about 100 cat breeds, each with
fields like `id`, `name`, `origin`, `temperament`, `life_span`, and
`description`. The full raw response is saved in
`cat_breeds_api_response.json`, documenting the API exploration step before
any data modeling happened.

**Choosing the sample.** This project loads a hand-picked sample of 10 out
of the ~100 breeds returned — the first few in the list plus some that
caught my curiosity. Ten was enough to practice the manual workflow;
loading all of them by hand wouldn't scale, which is exactly what the
automation step in [Possible next steps](#possible-next-steps) would solve.

### 3. Create the `cats_catalog` schema

Assuming a MySQL server is already running, the first statement in
`01_create_database.sql` creates the schema that will hold this project's
data:

```sql
CREATE DATABASE IF NOT EXISTS cats_catalog
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cats_catalog;
```

### 4. Create the empty `breeds` table

Still in `01_create_database.sql`, the table that will hold each breed's
data, with columns matching the fields returned by the API:

```sql
CREATE TABLE IF NOT EXISTS breeds (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    origin VARCHAR(100),
    temperament VARCHAR(255),
    life_span VARCHAR(20),
    description TEXT,
    wikipedia_url VARCHAR(500),
    synced_at DATETIME NOT NULL
) ENGINE=InnoDB;
```

### 5. Create the empty `sync_log` table

Also in `01_create_database.sql`, a table to record each import round —
mirroring the observability a real integration pipeline needs, even though
this process is manual:

```sql
CREATE TABLE IF NOT EXISTS sync_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    run_at DATETIME NOT NULL,
    notes VARCHAR(500),
    records_inserted INT,
    records_updated INT
) ENGINE=InnoDB;
```

Run the full file once to execute steps 3-5 together:

```bash
mysql -u root -p < 01_create_database.sql
```

### 6. Run the insert queries for `breeds` and `sync_log`

`02_insert_breeds.sql` first counts the rows already in the table, then runs
one `INSERT ... ON DUPLICATE KEY UPDATE` statement per breed (built by
reading each entry from the Postman response), and finally logs the round
with real counts:

```sql
-- Count rows before the import, to calculate real numbers for the log
SET @before = (SELECT COUNT(*) FROM breeds);

INSERT INTO breeds (id, name, origin, temperament, life_span, description, wikipedia_url, synced_at)
VALUES (
    'abys', 'Abyssinian', 'Egypt',
    'Active, Energetic, Independent, Intelligent, Gentle, Curious, Playful',
    '14-17',
    'Medium-sized, elegant cat with a distinctive ticked coat pattern...',
    NULL, NOW()
) AS new_row
ON DUPLICATE KEY UPDATE
    name=new_row.name, origin=new_row.origin, temperament=new_row.temperament,
    life_span=new_row.life_span, description=new_row.description,
    synced_at=new_row.synced_at;

-- ... one INSERT per breed ...

-- New rows = rows after - rows before; the remaining breeds were updated
SET @inserted = (SELECT COUNT(*) FROM breeds) - @before;

INSERT INTO sync_log (run_at, notes, records_inserted, records_updated)
VALUES (NOW(), 'Import via Postman - 10 breeds', @inserted, 10 - @inserted);
```

```bash
mysql -u root -p cats_catalog < 02_insert_breeds.sql
```

Two details make this file safe to re-run:

- `wikipedia_url` is **not** in the `ON DUPLICATE KEY UPDATE` list, so a
  re-import refreshes the API fields without erasing the links added in
  step 7.
- The `sync_log` counts are calculated from the data: the first run logs
  10 inserted / 0 updated, and a re-run logs 0 inserted / 10 updated.

At this point, `wikipedia_url` is `NULL` for every row — it's filled in
next, in step 7.

### 7. Update the data with the Wikipedia links

Right after loading the raw data, Wikipedia reference links were added via
a single batch `UPDATE` in `03_update_wikipedia_urls.sql`:

```sql
UPDATE breeds
SET wikipedia_url = CASE id
    WHEN 'abys' THEN 'https://en.wikipedia.org/wiki/Abyssinian_(cat)'
    WHEN 'aege' THEN 'https://en.wikipedia.org/wiki/Aegean_cat'
    -- ... one WHEN per breed ...
END
WHERE id IN ('abys','aege', /* ... */ 'ycho');
```

Using `CASE WHEN` updates all 10 rows in a single statement, instead of
running 10 separate `UPDATE`s.

### 8. Perform data analysis

With the data fully loaded and enriched, `04_analysis_queries.sql` explores
and cleans it:

```sql
-- Breeds grouped by country of origin
SELECT origin, COUNT(*) AS total
FROM breeds
GROUP BY origin
ORDER BY total DESC;

-- Breeds with a given temperament trait
SELECT name, temperament FROM breeds WHERE temperament LIKE '%Active%';

-- Cleaning a text field into numbers: life_span ("14-17") -> min/max age
SELECT
    name,
    life_span,
    CAST(SUBSTRING_INDEX(life_span, '-', 1) AS UNSIGNED) AS min_age,
    CAST(SUBSTRING_INDEX(life_span, '-', -1) AS UNSIGNED) AS max_age
FROM breeds;

-- Overall average minimum/maximum life expectancy across all breeds
SELECT
    ROUND(AVG(CAST(SUBSTRING_INDEX(life_span, '-', 1) AS UNSIGNED)), 1) AS avg_min_age,
    ROUND(AVG(CAST(SUBSTRING_INDEX(life_span, '-', -1) AS UNSIGNED)), 1) AS avg_max_age
FROM breeds;

-- Average life expectancy per breed (midpoint of each breed's own range)
SELECT
    name,
    life_span,
    ROUND((CAST(SUBSTRING_INDEX(life_span, '-', 1) AS UNSIGNED) +
           CAST(SUBSTRING_INDEX(life_span, '-', -1) AS UNSIGNED)) / 2, 1) AS avg_life_expectancy
FROM breeds
ORDER BY avg_life_expectancy DESC;
```

This step matters because `life_span` arrives from the API as free text
(`"14-17"`), not a number — a common real-world data quality issue that has
to be handled before any meaningful calculation (like an average) is
possible.

### 9. Validate the final result

The same file, `04_analysis_queries.sql`, ends with a few checks to confirm
the whole process worked correctly:

```sql
-- Row count should be 10
SELECT COUNT(*) AS total_breeds FROM breeds;

-- No row should be missing a Wikipedia link
SELECT id, name, wikipedia_url FROM breeds WHERE wikipedia_url IS NULL;
-- (an empty result here means 03_update_wikipedia_urls.sql covered every row)

-- Spot-check a few rows
SELECT id, name, wikipedia_url FROM breeds LIMIT 5;
```

## Technical decisions

- **Postman instead of a script**: chosen for this first project to focus
  on understanding the API (authentication via `x-api-key`, JSON structure)
  before automating anything.
- **API key in a Postman environment**: the collection references
  `{{api_key}}`, so it can be shared publicly without exposing credentials.
- **MySQL**: a database already familiar from a previous course, keeping
  the focus on learning API + SQL rather than a new DBMS at the same time.
- **`ON DUPLICATE KEY UPDATE`**: even with manual inserts, this syntax
  prevents duplicating a breed if the same `INSERT` is run again. It uses
  the `AS new_row` alias syntax instead of the older `VALUES()` function,
  which is deprecated in recent MySQL versions.
- **Preserving enriched data on re-import**: `wikipedia_url` is left out of
  the update list, so refreshing data from the API never overwrites fields
  that were added afterwards.
- **`sync_log` table with calculated counts**: documenting each import
  round, even without automation, mirrors a real implementation practice —
  traceability of every data sync. Counting rows before and after the
  import keeps the log accurate on every run, instead of relying on
  hardcoded numbers.
- **Handling "dirty" data**: `life_span` comes from the API as text
  (`"14-17"`), so `SUBSTRING_INDEX` + `CAST` were used to convert it into
  usable numbers before analysis.
- **Enrichment before analysis**: Wikipedia links were added (step 7) right
  after loading the raw data, before exploring and analyzing it (step 8) —
  the actual order this project was carried out in.
- **Batch `UPDATE` with `CASE WHEN`**: used to add Wikipedia URLs to all 10
  rows in a single statement, instead of 10 separate `UPDATE`s.
- **Validation as a final step**: closing the process with checks (row
  count, no missing links) instead of assuming the update worked.

## Possible next steps

- Automate the API-to-database transfer with a Python script, using this
  project's manual process and Postman collection as the reference — which
  would also make it practical to load all ~100 breeds.
- Add or switch to a key-less API (e.g. iNaturalist) to compare
  authentication flows.
- Build a small dashboard on top of the collected data.
