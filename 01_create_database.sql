-- 01_create_database.sql
-- Creates the database and tables for the Cat Breeds Catalog project.

CREATE DATABASE IF NOT EXISTS cats_catalog
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cats_catalog;

CREATE TABLE IF NOT EXISTS breeds (
    id VARCHAR(20) PRIMARY KEY,          -- breed id from The Cat API (e.g. "abys")
    name VARCHAR(100) NOT NULL,          -- breed name (e.g. "Abyssinian")
    origin VARCHAR(100),                 -- country of origin
    temperament VARCHAR(255),            -- e.g. "Active, Energetic, Independent"
    life_span VARCHAR(20),               -- e.g. "14-17" (free text, as returned by the API)
    description TEXT,
    wikipedia_url VARCHAR(500),          -- added later by 03_update_wikipedia_urls.sql
    synced_at DATETIME NOT NULL          -- when this record was inserted/updated
) ENGINE=InnoDB;

-- Logs each import round. Even though this project uses a manual process
-- (via Postman), 02_insert_breeds.sql writes one row here at the end of every
-- run, with insert/update counts calculated from the data itself -- mirroring
-- the observability a real integration pipeline needs.
CREATE TABLE IF NOT EXISTS sync_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    run_at DATETIME NOT NULL,
    notes VARCHAR(500),
    records_inserted INT,
    records_updated INT
) ENGINE=InnoDB;
