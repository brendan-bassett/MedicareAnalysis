
-- --------------------------------------------------------------------------------------------------------------------
--  Identify the distinct NDC codes that are used in the rx_drug_events table
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ndc_desynpuf;
CREATE TABLE ndc_desynpuf (
    ndc11 VARCHAR,
    matched BOOLEAN,
    desc_long VARCHAR
);

INSERT INTO ndc_desynpuf (ndc11, matched, desc_long)
SELECT ndc11, False, NULL FROM rx_drug_events rde;

-- Remove all the duplicates so each ndc value is distinct

ALTER TABLE ndc_desynpuf ADD COLUMN id SERIAL;

DELETE FROM ndc_desynpuf
WHERE id IN
    (SELECT id
    FROM 
        (SELECT id,
         ROW_NUMBER() OVER( PARTITION BY ndc11 ORDER BY  id ) AS row_num
        FROM ndc_desynpuf ) t
        WHERE t.row_num > 1 );


SELECT COUNT(*) FROM ndc_desynpuf;

--      RESULT: 268563


-- --------------------------------------------------------------------------------------------------------------------
--  Identify the distinct ICD9 codes that are used in the deSynPUF dataset
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS icd_desynpuf;
CREATE TABLE icd_desynpuf (
    icd9 VARCHAR,
    matched BOOLEAN,
    desc_long VARCHAR
);

INSERT INTO ndc_desynpuf (ndc11, matched, desc_long)
SELECT ndc11, False, NULL FROM rx_drug_events rde;

-- Remove all the duplicates so each ndc value is distinct

ALTER TABLE ndc_desynpuf ADD COLUMN id SERIAL;

DELETE FROM ndc_desynpuf
WHERE id IN
    (SELECT id
    FROM 
        (SELECT id,
         ROW_NUMBER() OVER( PARTITION BY ndc11 ORDER BY  id ) AS row_num
        FROM ndc_desynpuf ) t
        WHERE t.row_num > 1 );


SELECT COUNT(*) FROM ndc_desynpuf;

--      RESULT: 268563
