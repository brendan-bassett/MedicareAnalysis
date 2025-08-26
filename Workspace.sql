
/*

--      Create tables so we can sort through which ndc codes from rx_drug_events can be identifies, and which cant

CREATE TABLE ndc_matches (
    ndc11 VARCHAR,
    desc_long VARCHAR
);

CREATE TABLE ndc_nomatch (
    ndc11 VARCHAR
);


INSERT INTO ndc_matches (ndc11, desc_long)
SELECT n.ndc11, n.desc_long FROM rx_drug_events rde INNER JOIN ndc2010 n ON rde.ndc11 = n.ndc11;

INSERT INTO ndc_nomatch (ndc11)
SELECT rde.ndc11 FROM ndc2010 n RIGHT JOIN rx_drug_events rde ON rde.ndc11 = n.ndc11 WHERE n.ndc11 IS NULL;


--      Confirm that the ndc codes have been properly sorted

SELECT COUNT(DISTINCT ndc11) FROM rx_drug_events;

--      RESULT: 268563

SELECT COUNT(DISTINCT ndc11) FROM ndc_matches;

--      RESULT: 142467

SELECT COUNT(DISTINCT ndc11) FROM ndc_nomatch;

--      RESULT: 126096


--      Delete all duplicate entries so the ndc11 codes listed are distinct

--      First we create an id so we can identify each row.

ALTER TABLE ndc_matches ADD COLUMN id SERIAL;
ALTER TABLE ndc_nomatch ADD COLUMN id SERIAL;


--      Then delete the duplicates by joining the table with itself and comparing the two versions, deleting along the way.

DELETE FROM ndc_matches a
    USING ndc_matches b
WHERE a.id < b.id
    AND a.ndc11 = b.ndc11;

*/

DELETE FROM ndc_nomatch a
    USING ndc_nomatch b
WHERE a.id < b.id
    AND a.ndc11 = b.ndc11;
