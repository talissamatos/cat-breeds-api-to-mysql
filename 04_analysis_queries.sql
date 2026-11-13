-- 04_analysis_queries.sql
-- Exploratory SQL queries used to analyze the imported breed data, followed
-- by a final validation check of the full dataset.

USE cats_catalog;

-- 1) Breeds grouped by country of origin
SELECT origin, COUNT(*) AS total
FROM breeds
GROUP BY origin
ORDER BY total DESC;

-- 2) Breeds with a given temperament trait
SELECT name, temperament
FROM breeds
WHERE temperament LIKE '%Active%';

-- 3) Cleaning a text field into numbers: life_span ("14-17") -> min/max age
SELECT
    name,
    life_span,
    CAST(SUBSTRING_INDEX(life_span, '-', 1) AS UNSIGNED) AS min_age,
    CAST(SUBSTRING_INDEX(life_span, '-', -1) AS UNSIGNED) AS max_age
FROM breeds;

-- 4) Overall average minimum/maximum life expectancy across all breeds
SELECT
    ROUND(AVG(CAST(SUBSTRING_INDEX(life_span, '-', 1) AS UNSIGNED)), 1) AS avg_min_age,
    ROUND(AVG(CAST(SUBSTRING_INDEX(life_span, '-', -1) AS UNSIGNED)), 1) AS avg_max_age
FROM breeds;

-- 5) Average life expectancy per breed (midpoint of each breed's own range)
SELECT
    name,
    life_span,
    ROUND((CAST(SUBSTRING_INDEX(life_span, '-', 1) AS UNSIGNED) +
           CAST(SUBSTRING_INDEX(life_span, '-', -1) AS UNSIGNED)) / 2, 1) AS avg_life_expectancy
FROM breeds
ORDER BY avg_life_expectancy DESC;

-- Validation: confirm the full process worked as expected
-- 6) Row count should be 10
SELECT COUNT(*) AS total_breeds FROM breeds;

-- 7) No row should be missing a Wikipedia link
SELECT id, name, wikipedia_url
FROM breeds
WHERE wikipedia_url IS NULL;
-- (an empty result here means 03_update_wikipedia_urls.sql covered every row)

-- 8) Spot-check a few rows
SELECT id, name, wikipedia_url FROM breeds LIMIT 5;
