-- 03_update_wikipedia_urls.sql
-- Enriches the breeds table with Wikipedia reference links, added after the
-- initial import. Uses a single UPDATE with CASE WHEN to update all 10 rows
-- in one statement instead of 10 separate UPDATEs.

USE cats_catalog;

UPDATE breeds
SET wikipedia_url = CASE id
    WHEN 'abys' THEN 'https://en.wikipedia.org/wiki/Abyssinian_(cat)'
    WHEN 'aege' THEN 'https://en.wikipedia.org/wiki/Aegean_cat'
    WHEN 'bali' THEN 'https://en.wikipedia.org/wiki/Balinese_cat'
    WHEN 'braz' THEN 'https://en.wikipedia.org/wiki/Brazilian_Shorthair'
    WHEN 'bslo' THEN 'https://en.wikipedia.org/wiki/British_Longhair'
    WHEN 'jbob' THEN 'https://en.wikipedia.org/wiki/Japanese_Bobtail'
    WHEN 'mcoo' THEN 'https://en.wikipedia.org/wiki/Maine_Coon'
    WHEN 'sphy' THEN 'https://en.wikipedia.org/wiki/Sphynx_cat'
    WHEN 'tang' THEN 'https://en.wikipedia.org/wiki/Turkish_Angora'
    WHEN 'ycho' THEN 'https://en.wikipedia.org/wiki/York_Chocolate'
END
WHERE id IN ('abys','aege','bali','braz','bslo','jbob','mcoo','sphy','tang','ycho');
