
--      Create tables so we can sort through which ndc codes from rx_drug_events can be identifies, and which cant

INSERT INTO ndc_matches (ndc11, desc_long)
SELECT n.ndc11, n.desc_long FROM rx_drug_events rde INNER JOIN ndc2010 n ON rde.ndc11 = n.ndc11;

INSERT INTO ndc_nomatch (ndc11)
SELECT rde.ndc11 FROM ndc2010 n RIGHT JOIN rx_drug_events rde ON rde.ndc11 = n.ndc11 WHERE n.ndc11 IS NULL;

INSERT INTO ndc_matches (ndc11, desc_long)
SELECT n.ndc11, n.desc_long FROM rx_drug_events rde INNER JOIN ndc2012 n ON rde.ndc11 = n.ndc11;

INSERT INTO ndc_nomatch (ndc11)
SELECT rde.ndc11 FROM ndc2012 n RIGHT JOIN rx_drug_events rde ON rde.ndc11 = n.ndc11 WHERE n.ndc11 IS NULL;

--      Delete all duplicate entries so the ndc11 codes listed are distinct

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

SELECT COUNT(DISTINCT ndc11) FROM ndc_matches;

--      RESULT: 

SELECT COUNT(DISTINCT ndc11) FROM ndc_nomatch;

--      RESULT: 

ALTER TABLE ndc_matches DROP COLUMN id;
ALTER TABLE ndc_nomatch DROP COLUMN id;


--  Reconcile the remaining ndc codes that have not matched using the 2025 dataset.

INSERT INTO ndc_matches
SELECT nm.ndc11, n.package_description
FROM ndc_nomatch nm
INNER JOIN ndc2025_package n
ON nm.ndc11 = n.ndc_package11;

DELETE FROM ndc_nomatch nm
USING ndc_matches m
WHERE nm.ndc11 = m.ndc11;

SELECT COUNT(*) FROM ndc_matches;

--      RESULT: 144490

SELECT COUNT(*) FROM ndc_nomatch;

--      RESULT: 124073
