/*
-----------------------------------------------------------------------------------------------------------------------
	STEP 4
    
    Restructure the de-Syn_PUF dataset from the original "flat" style to a relational database.

    	** PART 1 **

    The original de-Syn-PUF dataset is large and inefficient. If we try to import it into Power BI as is then it's 
    unusably slow. It's also very difficult to create workable relationships between columns with the "flat" format 
	that is given. Here we configure the data to be more relational. This process is completed in two major steps, 
	saving at the end of each file for easier recovery. This saves time in case some of this processing needs 
	to be redone later.


        Summary:
            Create Table for Line Processing Indicator Code (used in carrier claims).
            Add Beneficiary Summary ID and merge Beneficiary Summaries into one table.
            Collect & Identify the distinct NDC codes that are used in the ma_rxdrugevents table.
            Identify every unique ICD-9 code present in the deSynPUF dataset.
            Identify every unique HCPCS code present in the deSynPUF dataset.
            Convert desynpuf_id to INTEGER.

-----------------------------------------------------------------------------------------------------------------------
*/

/*
-- --------------------------------------------------------------------------------------------------------------------
--  Load tables from the previous save point.
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_beneficiarysummary2008;
DROP TABLE IF EXISTS ma_beneficiarysummary2009;
DROP TABLE IF EXISTS ma_beneficiarysummary2010;
DROP TABLE IF EXISTS ma_carrierclaims;
DROP TABLE IF EXISTS ma_inpatientclaims;
DROP TABLE IF EXISTS ma_outpatientclaims;
DROP TABLE IF EXISTS ma_rxdrugevents;

DROP TABLE IF EXISTS hcpcs;
DROP TABLE IF EXISTS icd9;
DROP TABLE IF EXISTS ndc_combined;


CREATE TABLE ma_beneficiarysummary2008 AS TABLE Save2_desynpuf_beneficiarysummary2008;
CREATE TABLE ma_beneficiarysummary2009 AS TABLE Save2_desynpuf_beneficiarysummary2009;
CREATE TABLE ma_beneficiarysummary2010 AS TABLE Save2_desynpuf_beneficiarysummary2010;
CREATE TABLE ma_carrierclaims AS TABLE Save2_desynpuf_carrierclaims;
CREATE TABLE ma_inpatientclaims AS TABLE Save2_desynpuf_inpatientclaims;
CREATE TABLE ma_outpatientclaims AS TABLE Save2_desynpuf_outpatientclaims;
CREATE TABLE ma_rxdrugevents AS TABLE Save2_desynpuf_rxdrugevents;

CREATE TABLE hcpcs AS TABLE Save3_hcpcs;
CREATE TABLE icd9 AS TABLE Save3_icd9;
CREATE TABLE ndc_combined AS TABLE Save3_ndc;

*/

-- --------------------------------------------------------------------------------------------------------------------
-- Create Table for Line Processing Indicator Code (used in carrier claims).
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_line_prcsg_ind_cd;
CREATE TABLE ma_line_prcsg_ind_cd (
    code VARCHAR,
    description VARCHAR
);

INSERT INTO ma_line_prcsg_ind_cd (code, description)
VALUES ('A', 'Allowed'),
        ('B', 'Benefits exhausted'),
        ('C', 'Non-covered care'),
        ('D', 'Denied (from BMAD)'),
        ('G', 'MSP cost avoided - Secondary Claims Investigation'),
        ('H', 'MSP cost avoided - Self Reports'),
        ('I', 'Invalid data'),
        ('J', 'MSP cost avoided - 411.25'),
        ('K', 'MSP cost avoided - Insurer Voluntary Reporting'),
        ('L', 'CLIA'),
        ('M', 'Multiple submittal-duplicate line item'),
        ('N', 'Medically unnecessary'),
        ('O', 'Other'),
        ('P', 'Physician ownership denial'),
        ('Q', 'MSP cost avoided (contractor #88888) - voluntary agreement'),
        ('R', 'Reprocessed adjustments based on subsequent reprocessing of claim'),
        ('S', 'Secondary payer'),
        ('T', 'MSP cost avoided - IEQ contractor'),
        ('U', 'MSP cost avoided - HMO rate cell adjustment'),
        ('V', 'MSP cost avoided - litigation settlement'),
        ('X', 'MSP cost avoided - generic'),
        ('Y', 'MSP cost avoided - IRS/SSA data match project'),
        ('Z', 'Bundled test, no payment'),

        --      updated double-character codes

        ('00', 'MSP cost avoided - COB Contractor'),
        ('12', 'MSP cost avoided - BC/BS Voluntary Agreements'),
        ('13', 'MSP cost avoided - Office of Personnel Management'),
        ('14', 'MSP cost avoided - Workmans Compensation (WC) Datamatch'),
        ('15', 'MSP cost avoided - Workmans Compensation Insurer Voluntary Data Sharing Agreements'),
        ('16', 'MSP cost avoided - Liability Insurer VDSA'),
        ('17', 'MSP cost avoided - No-Fault Insurer VDSA'),
        ('18', 'MSP cost avoided - Pharmacy Benefit Manager Data Sharing Agreement'),
        ('21', 'MSP cost avoided - MIR Group Health Plan'),
        ('22', 'MSP cost avoided - MIR non-Group Health Plan'),
        ('25', 'MSP cost avoided - Recovery Audit Contractor - California'),
        ('26', 'MSP cost avoided - Recovery Audit Contractor - Florida'),

        --      legacy single-character codes

        ('!', 'MSP cost avoided - COB Contractor'),
        ('@', 'MSP cost avoided - BC/BS Voluntary Agreements'),
        ('#', 'MSP cost avoided - Office of Personnel Management'),
        ('$', 'MSP cost avoided - Workmans Compensation'),
        ('*', 'MSP cost avoided - Workmans Compensation Insurer Voluntary Data Sharing Agreements'),
        ('(', 'MSP cost avoided - Liability Insurer VDSA'),
        (')', 'MSP cost avoided - No-Fault Insurer VDSA'),
        ('+', 'MSP cost avoided - Pharmacy Benefit Manager Data Sharing Agreement'),
        ('<', 'MSP cost avoided - MIR Group Health Plan'),
        ('>', 'MSP cost avoided - MIR non-Group Health Plan'),
        ('%', 'MSP cost avoided - Recovery Audit Contractor - California'),
        ('&', 'MSP cost avoided - Recovery Audit Contractor - Florida');


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
--  Collect & Identify the distinct NDC codes that are used in the ma_rxdrugevents table.
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_ndc;
CREATE TABLE ma_ndc (
    ndc11 VARCHAR UNIQUE,
    matched BOOLEAN,
    desc_long VARCHAR,
    desc_short VARCHAR
);

INSERT INTO ma_ndc (ndc11, matched, desc_long, desc_short)
SELECT ndc11, False, NULL , NULL
FROM ma_rxdrugevents rde
WHERE NOT rde.ndc11 IS NULL
ON CONFLICT DO NOTHING;

SELECT COUNT(*) FROM ma_ndc;

--      RESULT: 268563

--  Sort throught the NDC codes in the DeSynPUF database that can be identified, and the ones that cant

UPDATE ma_ndc a
SET matched = TRUE,
    desc_long = c.desc_long,
    desc_short = c.desc_short
FROM ndc_combined c
WHERE a.ndc11 = c.ndc11;

--  Include "unidentified" descriptions for the codes that are not identified in the NDC table

UPDATE ma_ndc a
SET desc_long = ndc11 || ' - unidentified',
    desc_short = ndc11 || ' - unidentified'
WHERE a.matched = FALSE;


SELECT matched, COUNT(*) 
    FROM ma_ndc 
    GROUP BY matched;

--      RESULTS:
--            False	105478
--            True	163085

--    60.7 % of the NDC codes referred to in the desynpuf dataset have matching descriptions


--      Create a unique ID number for each NDC code in the de-Syn-PUF dataset
--      This will allow us to refer to NDC codes using 4-byte integers instead of 12-byte varchars

ALTER TABLE ma_ndc ADD COLUMN ndc11_id SERIAL PRIMARY KEY;


-- ------------------------------------------------------------------------------------------------------------------
-- Identify every unique ICD-9 code present in the deSynPUF dataset.
-- ------------------------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS ma_icd;
CREATE TABLE ma_icd (
    icd VARCHAR UNIQUE,
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


--  Indicate the ICD codes in the DeSynPUF database that have an identifying description, and the ones that dont

UPDATE ma_icd a
SET matched = TRUE,
    description = i.description
FROM icd9 i
WHERE a.icd = i.code;


SELECT matched, COUNT(*) 
    FROM ma_icd 
    GROUP BY matched;

--      RESULTS:
--            False	2305
--            True	11979

--    83.9 % of the ICD codes referred to in the desynpuf dataset have matching descriptions


--      Create a unique ID for each ICD code in the de-Syn-PUF dataset.
--      This allows us to refer to ICD codes using 4-byte integers instead of 6-byte varchars

ALTER TABLE ma_icd ADD COLUMN icd_id SERIAL PRIMARY KEY;

--  Add short descriptions

ALTER TABLE ma_icd RENAME COLUMN description TO desc_long;
ALTER TABLE ma_icd ADD COLUMN desc_short VARCHAR;

UPDATE ma_icd
SET desc_short = desc_long
WHERE length(desc_long) <= 29;

UPDATE ma_icd
SET desc_short = SUBSTRING(desc_long, 1, 29) || '...'
WHERE length(desc_long) > 29;

UPDATE ma_icd
SET desc_short = icd || ' - unidentified',
    desc_long = icd || ' - unidentified'
WHERE matched = False;


-- ------------------------------------------------------------------------------------------------------------------
-- Identify every unique HCPCS code present in the deSynPUF dataset.
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


--  Indicate the HCPCS codes in the DeSynPUF database that have an identifying description, and the ones that dont

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


--      Create a unique ID number for each hcpcs code in the de-Syn-PUF dataset
--      This allows us to refer to HCPCS codes using 4-byte integers instead of 6-byte varchars

ALTER TABLE ma_hcpcs ADD COLUMN hcpcs_id SERIAL PRIMARY KEY;

--  Add short descriptions

ALTER TABLE ma_hcpcs RENAME COLUMN description TO desc_long;
ALTER TABLE ma_hcpcs ADD COLUMN desc_short VARCHAR;

UPDATE ma_hcpcs a
SET desc_short = b.desc_short
FROM hcpcs b
WHERE a.hcpcs = b.hcpcs
    AND length(b.desc_short) <= 29;

UPDATE ma_hcpcs a
SET desc_short = SUBSTRING(b.desc_short, 1, 29) || '...'
FROM hcpcs b
WHERE a.hcpcs = b.hcpcs
    AND length(b.desc_short) > 29;

UPDATE ma_hcpcs
SET desc_short = hcpcs || ' - unidentified',
    desc_long = hcpcs || ' - unidentified'
WHERE matched = False;


-- --------------------------------------------------------------------------------------------------------------------
-- Convert desynpuf_id to INTEGER.
-- --------------------------------------------------------------------------------------------------------------------


--      There are 116352 distinct beneficiary IDs referred to in the de-Syn-PUF dataset, so BIGINT (8 bytes) is 
--      unnecessarily large.

--      Create a new patient ID that is INTEGER (4 bytes) and convert beneficiary IDs to it int order to reduce 
--      storage usage.

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
-- Drop the full ICD, HCPCS, and NDC tables. In the future we will use the more efficient MA tables.
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS hcpcs;
DROP TABLE IF EXISTS icd9;
DROP TABLE IF EXISTS ndc_combined;


-- --------------------------------------------------------------------------------------------------------------------
-- Copy Medicare-Analysis Tables as Save Point 4
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS Save4_ma_beneficiarysummary;
DROP TABLE IF EXISTS Save4_ma_carrierclaims;
DROP TABLE IF EXISTS Save4_ma_hcpcs;
DROP TABLE IF EXISTS Save4_ma_icd;
DROP TABLE IF EXISTS Save4_ma_inpatientclaims;
DROP TABLE IF EXISTS Save4_ma_ndc;
DROP TABLE IF EXISTS Save4_ma_outpatientclaims;
DROP TABLE IF EXISTS Save4_ma_rxdrugevents;

CREATE TABLE Save4_ma_beneficiarysummary AS TABLE ma_beneficiarysummary;
CREATE TABLE Save4_ma_carrierclaims AS TABLE ma_carrierclaims;
CREATE TABLE Save4_ma_hcpcs AS TABLE ma_hcpcs;
CREATE TABLE Save4_ma_icd AS TABLE ma_icd;
CREATE TABLE Save4_ma_inpatientclaims AS TABLE ma_inpatientclaims;
CREATE TABLE Save4_ma_ndc AS TABLE ma_ndc;
CREATE TABLE Save4_ma_outpatientclaims AS TABLE ma_outpatientclaims;
CREATE TABLE Save4_ma_rxdrugevents AS TABLE ma_rxdrugevents;


VACUUM FULL ANALYZE;
