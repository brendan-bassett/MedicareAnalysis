


ALTER TABLE ndc_matches ADD COLUMN id SERIAL;
ALTER TABLE ndc_nomatch ADD COLUMN id SERIAL;

DELETE FROM ndc_matches
WHERE id IN
    (SELECT id
    FROM 
        (SELECT id,
         ROW_NUMBER() OVER( PARTITION BY ndc11 ORDER BY  id ) AS row_num
        FROM ndc_matches ) t
        WHERE t.row_num > 1 );

DELETE FROM ndc_nomatch
WHERE id IN
    (SELECT id
    FROM 
        (SELECT id,
         ROW_NUMBER() OVER( PARTITION BY ndc11 ORDER BY  id ) AS row_num
        FROM ndc_nomatch ) t
        WHERE t.row_num > 1 );

ALTER TABLE ndc_matches DROP COLUMN id;
ALTER TABLE ndc_nomatch DROP COLUMN id;

SELECT COUNT(DISTINCT ndc11) FROM ndc_matches;

--      RESULT: 154408

SELECT COUNT(DISTINCT ndc11) FROM ndc_nomatch;

--      RESULT: 138052

--  Reconcile the remaining ndc codes that have not matched, using the 2025 dataset.
-- --------------------------------------------------------------------------------------------------------------------

INSERT INTO ndc_matches
SELECT nm.ndc11, n.package_description
FROM ndc_nomatch nm
INNER JOIN ndc2025_package n
ON nm.ndc11 = n.ndc_package11;

DELETE FROM ndc_nomatch nm
USING ndc_matches m
WHERE nm.ndc11 = m.ndc11;

SELECT COUNT(*) FROM ndc_matches;

--  RESULT: 156624

SELECT COUNT(*) FROM ndc_nomatch;

--  RESULT: 112728

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Run cleanup of dead tuples & maximize efficiency
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

VACUUM FULL ANALYZE;