-- 02_insert_breeds.sql
-- Loads 10 cat breeds into the `breeds` table, based on the response retrieved
-- from The Cat API via Postman (see cat_breeds_api_response.json for the raw
-- response).
--
-- Safe to re-run:
--   * ON DUPLICATE KEY UPDATE updates existing breeds instead of duplicating them.
--   * wikipedia_url is intentionally NOT in the update list, so links added later
--     by 03_update_wikipedia_urls.sql are preserved on a re-import.
--   * The sync_log entry at the end uses counts calculated from the data, so it
--     stays accurate no matter how many times this file is run.
--
-- Requires MySQL 8.0.19+ (for the "AS new_row" alias syntax).

USE cats_catalog;

-- Count rows before the import, to calculate real numbers for the sync log
SET @before = (SELECT COUNT(*) FROM breeds);

INSERT INTO breeds (id, name, origin, temperament, life_span, description, wikipedia_url, synced_at)
VALUES (
    'abys', 'Abyssinian', 'Egypt',
    'Active, Energetic, Independent, Intelligent, Gentle, Curious, Playful',
    '14-17',
    'Medium-sized, elegant cat with a distinctive ticked coat pattern giving a wild appearance. Known for its athletic build, almond-shaped eyes, and highly active, curious personality.',
    NULL, NOW()
) AS new_row
ON DUPLICATE KEY UPDATE
    name=new_row.name, origin=new_row.origin, temperament=new_row.temperament,
    life_span=new_row.life_span, description=new_row.description,
    synced_at=new_row.synced_at;

INSERT INTO breeds (id, name, origin, temperament, life_span, description, wikipedia_url, synced_at)
VALUES (
    'aege', 'Aegean', 'Greece',
    'Affectionate, Social, Intelligent, Playful, Active, Adaptable',
    '9-12',
    'Medium-sized natural breed with a semi-longhaired coat, muscular build, and almond-shaped eyes. One of the oldest domesticated cat breeds, known for its love of water and fishing heritage.',
    NULL, NOW()
) AS new_row
ON DUPLICATE KEY UPDATE
    name=new_row.name, origin=new_row.origin, temperament=new_row.temperament,
    life_span=new_row.life_span, description=new_row.description,
    synced_at=new_row.synced_at;

INSERT INTO breeds (id, name, origin, temperament, life_span, description, wikipedia_url, synced_at)
VALUES (
    'bali', 'Balinese', 'United States',
    'Affectionate, Intelligent, Playful, Active, Social, Curious',
    '12-20',
    'Elegant, svelte cat with long silky coat and striking blue eyes. Essentially a longhaired Siamese with the same pointed coloration and athletic build.',
    NULL, NOW()
) AS new_row
ON DUPLICATE KEY UPDATE
    name=new_row.name, origin=new_row.origin, temperament=new_row.temperament,
    life_span=new_row.life_span, description=new_row.description,
    synced_at=new_row.synced_at;

INSERT INTO breeds (id, name, origin, temperament, life_span, description, wikipedia_url, synced_at)
VALUES (
    'braz', 'Brazilian Shorthair', 'Brazil',
    'Active, Playful, Intelligent, Affectionate, Social',
    '14-20',
    'Medium-sized, elegant cat with a muscular build and short, close-lying coat. Brazil''s only internationally recognized cat breed.',
    NULL, NOW()
) AS new_row
ON DUPLICATE KEY UPDATE
    name=new_row.name, origin=new_row.origin, temperament=new_row.temperament,
    life_span=new_row.life_span, description=new_row.description,
    synced_at=new_row.synced_at;

INSERT INTO breeds (id, name, origin, temperament, life_span, description, wikipedia_url, synced_at)
VALUES (
    'bslo', 'British Longhair', 'United Kingdom',
    'Affectionate, Easy Going, Independent, Intelligent, Loyal, Social, Calm',
    '12-15',
    'Large, round cat with plush long coat and characteristic cobby body. The longhaired version of the British Shorthair with the same gentle personality.',
    NULL, NOW()
) AS new_row
ON DUPLICATE KEY UPDATE
    name=new_row.name, origin=new_row.origin, temperament=new_row.temperament,
    life_span=new_row.life_span, description=new_row.description,
    synced_at=new_row.synced_at;

INSERT INTO breeds (id, name, origin, temperament, life_span, description, wikipedia_url, synced_at)
VALUES (
    'jbob', 'Japanese Bobtail', 'Japan',
    'Active, Agile, Clever, Easy Going, Intelligent, Lively, Loyal, Playful, Social',
    '14-16',
    'Medium-sized cat with distinctive pom-pom tail and elegant, slender build. Traditional Japanese breed.',
    NULL, NOW()
) AS new_row
ON DUPLICATE KEY UPDATE
    name=new_row.name, origin=new_row.origin, temperament=new_row.temperament,
    life_span=new_row.life_span, description=new_row.description,
    synced_at=new_row.synced_at;

INSERT INTO breeds (id, name, origin, temperament, life_span, description, wikipedia_url, synced_at)
VALUES (
    'mcoo', 'Maine Coon', 'United States',
    'Adaptable, Intelligent, Loving, Gentle, Independent, Playful, Friendly',
    '12-15',
    'Large to very large, muscular cat with long shaggy coat, tufted ears, and bushy tail. One of the largest domestic cat breeds.',
    NULL, NOW()
) AS new_row
ON DUPLICATE KEY UPDATE
    name=new_row.name, origin=new_row.origin, temperament=new_row.temperament,
    life_span=new_row.life_span, description=new_row.description,
    synced_at=new_row.synced_at;

INSERT INTO breeds (id, name, origin, temperament, life_span, description, wikipedia_url, synced_at)
VALUES (
    'sphy', 'Sphynx', 'Canada',
    'Loyal, Inquisitive, Friendly, Quiet, Gentle, Affectionate, Social',
    '12-16',
    'Medium-sized, hairless cat with wrinkled skin, large ears, and muscular body. Known for affectionate, attention-seeking personality.',
    NULL, NOW()
) AS new_row
ON DUPLICATE KEY UPDATE
    name=new_row.name, origin=new_row.origin, temperament=new_row.temperament,
    life_span=new_row.life_span, description=new_row.description,
    synced_at=new_row.synced_at;

INSERT INTO breeds (id, name, origin, temperament, life_span, description, wikipedia_url, synced_at)
VALUES (
    'tang', 'Turkish Angora', 'Turkey',
    'Affectionate, Agile, Clever, Gentle, Intelligent, Playful, Social, Athletic',
    '12-18',
    'Medium-sized, elegant cat with long silky coat and graceful build. One of the oldest natural cat breeds.',
    NULL, NOW()
) AS new_row
ON DUPLICATE KEY UPDATE
    name=new_row.name, origin=new_row.origin, temperament=new_row.temperament,
    life_span=new_row.life_span, description=new_row.description,
    synced_at=new_row.synced_at;

INSERT INTO breeds (id, name, origin, temperament, life_span, description, wikipedia_url, synced_at)
VALUES (
    'ycho', 'York Chocolate', 'United States',
    'Playful, Social, Intelligent, Curious, Friendly, Affectionate, Active',
    '13-15',
    'Large, semi-longhaired cat with rich chocolate or lavender coat. Farm cat origin with affectionate personality.',
    NULL, NOW()
) AS new_row
ON DUPLICATE KEY UPDATE
    name=new_row.name, origin=new_row.origin, temperament=new_row.temperament,
    life_span=new_row.life_span, description=new_row.description,
    synced_at=new_row.synced_at;

-- Log this import round with real counts:
-- new rows = rows after - rows before; the remaining breeds were updated.
SET @inserted = (SELECT COUNT(*) FROM breeds) - @before;

INSERT INTO sync_log (run_at, notes, records_inserted, records_updated)
VALUES (NOW(), 'Import via Postman - 10 breeds', @inserted, 10 - @inserted);
