/*
-----------------------------------------------------------------------------------------------------------------------
	Prepare the de-Syn_PUF data for efficient use in Power BI.

    The original de-Syn-PUF dataset is large and unweildy. If we try to import it into Power BI as-is then it's 
    unusably slow to manipulate. It's also very difficult to create workable relationships.
    
    This involves removing extra columns nad merging tables. Also creating lookup tables for codes such as hcpcs that 
    have multiple columns for the same category of data.
-----------------------------------------------------------------------------------------------------------------------
*/


-- --------------------------------------------------------------------------------------------------------------------
--  Save the original desynpuf tables and create new Medical-Analysis (MA) tables
-- --------------------------------------------------------------------------------------------------------------------

/*

ALTER TABLE beneficiary_summary_2008 RENAME TO desynpuf_beneficiarysummary2008;
ALTER TABLE beneficiary_summary_2009 RENAME TO desynpuf_beneficiarysummary2009;
ALTER TABLE beneficiary_summary_2010 RENAME TO desynpuf_beneficiarysummary2010;
ALTER TABLE carrier_claims RENAME TO desynpuf_carrierclaims;
ALTER TABLE inpatient_claims RENAME TO desynpuf_inpatientclaims;
ALTER TABLE outpatient_claims RENAME TO desynpuf_outpatientclaims;
ALTER TABLE rx_drug_events RENAME TO desynpuf_rxdrugevents;

*/

/*

DROP TABLE IF EXISTS ma_beneficiarysummary2008;
DROP TABLE IF EXISTS ma_beneficiarysummary2009;
DROP TABLE IF EXISTS ma_beneficiarysummary2010;
DROP TABLE IF EXISTS ma_carrierclaims;
DROP TABLE IF EXISTS ma_inpatientclaims;
DROP TABLE IF EXISTS ma_outpatientclaims;
DROP TABLE IF EXISTS ma_rxdrugevents;

CREATE TABLE ma_beneficiarysummary2008 AS TABLE desynpuf_beneficiarysummary2008;
CREATE TABLE ma_beneficiarysummary2009 AS TABLE desynpuf_beneficiarysummary2009;
CREATE TABLE ma_beneficiarysummary2010 AS TABLE desynpuf_beneficiarysummary2010;
CREATE TABLE ma_carrierclaims AS TABLE desynpuf_carrierclaims;
CREATE TABLE ma_inpatientclaims AS TABLE desynpuf_inpatientclaims;
CREATE TABLE ma_outpatientclaims AS TABLE desynpuf_outpatientclaims;
CREATE TABLE ma_rxdrugevents AS TABLE desynpuf_rxdrugevents;


-- --------------------------------------------------------------------------------------------------------------------
-- Add Beneficiary Summary ID and merge Beneficiary Summaries into one table
-- --------------------------------------------------------------------------------------------------------------------

--      Relationships from desynpuf_id to multiple beneficiary summary tables from ma_outpatientclaims and similar 
--      are preventing Power BI from creating other relationships. The solution here is to create a new beneficiary 
--      summary id that is unique to each year's patient beneficiary summary.


-- Create unique Beneficiary Summary ID for each entry in Beneficiary Summaries
-- --------------------------------------------------------------------------------------------------------------------

ALTER TABLE ma_beneficiarysummary2008 DROP COLUMN IF EXISTS primary_key;
ALTER TABLE ma_beneficiarysummary2008 ADD COLUMN bs_id INTEGER UNIQUE;

CREATE SEQUENCE bs_id_seq
INCREMENT 1
START 1
OWNED BY ma_beneficiarysummary2008.bs_id;

UPDATE ma_beneficiarysummary2008
SET bs_id = nextval('bs_id_seq');

ALTER TABLE ma_beneficiarysummary2008 ADD PRIMARY KEY (bs_id);

-- --------------------------

ALTER TABLE ma_beneficiarysummary2009 DROP COLUMN IF EXISTS primary_key;
ALTER TABLE ma_beneficiarysummary2009 ADD COLUMN bs_id INTEGER UNIQUE;

ALTER SEQUENCE bs_id_seq OWNED BY ma_beneficiarysummary2009.bs_id;

UPDATE ma_beneficiarysummary2009
SET bs_id = nextval('bs_id_seq');

ALTER TABLE ma_beneficiarysummary2009 ADD PRIMARY KEY (bs_id);

-- --------------------------

ALTER TABLE ma_beneficiarysummary2010 DROP COLUMN IF EXISTS primary_key;
ALTER TABLE ma_beneficiarysummary2010 ADD COLUMN bs_id INTEGER UNIQUE;

ALTER SEQUENCE bs_id_seq OWNED BY ma_beneficiarysummary2010.bs_id;

UPDATE ma_beneficiarysummary2010
SET bs_id = nextval('bs_id_seq');

ALTER TABLE ma_beneficiarysummary2010 ADD PRIMARY KEY (bs_id);

-- --------------------------

DROP SEQUENCE IF EXISTS bs_id_seq;


-- Add the Beneficiary Summary ID for each other table in the DeSynPUF

ALTER TABLE ma_rxdrugevents ADD COLUMN bs_id INTEGER;

UPDATE ma_rxdrugevents
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2008 bs
WHERE DATE_PART('year', srvc_dt) = 2008.0
AND ma_rxdrugevents.desynpuf_id = bs.desynpuf_id;

UPDATE ma_rxdrugevents
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2009 bs
WHERE DATE_PART('year', srvc_dt) = 2009.0
AND ma_rxdrugevents.desynpuf_id = bs.desynpuf_id;

UPDATE ma_rxdrugevents
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2010 bs
WHERE DATE_PART('year', srvc_dt) = 2010.0
AND ma_rxdrugevents.desynpuf_id = bs.desynpuf_id;

-- --------------------------

ALTER TABLE ma_inpatientclaims ADD COLUMN bs_id INTEGER;

UPDATE ma_inpatientclaims
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2008 bs
WHERE DATE_PART('year', clm_from_dt) = 2008.0
AND ma_inpatientclaims.desynpuf_id = bs.desynpuf_id;

UPDATE ma_inpatientclaims
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2009 bs
WHERE DATE_PART('year', clm_from_dt) = 2009.0
AND ma_inpatientclaims.desynpuf_id = bs.desynpuf_id;

UPDATE ma_inpatientclaims
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2010 bs
WHERE DATE_PART('year', clm_from_dt) = 2010.0
AND ma_inpatientclaims.desynpuf_id = bs.desynpuf_id;

-- --------------------------

ALTER TABLE ma_outpatientclaims ADD COLUMN bs_id INTEGER;

UPDATE ma_outpatientclaims
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2008 bs
WHERE DATE_PART('year', clm_from_dt) = 2008.0
AND ma_outpatientclaims.desynpuf_id = bs.desynpuf_id;

UPDATE ma_outpatientclaims
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2009 bs
WHERE DATE_PART('year', clm_from_dt) = 2009.0
AND ma_outpatientclaims.desynpuf_id = bs.desynpuf_id;

UPDATE ma_outpatientclaims
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2010 bs
WHERE DATE_PART('year', clm_from_dt) = 2010.0
AND ma_outpatientclaims.desynpuf_id = bs.desynpuf_id;

-- --------------------------

ALTER TABLE ma_carrierclaims ADD COLUMN bs_id INTEGER;

UPDATE ma_carrierclaims
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2008 bs
WHERE DATE_PART('year', clm_from_dt) = 2008.0
AND ma_carrierclaims.desynpuf_id = bs.desynpuf_id;

UPDATE ma_carrierclaims
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2009 bs
WHERE DATE_PART('year', clm_from_dt) = 2009.0
AND ma_carrierclaims.desynpuf_id = bs.desynpuf_id;

UPDATE ma_carrierclaims
SET bs_id = bs.bs_id
FROM ma_beneficiarysummary2010 bs
WHERE DATE_PART('year', clm_from_dt) = 2010.0
AND ma_carrierclaims.desynpuf_id = bs.desynpuf_id;


-- Combine the Beneficiary Summary tables into one table

DROP TABLE IF EXISTS ma_beneficiarysummary;

CREATE TABLE ma_beneficiarysummary AS TABLE ma_beneficiarysummary2008;
ALTER TABLE ma_beneficiarysummary ADD COLUMN bs_year SMALLINT;


UPDATE ma_beneficiarysummary
SET bs_year = 2008;

INSERT INTO ma_beneficiarysummary
SELECT *
FROM ma_beneficiarysummary2009;

UPDATE ma_beneficiarysummary
SET bs_year = 2009
WHERE bs_year IS NULL;

INSERT INTO ma_beneficiarysummary
SELECT *
FROM ma_beneficiarysummary2010;

UPDATE ma_beneficiarysummary
SET bs_year = 2010
WHERE bs_year IS NULL;


-- Get rid of the old beneficiary summary tables

DROP TABLE ma_beneficiarysummary2008;
DROP TABLE ma_beneficiarysummary2009;
DROP TABLE ma_beneficiarysummary2010;


-- --------------------------------------------------------------------------------------------------------------------
--  Collect & Identify the distinct NDC codes that are used in the ma_rxdrugevents table
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_ndc;
CREATE TABLE ma_ndc (
    ndc11 VARCHAR UNIQUE,
    desc_long VARCHAR
);

INSERT INTO ma_ndc (ndc11, matched, desc_long)
SELECT ndc11, False, NULL 
FROM ma_rxdrugevents rde
WHERE NOT rde.ndc11 IS NULL
ON CONFLICT DO NOTHING;


SELECT COUNT(*) FROM ma_ndc;

--      RESULT: 268563

--  Sort throught the NDC codes in the DeSynPUF database that can be identified, and the ones that cant

UPDATE ma_ndc a
SET matched = TRUE,
    desc_long = c.desc_long
FROM ndc_combined c
WHERE a.ndc11 = c.ndc11;


SELECT matched, COUNT(*) 
    FROM ma_ndc 
    GROUP BY matched;


--      RESULTS:
--            False	105478
--            True	163085

--    60.7 % of the NDC codes referred to in the desynpuf dataset have matching descriptions


-- ------------------------------------------------------------------------------------------------------------------
-- Identify every unique ICD-9 code present in the deSynPUF dataset
-- ------------------------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS ma_icd;
CREATE TABLE ma_icd (
    icd9 VARCHAR UNIQUE,
    description VARCHAR
);

-- Create a function here, because making 100 slightly different commands would be repetitive.

DROP FUNCTION IF EXISTS identify_ma_icd;

CREATE OR REPLACE FUNCTION identify_ma_icd (
   table_name VARCHAR,
   icd_col VARCHAR
)

RETURNS TABLE ( 
	c BIGINT
)

LANGUAGE plpgsql

AS $$
	
DECLARE

	s TEXT;

BEGIN

	s :=  format('INSERT INTO %1$I '
                    || 'SELECT %2$I, False, NULL ' 
                    || 'FROM %3$I '
                    || 'WHERE NOT %2$I IS NULL '
                    || 'ON CONFLICT DO NOTHING;',
                'ma_icd', icd_col, table_name);

    RAISE INFO '%', s;
	EXECUTE s;

	RETURN QUERY EXECUTE format('SELECT COUNT(*) FROM %I;', 'ma_icd');

END
$$;

-- Carrier Claims

SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'icd9_dgns_cd_1');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'icd9_dgns_cd_2');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'icd9_dgns_cd_3');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'icd9_dgns_cd_4');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'icd9_dgns_cd_5');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'icd9_dgns_cd_6');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'icd9_dgns_cd_7');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'icd9_dgns_cd_8');

SELECT COUNT(*) FROM ma_icd;

--      RESULT: 13216

SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_1');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_2');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_3');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_4');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_5');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_6');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_7');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_8');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_9');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_10');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_11');
SELECT * FROM identify_ma_icd (table_name => 'ma_carrierclaims', icd_col => 'line_icd9_dgns_cd_12');

SELECT COUNT(*) FROM ma_icd;

--      RESULT: 13340


-- Inpatient Claims

SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_dgns_cd_1');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_dgns_cd_2');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_dgns_cd_3');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_dgns_cd_4');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_dgns_cd_5');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_dgns_cd_6');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_dgns_cd_7');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_dgns_cd_8');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_dgns_cd_9');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_dgns_cd_10');

SELECT COUNT(*) FROM ma_icd;

--      RESULT: 13384

SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_1');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_2');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_3');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_4');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_5');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_6');

SELECT COUNT(*) FROM ma_icd;

--      RESULT: 14156


-- Outpatient Claims

SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_dgns_cd_1');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_dgns_cd_2');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_dgns_cd_3');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_dgns_cd_4');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_dgns_cd_5');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_dgns_cd_6');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_dgns_cd_7');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_dgns_cd_8');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_dgns_cd_9');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_dgns_cd_10');

SELECT COUNT(*) FROM ma_icd;

--      RESULT: 14284


SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_1');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_2');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_3');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_4');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_5');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_6');

SELECT COUNT(*) FROM ma_icd;

--      RESULT: 14284


--  Sort throught the ICD codes in the DeSynPUF database that can be identified, and the ones that cant

UPDATE ma_icd a
SET matched = TRUE,
    description = i.description
FROM icd9 i
WHERE a.icd9 = i.code;


SELECT matched, COUNT(*) 
    FROM ma_icd 
    GROUP BY matched;

--      RESULTS:
--            False	2305
--            True	11979

--    83.9 % of the ICD codes referred to in the desynpuf dataset have matching descriptions


ALTER TABLE ma_icd ADD COLUMN icd_id SERIAL PRIMARY KEY;


-- ------------------------------------------------------------------------------------------------------------------
-- Identify every unique HCPCS code present in the deSynPUF dataset
-- ------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_hcpcs;
CREATE TABLE ma_hcpcs (
    hcpcs VARCHAR UNIQUE,
    description VARCHAR
);

-- Create a function here, because making 100 slightly different commands would be repetitive.

DROP FUNCTION IF EXISTS identify_ma_hcpcs;

CREATE OR REPLACE FUNCTION identify_ma_hcpcs (
   table_name VARCHAR,
   hcpcs_col VARCHAR
)

RETURNS TABLE ( 
	c BIGINT
)

LANGUAGE plpgsql

AS $$
	
DECLARE

	s TEXT;

BEGIN

	s :=  format('INSERT INTO %1$I '
                    || 'SELECT %2$I, False, NULL ' 
                    || 'FROM %3$I '
                    || 'WHERE NOT %2$I IS NULL '
                    || 'ON CONFLICT DO NOTHING;',
                'ma_hcpcs', hcpcs_col, table_name);

    RAISE INFO '%', s;
	EXECUTE s;

	RETURN QUERY EXECUTE format('SELECT COUNT(*) FROM %I;', 'ma_hcpcs');

END
$$;

-- Inpatient Claims

SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_1');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_2');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_3');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_4');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_5');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_6');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_7');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_8');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_9');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_10');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_11');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_12');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_13');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_14');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_15');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_16');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_17');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_18');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_19');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_20');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_21');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_22');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_23');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_24');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_25');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_26');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_27');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_28');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_29');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_30');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_31');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_32');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_33');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_34');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_35');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_36');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_37');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_38');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_39');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_40');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_41');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_42');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_43');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_44');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_inpatientclaims', hcpcs_col => 'hcpcs_cd_45');

SELECT COUNT(*) FROM ma_hcpcs;

--      RESULT: 0

--      There are NO hcpcs codes in the inpatient claims tables. Drop all those columns

AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_1;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_2;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_3;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_4;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_5;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_6;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_7;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_8;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_9;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_10;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_11;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_12;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_13;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_14;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_15;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_16;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_17;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_18;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_19;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_20;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_21;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_22;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_23;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_24;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_25;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_26;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_27;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_28;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_29;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_30;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_31;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_32;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_33;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_34;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_35;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_36;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_37;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_38;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_39;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_40;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_41;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_42;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_43;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_44;
AlTER TABLE ma_inpatientclaims DROP COLUMN hcpcs_cd_45;


-- Outpatient Claims

SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_1');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_2');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_3');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_4');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_5');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_6');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_7');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_8');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_9');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_10');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_11');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_12');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_13');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_14');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_15');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_16');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_17');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_18');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_19');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_20');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_21');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_22');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_23');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_24');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_25');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_26');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_27');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_28');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_29');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_30');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_31');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_32');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_33');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_34');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_35');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_36');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_37');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_38');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_39');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_40');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_41');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_42');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_43');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_44');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_outpatientclaims', hcpcs_col => 'hcpcs_cd_45');

SELECT COUNT(*) FROM ma_hcpcs;

--      RESULT: 5618


-- Carrier Claims

SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_1');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_2');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_3');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_4');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_5');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_6');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_7');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_8');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_9');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_10');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_11');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_12');
SELECT * FROM identify_ma_hcpcs (table_name => 'ma_carrierclaims', hcpcs_col => 'hcpcs_cd_13');

SELECT COUNT(*) FROM ma_hcpcs;

--      RESULT: 8991


--  Sort throught the HCPCS codes in the DeSynPUF database that can be identified, and the ones that cant

UPDATE ma_hcpcs a
SET matched = TRUE,
    description = h.desc_long
FROM hcpcs h
WHERE a.hcpcs = h.hcpcs;


SELECT matched, COUNT(*) 
    FROM ma_hcpcs 
    GROUP BY matched;

--      RESULTS:
--            False	306
--            True	8685

--    96.6 % of the HCPCS codes referred to in the desynpuf dataset have matching descriptions


*/

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Convert desynpuf_id to INTEGER
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS patient_id_conversion;
CREATE TABLE patient_id_conversion (
    beneficiary_id BIGINT UNIQUE,
    patient_id SERIAL PRIMARY KEY
);

INSERT INTO patient_id_conversion (beneficiary_id)
SELECT desynpuf_id
FROM ma_beneficiarySummary
ON CONFLICT DO NOTHING;


ALTER TABLE ma_beneficiarysummary ADD COLUMN patient_id INTEGER;

UPDATE ma_beneficiarysummary m
SET patient_id = c.patient_id
FROM patient_id_conversion c
WHERE m.desynpuf_id = c.beneficiary_id;


ALTER TABLE ma_beneficiarysummary DROP COLUMN desynpuf_id;


ALTER TABLE ma_carrierclaims ADD COLUMN patient_id INTEGER;

UPDATE ma_carrierclaims m
SET patient_id = c.patient_id
FROM patient_id_conversion c
WHERE m.desynpuf_id = c.beneficiary_id;


ALTER TABLE ma_carrierclaims DROP COLUMN desynpuf_id;


ALTER TABLE ma_inpatientclaims ADD COLUMN patient_id INTEGER;

UPDATE ma_inpatientclaims m
SET patient_id = c.patient_id
FROM patient_id_conversion c
WHERE m.desynpuf_id = c.beneficiary_id;

ALTER TABLE ma_inpatientclaims DROP COLUMN desynpuf_id;


ALTER TABLE ma_outpatientclaims ADD COLUMN patient_id INTEGER;

UPDATE ma_outpatientclaims m
SET patient_id = c.patient_id
FROM patient_id_conversion c
WHERE m.desynpuf_id = c.beneficiary_id;

ALTER TABLE ma_outpatientclaims DROP COLUMN desynpuf_id;


ALTER TABLE ma_rxdrugevents ADD COLUMN patient_id INTEGER;

UPDATE ma_rxdrugevents m
SET patient_id = c.patient_id
FROM patient_id_conversion c
WHERE m.desynpuf_id = c.beneficiary_id;

ALTER TABLE ma_rxdrugevents DROP COLUMN desynpuf_id;


DROP TABLE IF EXISTS patient_id_conversion;


-- --------------------------------------------------------------------------------------------------------------------
-- Truncate numeric columns to INTEGER
-- --------------------------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS cast_col;

CREATE OR REPLACE FUNCTION cast_col (
   table_name VARCHAR,
   col_name VARCHAR
)

RETURNS TABLE ( 
	c BIGINT
)

LANGUAGE plpgsql

AS $$
	
DECLARE

	col_name_OLD VARCHAR;


BEGIN

    col_name_OLD := col_name || '_OLD';

	EXECUTE  format('ALTER TABLE %I RENAME COLUMN %I TO %I;',
                table_name, col_name, col_name_OLD);

	EXECUTE  format('ALTER TABLE %I ADD COLUMN %I INTEGER;',
                table_name, col_name);

	EXECUTE  format('UPDATE %I SET %I = CAST(%I AS INTEGER);',
                table_name, col_name, col_name_OLD);

	EXECUTE  format('ALTER TABLE %I DROP COLUMN %I;',
                table_name, col_name_OLD);

	RETURN QUERY EXECUTE format('SELECT COUNT(*) FROM %I;', table_name);

END
$$;


-- Beneficiary Summary

SELECT cast_col('ma_beneficiarysummary', 'medreimb_ip');
SELECT cast_col('ma_beneficiarysummary', 'benres_ip');
SELECT cast_col('ma_beneficiarysummary', 'pppymt_ip');
SELECT cast_col('ma_beneficiarysummary', 'medreimb_op');
SELECT cast_col('ma_beneficiarysummary', 'benres_op');
SELECT cast_col('ma_beneficiarysummary', 'pppymt_op');
SELECT cast_col('ma_beneficiarysummary', 'medreimb_car');
SELECT cast_col('ma_beneficiarysummary', 'benres_car');
SELECT cast_col('ma_beneficiarysummary', 'pppymt_car');

-- Carrier Claims

SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_1');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_2');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_3');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_4');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_5');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_6');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_7');

SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_8');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_9');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_10');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_11');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_12');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_13');

SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_1');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_2');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_3');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_4');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_5');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_6');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_7');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_8');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_9');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_10');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_11');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_12');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_13');

SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_1');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_2');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_3');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_4');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_5');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_6');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_7');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_8');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_9');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_10');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_11');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_12');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_13');

SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_1');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_2');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_3');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_4');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_5');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_6');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_7');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_8');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_9');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_10');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_11');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_12');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_13');

SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_1');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_2');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_3');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_4');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_5');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_6');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_7');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_8');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_9');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_10');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_11');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_12');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_13');

-- Inpatient Claims

SELECT cast_col('ma_inpatientclaims', 'clm_pmt_amt');
SELECT cast_col('ma_inpatientclaims', 'nch_prmry_pyr_clm_pd_amt');
SELECT cast_col('ma_inpatientclaims', 'clm_pass_thru_per_diem_amt');
SELECT cast_col('ma_inpatientclaims', 'nch_bene_ip_ddctbl_amt');
SELECT cast_col('ma_inpatientclaims', 'nch_bene_pta_coinsrnc_lblty_am');
SELECT cast_col('ma_inpatientclaims', 'nch_bene_blood_ddctbl_lblty_am');

-- Outpatient Claims

SELECT cast_col('ma_outpatientclaims', 'clm_pmt_amt');
SELECT cast_col('ma_outpatientclaims', 'nch_prmry_pyr_clm_pd_amt');
SELECT cast_col('ma_outpatientclaims', 'nch_bene_blood_ddctbl_lblty_am');
SELECT cast_col('ma_outpatientclaims', 'nch_bene_ptb_ddctbl_amt');
SELECT cast_col('ma_outpatientclaims', 'nch_bene_ptb_coinsrnc_amt');


-- --------------------------------------------------------------------------------------------------------------------
-- Correlate NDC codes to Rx Drug Events
-- --------------------------------------------------------------------------------------------------------------------

ALTER TABLE ma_ndc ADD COLUMN ndc11_id SERIAL PRIMARY KEY;

ALTER TABLE ma_rxdrugevents ADD COLUMN ndc11_id INTEGER;

UPDATE ma_rxdrugevents a
SET ndc11_id = b.ndc11_id
FROM ma_ndc b
WHERE a.ndc11 = b.ndc11;

ALTER TABLE ma_rxdrugevents DROP COLUMN ndc11;


-- --------------------------------------------------------------------------------------------------------------------
-- Correlate ICD codes to each table
-- --------------------------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS correllate_icd;

CREATE OR REPLACE FUNCTION correllate_icd (
   source_table_name VARCHAR,
   dest_table_name VARCHAR,
   source_col_name VARCHAR
)

RETURNS TABLE ( 
	c BIGINT
)

LANGUAGE plpgsql

AS $$
	

BEGIN

	EXECUTE  format('INSERT INTO %1$I '
                    || 'SELECT %2$I.%3$I, %5$I.%4$I '
                    || 'FROM %5$I '
                    || 'INNER JOIN %2$I '
                    || 'ON %5$I.%6$I = %2$I.%7$I;',
                dest_table_name,    -- 1
                'ma_icd',           -- 2
                'icd_id',           -- 3
                'clm_id',           -- 4
                source_table_name,  -- 5
                source_col_name,    -- 6
                'icd9');            -- 7

	RETURN QUERY EXECUTE format('SELECT COUNT(*) FROM %I;', 'ma_icd');

END
$$;


-- EXAMPLE:

--         INSERT INTO ma_ic_icd9_dgns_cd
--         SELECT ma_icd.icd_id, ma_inpatientclaims.clm_id
--         FROM ma_inpatientclaims
--             INNER JOIN ma_icd
--             ON ma_inpatientclaims.icd9_dgns_cd_1 = ma_icd.icd9;



-- Inpatient Claims
-- ------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_ic_icd9_dgns_cd;
CREATE TABLE ma_ic_icd9_dgns_cd (
    icd9_id INTEGER,
    clm_id BIGINT
);

SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns_cd', 'icd9_dgns_cd_1');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns_cd', 'icd9_dgns_cd_2');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns_cd', 'icd9_dgns_cd_3');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns_cd', 'icd9_dgns_cd_4');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns_cd', 'icd9_dgns_cd_5');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns_cd', 'icd9_dgns_cd_6');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns_cd', 'icd9_dgns_cd_7');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns_cd', 'icd9_dgns_cd_8');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns_cd', 'icd9_dgns_cd_9');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns_cd', 'icd9_dgns_cd_10');

SELECT COUNT(*) FROM ma_ic_icd9_dgns_cd;

--      RESULT: 537271


DROP TABLE IF EXISTS ma_ic_icd9_prcdr_cd;
CREATE TABLE ma_ic_icd9_prcdr_cd (
    icd9_id INTEGER,
    clm_id BIGINT
);

SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr_cd', 'icd9_prcdr_cd_1');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr_cd', 'icd9_prcdr_cd_2');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr_cd', 'icd9_prcdr_cd_3');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr_cd', 'icd9_prcdr_cd_4');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr_cd', 'icd9_prcdr_cd_5');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr_cd', 'icd9_prcdr_cd_6');

SELECT COUNT(*) FROM ma_ic_icd9_prcdr_cd;

--      RESULT: 95871


ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_1;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_2;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_3;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_4;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_5;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_6;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_7;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_8;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_9;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_10;

ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_1;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_2;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_3;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_4;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_5;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_6;


-- Outpatient Claims
-- ------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_oc_icd9_dgns_cd;
CREATE TABLE ma_oc_icd9_dgns_cd (
    icd9_id INTEGER,
    clm_id BIGINT
);

SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns_cd', 'icd9_dgns_cd_1');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns_cd', 'icd9_dgns_cd_2');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns_cd', 'icd9_dgns_cd_3');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns_cd', 'icd9_dgns_cd_4');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns_cd', 'icd9_dgns_cd_5');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns_cd', 'icd9_dgns_cd_6');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns_cd', 'icd9_dgns_cd_7');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns_cd', 'icd9_dgns_cd_8');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns_cd', 'icd9_dgns_cd_9');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns_cd', 'icd9_dgns_cd_10');

SELECT COUNT(*) FROM ma_oc_icd9_dgns_cd;

--      RESULT: 2073796


DROP TABLE IF EXISTS ma_oc_icd9_prcdr_cd;
CREATE TABLE ma_oc_icd9_prcdr_cd (
    icd9_id INTEGER,
    clm_id BIGINT
);

SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr_cd', 'icd9_prcdr_cd_1');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr_cd', 'icd9_prcdr_cd_2');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr_cd', 'icd9_prcdr_cd_3');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr_cd', 'icd9_prcdr_cd_4');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr_cd', 'icd9_prcdr_cd_5');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr_cd', 'icd9_prcdr_cd_6');

SELECT COUNT(*) FROM ma_oc_icd9_prcdr_cd;

--      RESULT: 508

ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_1;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_2;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_3;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_4;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_5;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_6;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_7;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_8;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_9;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_10;

ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_1;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_2;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_3;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_4;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_5;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_6;

/*

-- Carrier Claims
-- ------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_cc_icd9_dgns_cd;
CREATE TABLE ma_cc_icd9_dgns_cd (
    icd9_id INTEGER,
    clm_id BIGINT
);

SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns_cd', 'icd9_dgns_cd_1');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns_cd', 'icd9_dgns_cd_2');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns_cd', 'icd9_dgns_cd_3');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns_cd', 'icd9_dgns_cd_4');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns_cd', 'icd9_dgns_cd_5');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns_cd', 'icd9_dgns_cd_6');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns_cd', 'icd9_dgns_cd_7');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns_cd', 'icd9_dgns_cd_8');

SELECT COUNT(*) FROM ma_cc_icd9_dgns_cd;

--      RESULT: 


ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_1;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_2;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_3;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_4;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_5;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_6;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_7;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_8;


-- ------------------------------------------------------------------------------------------------

--      The carrier claims are separated by line item. Convert the ICD line diagnoses to 
--      corresponding IDs. We might separate line items later.

ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_1 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_2 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_3 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_4 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_5 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_6 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_7 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_8 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_9 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_10 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_11 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_12 INTEGER;
ALTER TABLE ma_carrierclaims ADD COLUMN line_icd9_id_13 INTEGER;


UPDATE ma_carrierclaims a
SET line_icd9_id_1 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_1 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_2 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_2 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_3 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_3 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_4 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_4 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_5 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_5 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_6 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_6 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_7 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_7 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_8 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_8 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_9 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_9 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_10 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_10 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_11 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_11 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_12 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_12 = b.ndc11;

UPDATE ma_carrierclaims a
SET line_icd9_id_13 = b.ndc11_id
FROM ma_ndc b
WHERE a.line_icd9_dgns_cd_13 = b.ndc11;

ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_1;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_2;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_3;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_4;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_5;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_6;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_7;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_8;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_9;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_10;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_11;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_12;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_13;


-- --------------------------------------------------------------------------------------------------------------------
-- Correlate HCPCS codes to each table
-- --------------------------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS correllate_hcpcs;

CREATE OR REPLACE FUNCTION correllate_hcpcs (
   source_table_name VARCHAR,
   dest_table_name VARCHAR,
   source_col_name VARCHAR
)

RETURNS TABLE ( 
	c BIGINT
)

LANGUAGE plpgsql

AS $$
	

BEGIN

	EXECUTE  format('INSERT INTO %1$I '
                    || 'SELECT %2$I.%3$I, %5$I.%4$I '
                    || 'FROM %5$I '
                    || 'INNER JOIN %2$I '
                    || 'ON %5$I.%6$I = %2$I.%7$I;',
                dest_table_name,    -- 1
                'ma_hcpcs',           -- 2
                'icd_id',           -- 3
                'clm_id',           -- 4
                source_table_name,  -- 5
                source_col_name,    -- 6
                'hcpcs');            -- 7

	RETURN QUERY EXECUTE format('SELECT COUNT(*) FROM %I;', 'ma_hcpcs');

END
$$;

*/

-- --------------------------------------------------------------------------------------------------------------------
-- Run cleanup of dead tuples & maximize efficiency
-- --------------------------------------------------------------------------------------------------------------------

VACUUM FULL ANALYZE;