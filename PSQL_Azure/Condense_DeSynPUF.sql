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

ALTER TABLE beneficiary_summary_2008 RENAME TO desynpuf_beneficiarysummary2008;
ALTER TABLE beneficiary_summary_2009 RENAME TO desynpuf_beneficiarysummary2009;
ALTER TABLE beneficiary_summary_2010 RENAME TO desynpuf_beneficiarysummary2010;
ALTER TABLE carrier_claims RENAME TO desynpuf_carrierclaims;
ALTER TABLE inpatient_claims RENAME TO desynpuf_inpatientclaims;
ALTER TABLE outpatient_claims RENAME TO desynpuf_outpatientclaims;
ALTER TABLE rx_drug_events RENAME TO desynpuf_rxdrugevents;

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

SELECT desynpuf_id, bs_id FROM ma_beneficiarysummary2008 ORDER BY bs_id LIMIT 20;

ALTER TABLE ma_beneficiarysummary2008 ADD PRIMARY KEY (bs_id);

-- --------------------------

ALTER TABLE ma_beneficiarysummary2009 DROP COLUMN IF EXISTS primary_key;
ALTER TABLE ma_beneficiarysummary2009 ADD COLUMN bs_id INTEGER UNIQUE;

ALTER SEQUENCE bs_id_seq OWNED BY ma_beneficiarysummary2009.bs_id;

UPDATE ma_beneficiarysummary2009
SET bs_id = nextval('bs_id_seq');

ALTER TABLE ma_beneficiarysummary2009 ADD PRIMARY KEY (bs_id);

SELECT desynpuf_id, bs_id FROM ma_beneficiarysummary2009 ORDER BY bs_id LIMIT 20;

-- --------------------------

ALTER TABLE ma_beneficiarysummary2010 DROP COLUMN IF EXISTS primary_key;
ALTER TABLE ma_beneficiarysummary2010 ADD COLUMN bs_id INTEGER UNIQUE;

ALTER SEQUENCE bs_id_seq OWNED BY ma_beneficiarysummary2010.bs_id;

UPDATE ma_beneficiarysummary2010
SET bs_id = nextval('bs_id_seq');

ALTER TABLE ma_beneficiarysummary2010 ADD PRIMARY KEY (bs_id);

SELECT desynpuf_id, bs_id FROM ma_beneficiarysummary2010 ORDER BY bs_id LIMIT 20;

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

DROP TABLE IF EXISTS ndc_desynpuf;
CREATE TABLE ndc_desynpuf (
    ndc11 VARCHAR UNIQUE,
    matched BOOLEAN,
    desc_long VARCHAR
);

INSERT INTO ndc_desynpuf (ndc11, matched, desc_long)
SELECT ndc11, False, NULL 
FROM ma_rxdrugevents rde
WHERE NOT rde.ndc11 IS NULL
ON CONFLICT DO NOTHING;


SELECT COUNT(*) FROM ndc_desynpuf;

--      RESULT: 268563


-- ------------------------------------------------------------------------------------------------------------------
-- Identify every unique ICD-9 code present in the deSynPUF dataset
-- ------------------------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS ma_icd;
CREATE TABLE ma_icd (
    icd9 VARCHAR UNIQUE,
    matched BOOLEAN,
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

--      RESULT: 

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

--      RESULT: 


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

--      RESULT: 

SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_1');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_2');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_3');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_4');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_5');
SELECT * FROM identify_ma_icd (table_name => 'ma_inpatientclaims', icd_col => 'icd9_prcdr_cd_6');

SELECT COUNT(*) FROM ma_icd;

--      RESULT: 


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

--      RESULT: 


SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_1');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_2');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_3');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_4');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_5');
SELECT * FROM identify_ma_icd (table_name => 'ma_outpatientclaims', icd_col => 'icd9_prcdr_cd_6');

SELECT COUNT(*) FROM ma_icd;

--      RESULT: 



-- ------------------------------------------------------------------------------------------------------------------
-- Identify every unique HCPCS code present in the deSynPUF dataset
-- ------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_hcpcs;
CREATE TABLE ma_hcpcs (
    hcpcs VARCHAR UNIQUE,
    matched BOOLEAN,
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

--      RESULT: 


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

--      RESULT: 

/*

--  Sort throught the NDC codes in the DeSynPUF database that can be identified, and the ones that cant
-- --------------------------------------------------------------------------------------------------------------------

UPDATE ndc_desynpuf a
SET matched = TRUE,
    desc_long = c.desc_long
FROM ndc_combined c
WHERE a.ndc11 = c.ndc11;


SELECT matched, COUNT(*) 
    FROM ndc_desynpuf 
    GROUP BY matched;

/*
      RESULTS:
            False	105478
            True	163085

    60.7 % of the NDC codes referred to in the desynpuf dataset have matching descriptions
*/
*/


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Run cleanup of dead tuples & maximize efficiency
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

VACUUM FULL ANALYZE;