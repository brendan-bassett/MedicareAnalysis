
-- --------------------------------------------------------------------------------------------------------------------
--  Collect & Identify the distinct NDC codes that are used in the rx_drug_events table
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
    description VARCHAR
);

INSERT INTO icd_desynpuf (icd9, matched, description)
SELECT cc.icd9_dgns_cd_1, False, NULL 
    FROM carrier_claims cc;

-- Remove all the duplicates so each ndc value is distinct

ALTER TABLE icd_desynpuf ADD COLUMN id SERIAL;

DELETE FROM icd_desynpuf
WHERE id 
    IN (SELECT id
        FROM 
            (SELECT id, 
                ROW_NUMBER() 
                    OVER( PARTITION BY icd9 ORDER BY  id ) 
                    AS row_num
            FROM icd_desynpuf ) t
            WHERE t.row_num > 1 );


SELECT COUNT(*) FROM icd_desynpuf;

--      RESULT: 

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Beneficiary Summary ID to DeSynPUF dataset
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------


--      List and count every hcpcs code listed in outpatient_claims that does not correspond to an etry in the hcpcs17 table

SELECT oc.hcpcs_cd_1, COUNT(*) FROM outpatient_claims oc LEFT JOIN hcpcs17 h ON oc.hcpcs_cd_1 = h.hcpc WHERE h.hcpc IS NULL GROUP BY oc.hcpcs_cd_1;

--      That's a lot of entries that do not occur in hcpcs 17

--      Show all the hcpcs codes from hcpcs17 table that DO NOT appear in the cms_rvu table

SELECT h.hcpc, h.desc_long FROM hcpcs17 h LEFT JOIN cms_rvu_2010 c ON h.hcpc = c.hcpcs WHERE c.hcpcs IS NULL GROUP BY h.hcpc, h.desc_long;

--      Count how many entries in the hcpcs17 table DO NOT appear in the cms_rvu

SELECT COUNT(*) FROM hcpcs17 h LEFT JOIN cms_rvu_2010 c ON h.hcpc = c.hcpcs WHERE c.hcpcs IS NULL;

--      RESULT: 3767

--      Show all the hcpcs codes from hcpcs17 table that do appear in the cms_rvu table

SELECT h.hcpc, h.desc_long FROM hcpcs17 h INNER JOIN cms_rvu_2010 c ON h.hcpc = c.hcpcs GROUP BY h.hcpc, h.desc_long;

--      Count how many entries in the hcpcs17 table do appear in the cms_rvu

SELECT COUNT(*) FROM hcpcs17 h INNER JOIN cms_rvu_2010 c ON h.hcpc = c.hcpcs;

--      RESULT: 2775

--      There is a lot of overlap between the hcpcs17 list of hcpcs codes, but it doesnt cover all the codes present 
--      in the Medicare DeSynPUF dataset.

--      Show and count each hcpcs code from outpatient claims that does not appear in cms_rvu

SELECT c.hcpcs, c.description, COUNT(*) FROM outpatient_claims oc RIGHT JOIN cms_rvu_2010 c ON oc.hcpcs_cd_1 = c.hcpcs WHERE c.hcpcs IS NULL GROUP BY c.hcpcs, c.description;

--      RESULT: -- no rows --

--      The cms_rvu table has hcpcs descriptions for every code in the Medicare DeSynPUF dataset

--      Just to double-check. Let's count the number of hcpcs codes in the outpatient claims that do not appear in the cms_rvu

SELECT COUNT(*) FROM outpatient_claims oc RIGHT JOIN cms_rvu_2010 c ON oc.hcpcs_cd_1 = c.hcpcs WHERE c.hcpcs IS NULL;

--      RESULT: 0


--      --------------------------------------------

--      Now the cms_rvu dataset may be comprehensive, but the descriptions are short and not as easy to understand
--      as those in the hcpcs17 data. We should combine the two datasets.


--      Populate a new hcpcs table with the descriptions from hcpcs17

CREATE TABLE hcpcs (
    hcpcs VARCHAR(5) UNIQUE,
    desc_short VARCHAR,
    desc_long VARCHAR
);

INSERT INTO hcpcs (hcpcs, desc_short, desc_long)
SELECT h.hcpc, h.desc_short, h.desc_long
FROM hcpcs17 h;


--      Add any additional hcpcs codes and descriptions from cms_rvu that are not already in the description list

INSERT INTO hcpcs (hcpcs, desc_short, desc_long)
SELECT cr.hcpcs, cr.description, cr.description
FROM cms_rvu_2010 cr
ON CONFLICT (hcpcs)
DO NOTHING;

--      Get rid of the old hcpcs17 table. It doesnt have any other information we will need.

DROP TABLE hcpcs17;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Beneficiary Summary ID to DeSynPUF dataset
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

--      Relationships from desynpuf_id to multiple beneficiary summary tables from outpatient_claims and similar are preventing
--      Power BI from creating other relationships. The solution here is to create a new beneficiary summary id that is unique to
--      each year's patient beneficiary summary.


-- Create unique Beneficiary Summary ID for each entry in Beneficiary Summaries
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE beneficiary_summary_2008 DROP COLUMN IF EXISTS primary_key;
ALTER TABLE beneficiary_summary_2008 ADD COLUMN bs_id INTEGER;

CREATE SEQUENCE bs_id_seq
INCREMENT 1
START 1
OWNED BY beneficiary_summary_2008.bs_id;

UPDATE beneficiary_summary_2008
SET bs_id = nextval('bs_id_seq');

SELECT desynpuf_id, bs_id FROM beneficiary_summary_2008 ORDER BY bs_id LIMIT 20;

ALTER TABLE beneficiary_summary_2008 ADD PRIMARY KEY (bs_id);

-- --------------------------

ALTER TABLE beneficiary_summary_2009 DROP COLUMN IF EXISTS primary_key;
ALTER TABLE beneficiary_summary_2009 ADD COLUMN bs_id INTEGER;

ALTER SEQUENCE bs_id_seq OWNED BY beneficiary_summary_2009.bs_id;

UPDATE beneficiary_summary_2009
SET bs_id = nextval('bs_id_seq');

ALTER TABLE beneficiary_summary_2009 ADD PRIMARY KEY (bs_id);

SELECT desynpuf_id, bs_id FROM beneficiary_summary_2009 ORDER BY bs_id LIMIT 20;

-- --------------------------

ALTER TABLE beneficiary_summary_2010 DROP COLUMN IF EXISTS primary_key;
ALTER TABLE beneficiary_summary_2010 ADD COLUMN bs_id INTEGER;

ALTER SEQUENCE bs_id_seq OWNED BY beneficiary_summary_2010.bs_id;

UPDATE beneficiary_summary_2010
SET bs_id = nextval('bs_id_seq');

ALTER TABLE beneficiary_summary_2010 ADD PRIMARY KEY (bs_id);

SELECT desynpuf_id, bs_id FROM beneficiary_summary_2010 ORDER BY bs_id LIMIT 20;

-- --------------------------

DROP SEQUENCE IF EXISTS bs_id_seq;


-- Add the Beneficiary Summary ID for each other table in the DeSynPUF
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE rx_drug_events ADD COLUMN bs_id INTEGER;

UPDATE rx_drug_events
SET bs_id = bs.bs_id
FROM beneficiary_summary_2008 bs
WHERE DATE_PART('year', srvc_dt) = 2008.0
AND rx_drug_events.desynpuf_id = bs.desynpuf_id;

UPDATE rx_drug_events
SET bs_id = bs.bs_id
FROM beneficiary_summary_2009 bs
WHERE DATE_PART('year', srvc_dt) = 2009.0
AND rx_drug_events.desynpuf_id = bs.desynpuf_id;

UPDATE rx_drug_events
SET bs_id = bs.bs_id
FROM beneficiary_summary_2010 bs
WHERE DATE_PART('year', srvc_dt) = 2010.0
AND rx_drug_events.desynpuf_id = bs.desynpuf_id;

-- --------------------------

ALTER TABLE inpatient_claims ADD COLUMN bs_id INTEGER;

UPDATE inpatient_claims
SET bs_id = bs.bs_id
FROM beneficiary_summary_2008 bs
WHERE DATE_PART('year', clm_from_dt) = 2008.0
AND inpatient_claims.desynpuf_id = bs.desynpuf_id;

UPDATE inpatient_claims
SET bs_id = bs.bs_id
FROM beneficiary_summary_2009 bs
WHERE DATE_PART('year', clm_from_dt) = 2009.0
AND inpatient_claims.desynpuf_id = bs.desynpuf_id;

UPDATE inpatient_claims
SET bs_id = bs.bs_id
FROM beneficiary_summary_2010 bs
WHERE DATE_PART('year', clm_from_dt) = 2010.0
AND inpatient_claims.desynpuf_id = bs.desynpuf_id;

-- --------------------------

ALTER TABLE outpatient_claims ADD COLUMN bs_id INTEGER;

UPDATE outpatient_claims
SET bs_id = bs.bs_id
FROM beneficiary_summary_2008 bs
WHERE DATE_PART('year', clm_from_dt) = 2008.0
AND outpatient_claims.desynpuf_id = bs.desynpuf_id;

UPDATE outpatient_claims
SET bs_id = bs.bs_id
FROM beneficiary_summary_2009 bs
WHERE DATE_PART('year', clm_from_dt) = 2009.0
AND outpatient_claims.desynpuf_id = bs.desynpuf_id;

UPDATE outpatient_claims
SET bs_id = bs.bs_id
FROM beneficiary_summary_2010 bs
WHERE DATE_PART('year', clm_from_dt) = 2010.0
AND outpatient_claims.desynpuf_id = bs.desynpuf_id;

-- --------------------------

ALTER TABLE carrier_claims ADD COLUMN bs_id INTEGER;

UPDATE carrier_claims
SET bs_id = bs.bs_id
FROM beneficiary_summary_2008 bs
WHERE DATE_PART('year', clm_from_dt) = 2008.0
AND carrier_claims.desynpuf_id = bs.desynpuf_id;

UPDATE carrier_claims
SET bs_id = bs.bs_id
FROM beneficiary_summary_2009 bs
WHERE DATE_PART('year', clm_from_dt) = 2009.0
AND carrier_claims.desynpuf_id = bs.desynpuf_id;

UPDATE carrier_claims
SET bs_id = bs.bs_id
FROM beneficiary_summary_2010 bs
WHERE DATE_PART('year', clm_from_dt) = 2010.0
AND carrier_claims.desynpuf_id = bs.desynpuf_id;


-- Combine the Beneficiary Summary tables into one table
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS beneficiary_summary_merged;

CREATE TABLE beneficiary_summary_merged AS TABLE beneficiary_summary_2008;
ALTER TABLE beneficiary_summary_merged ADD COLUMN bs_year SMALLINT;


UPDATE beneficiary_summary_merged
SET bs_year = 2008
WHERE bs_year IS NULL;

INSERT INTO beneficiary_summary_merged
SELECT *
FROM beneficiary_summary_2009;

UPDATE beneficiary_summary_merged
SET bs_year = 2009
WHERE bs_year IS NULL;

INSERT INTO beneficiary_summary_merged
SELECT *
FROM beneficiary_summary_2010;

UPDATE beneficiary_summary_merged
SET bs_year = 2010
WHERE bs_year IS NULL;


-- --------------------------------------------------------------------------------------------------------------------
--  Remove duplicates from ICD9 table
-- --------------------------------------------------------------------------------------------------------------------

--  There are duplicates in the icd9 dataset. Lets take a look at them.

SELECT code, COUNT(*)
FROM icd9
GROUP BY code
HAVING COUNT(*) > 1;

SELECT * FROM icd9 WHERE code = '2449';
SELECT * FROM icd9 WHERE code = '40390';
SELECT * FROM icd9 WHERE code = '30002';

--  These appear to be labeled as both 'included' and 'excluded. Remove all the duplicates, getting rid of 
--  the 'excluded' ones in these cases. The 'lncluded' ones all have lower primary keys than their 
--  'excluded' counterparts.

DELETE FROM icd9
WHERE primary_key IN
    (SELECT primary_key
    FROM 
        (SELECT primary_key,
         ROW_NUMBER() OVER( PARTITION BY code ORDER BY  primary_key ) AS row_num
        FROM icd9 ) t
        WHERE t.row_num > 1 );

SELECT * FROM icd9 WHERE code = '2449';
SELECT * FROM icd9 WHERE code = '40390';
SELECT * FROM icd9 WHERE code = '30002';


-- Get rid of the old de_syn_puf id and the old beneficiary summary tables
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE beneficiary_summary_2008;
DROP TABLE beneficiary_summary_2009;
DROP TABLE beneficiary_summary_2010;

ALTER TABLE beneficiary_summary_merged RENAME TO beneficiary_summaries;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Run cleanup of dead tuples & maximize efficiency
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

VACUUM FULL ANALYZE;