/*
-----------------------------------------------------------------------------------------------------------------------
	STEP 3
    
    Combine the imported NDC, HCPCS, and ICD information into complete tables of each.

    (3 min processing time)
-----------------------------------------------------------------------------------------------------------------------
*/

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Merge the ICD9 included & excluded tables
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS icd9;
CREATE TABLE icd9 (
	
	code VARCHAR UNIQUE, 
	description VARCHAR,
	included BOOLEAN
);

INSERT INTO icd9
SELECT code, description, True 
FROM icd9_included
ON CONFLICT DO NOTHING;

INSERT INTO icd9
SELECT code, description, False 
FROM icd9_excluded
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Merge hcpcs17 and cms_rvu descriptions.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

--  The hcpcs17 dataset has better descriptions, but less codes. The CMS_RVU dataset has more codes, but poorer descriptions. 
--      (see Other_Queries.sql for the comparison)
--  Merge the two datasets into one hcpcs file for the Medicare-Analysis dataset

--      Populate a new hcpcs table with the descriptions from hcpcs17

DROP TABLE IF EXISTS hcpcs;
CREATE TABLE hcpcs (
    hcpcs VARCHAR(5) UNIQUE,
    desc_short VARCHAR,
    desc_long VARCHAR
);

INSERT INTO hcpcs (hcpcs, desc_short, desc_long)
SELECT h.hcpc, h.desc_short, h.desc_long
FROM hcpcs17 h
ON CONFLICT DO NOTHING;

--      Add any additional hcpcs codes and descriptions from cms_rvu that are not already in the description list

INSERT INTO hcpcs (hcpcs, desc_short, desc_long)
SELECT cr.hcpcs, cr.description, cr.description
FROM cms_rvu_2010 cr
ON CONFLICT DO NOTHING;


-- --------------------------------------------------------------------------------------------------------------------
--  Merge 2008 & 2010 & 2012 packages & listings
-- --------------------------------------------------------------------------------------------------------------------

--  merge 2008

DROP TABLE IF EXISTS ndc2008;
CREATE TABLE ndc2008 AS TABLE ndc2008_packages;

ALTER TABLE ndc2008 
ADD COLUMN lblcode VARCHAR;

ALTER TABLE ndc2008 
ADD COLUMN prodcode VARCHAR;

ALTER TABLE ndc2008 
ADD COLUMN strength VARCHAR;

ALTER TABLE ndc2008 
ADD COLUMN unit VARCHAR;

ALTER TABLE ndc2008 
ADD COLUMN rx_otc VARCHAR;

ALTER TABLE ndc2008 
ADD COLUMN tradename VARCHAR;


UPDATE ndc2008 c
SET lblcode = l.lblcode,
    prodcode = l.prodcode,
    strength = l.strength,
    unit = l.unit,
    rx_otc = l.rx_otc,
    tradename = l.tradename
FROM NDC2008_listings l
WHERE c.listing_seq_no = l.listing_seq_no;


SELECT COUNT(*) FROM ndc2008 WHERE prodcode IS NULL;

--      RESULT: 0       There are no missing ndc codes here


--  merge 2010
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ndc2010;
CREATE TABLE ndc2010 AS TABLE ndc2010_packages;

ALTER TABLE ndc2010 
ADD COLUMN lblcode VARCHAR;

ALTER TABLE ndc2010 
ADD COLUMN prodcode VARCHAR;

ALTER TABLE ndc2010 
ADD COLUMN strength VARCHAR;

ALTER TABLE ndc2010 
ADD COLUMN unit VARCHAR;

ALTER TABLE ndc2010 
ADD COLUMN rx_otc VARCHAR;

ALTER TABLE ndc2010 
ADD COLUMN tradename VARCHAR;


UPDATE ndc2010 c
SET lblcode = l.lblcode,
    prodcode = l.prodcode,
    strength = l.strength,
    unit = l.unit,
    rx_otc = l.rx_otc,
    tradename = l.tradename
FROM NDC2010_listings l
WHERE c.listing_seq_no = l.listing_seq_no;


SELECT COUNT(*) FROM ndc2010 WHERE prodcode IS NULL;

--      RESULT: 5           there are still a few rows where the product code is null


--  merge 2012
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ndc2012;
CREATE TABLE ndc2012 AS TABLE ndc2012_packages;

ALTER TABLE ndc2012 
ADD COLUMN lblcode VARCHAR;

ALTER TABLE ndc2012 
ADD COLUMN prodcode VARCHAR;

ALTER TABLE ndc2012 
ADD COLUMN strength VARCHAR;

ALTER TABLE ndc2012 
ADD COLUMN unit VARCHAR;

ALTER TABLE ndc2012 
ADD COLUMN rx_otc VARCHAR;

ALTER TABLE ndc2012 
ADD COLUMN tradename VARCHAR;


UPDATE ndc2012 c
SET lblcode = l.lblcode,
    prodcode = l.prodcode,
    strength = l.strength,
    unit = l.unit,
    rx_otc = l.rx_otc,
    tradename = l.tradename
FROM NDC2012_listings l
WHERE c.listing_seq_no = l.listing_seq_no;


SELECT COUNT(*) FROM ndc2010 WHERE prodcode IS NULL;

--      RESULT: 5           there are still a few rows where the product code is null


-- --------------------------------------------------------------------------------------------------------------------
--  Assemble the complete NDC11 code & descriptions for 2008 & 2010 & 2012
-- --------------------------------------------------------------------------------------------------------------------


--  ndc2008
-- --------------------------------------------------------------------------------------------------------------------

SELECT COUNT(*) FROM ndc2008;

--      RESULT: 148764          TOTAL number of package & product combinations before we clean it up


--  Show that EVERY label code contains an unnecessary leading '0' character.


SELECT * FROM ndc2008 WHERE SUBSTRING(lblcode, 0, 2) <> '0' LIMIT 50;

--      RESULT: NULL

--  Remove the leading zero in NDC label code so the result is a 5-digit code


ALTER TABLE ndc2008 ADD COLUMN lblcode_trimmed VARCHAR;

UPDATE ndc2008
SET lblcode_trimmed = SUBSTRING(lblcode, 2);


--  Many package codes have '*' characters that seem to represent zeros in the NDC11 codes. 
--     See "OtherQueries.sql" for a deeper look at this.

ALTER TABLE ndc2008 ADD COLUMN prodcode_converted VARCHAR;

UPDATE ndc2008
SET prodcode_converted = REPLACE(prodcode, '*', '0');

ALTER TABLE ndc2008 ADD COLUMN pkgcode_converted VARCHAR;

UPDATE ndc2008
SET pkgcode_converted = REPLACE(pkgcode, '*', '0');


--  Remove any rows with missing or unusable NDC codes

DELETE FROM ndc2008
WHERE lblcode_trimmed IS NULL;

DELETE FROM ndc2008
WHERE prodcode_converted IS NULL;

DELETE FROM ndc2008
WHERE pkgcode_converted IS NULL;


DELETE FROM ndc2008
WHERE NOT lblcode_trimmed ~ '^[0-9\.]+$';

DELETE FROM ndc2008
WHERE NOT prodcode_converted ~ '^[0-9\.]+$';

DELETE FROM ndc2008
WHERE NOT pkgcode_converted ~ '^[0-9\.]+$';


DELETE FROM ndc2008
WHERE LENGTH(pkgcode_converted) <> 2;


SELECT COUNT(*) FROM ndc2008;

--      RESULT: 147921          The number of remaining rows
--                                (56 rows were deleted)


--  Assemble the complete NDC11 code & descriptions

ALTER TABLE ndc2008 ADD COLUMN ndc11 VARCHAR;

UPDATE ndc2008
SET ndc11 = lblcode_trimmed || prodcode_converted || pkgcode_converted;


ALTER TABLE ndc2008 ADD COLUMN desc_long VARCHAR;

UPDATE ndc2008
SET desc_long = tradename || ' (' || strength || ' ' || unit || ') - ' || packsize;

--  This leaves a lot of null descriptions. Handle all the cases where the some of the descriptive info is missing.

UPDATE ndc2008
SET desc_long = tradename || ' (' || strength || ' ' || unit || ')'
WHERE packsize IS NULL;

UPDATE ndc2008
SET desc_long = tradename || ' - ' || packsize
WHERE strength IS NULL OR unit IS NULL;

--  Add shortened descriptions.

ALTER TABLE ndc2008 ADD COLUMN desc_short VARCHAR;

UPDATE ndc2008
SET desc_short = tradename
WHERE LENGTH(tradename) <= 29;

UPDATE ndc2008
SET desc_short = SUBSTRING(tradename, 1, 29) || '...'
WHERE LENGTH(tradename) > 29;


--  ndc2010
-- --------------------------------------------------------------------------------------------------------------------

SELECT COUNT(*) FROM ndc2010;

--      RESULT: 172259           TOTAL number of package & product combinations before we clean it up


--  Remove the leading zero in NDC label code so the result is a 5-digit code

ALTER TABLE ndc2010 ADD COLUMN lblcode_trimmed VARCHAR;

UPDATE ndc2010
SET lblcode_trimmed = SUBSTRING(lblcode, 2);


--  Many package codes have '*' characters that seem to represent zeros in the NDC11 codes. 
--     See "OtherQueries.sql" for a deeper look at this.

ALTER TABLE ndc2010 ADD COLUMN prodcode_converted VARCHAR;

UPDATE ndc2010
SET prodcode_converted = REPLACE(prodcode, '*', '0');

ALTER TABLE ndc2010 ADD COLUMN pkgcode_converted VARCHAR;

UPDATE ndc2010
SET pkgcode_converted = REPLACE(pkgcode, '*', '0');


--  Remove any rows with missing or unusable NDC codes

DELETE FROM ndc2010
WHERE lblcode_trimmed IS NULL;

DELETE FROM ndc2010
WHERE prodcode_converted IS NULL;

DELETE FROM ndc2010
WHERE pkgcode_converted IS NULL;


DELETE FROM ndc2010
WHERE NOT lblcode_trimmed ~ '^[0-9\.]+$';

DELETE FROM ndc2010
WHERE NOT prodcode_converted ~ '^[0-9\.]+$';

DELETE FROM ndc2010
WHERE NOT pkgcode_converted ~ '^[0-9\.]+$';


DELETE FROM ndc2010
WHERE LENGTH(pkgcode_converted) <> 2;


SELECT COUNT(*) FROM ndc2010;

--      RESULT: 171384          The number of remaining rows
--                                  (68 rows were deleted)


--  Assemble the complete NDC11 code & descriptions

ALTER TABLE ndc2010 ADD COLUMN ndc11 VARCHAR;

UPDATE ndc2010
SET ndc11 = lblcode_trimmed || prodcode_converted || pkgcode_converted;


ALTER TABLE ndc2010 ADD COLUMN desc_long VARCHAR;

UPDATE ndc2010
SET desc_long = tradename || ' (' || strength || ' ' || unit || ') - ' || packsize;

--  This leaves a lot of null descriptions. Handle all the cases where the some of the descriptive info is missing.

UPDATE ndc2010
SET desc_long = tradename || ' (' || strength || ' ' || unit || ')'
WHERE packsize IS NULL;

UPDATE ndc2010
SET desc_long = tradename || ' - ' || packsize
WHERE strength IS NULL OR unit IS NULL;

--  Add shortened descriptions.

ALTER TABLE ndc2010 ADD COLUMN desc_short VARCHAR;

UPDATE ndc2010
SET desc_short = tradename
WHERE LENGTH(tradename) <= 29;

UPDATE ndc2010
SET desc_short = SUBSTRING(tradename, 1, 29) || '...'
WHERE LENGTH(tradename) > 29;


--  ndc2012
-- --------------------------------------------------------------------------------------------------------------------

SELECT COUNT(*) FROM ndc2012;

--      RESULT: 183464          TOTAL number of package & product combinations before we clean it up


--  Remove the leading zero in NDC label code so the result is a 5-digit code

ALTER TABLE ndc2012 ADD COLUMN lblcode_trimmed VARCHAR;

UPDATE ndc2012
SET lblcode_trimmed = SUBSTRING(lblcode, 2);


--  Many package codes have '*' characters that seem to represent zeros in the NDC11 codes. 
--     See "OtherQueries.sql" for a deeper look at this.


ALTER TABLE ndc2012 ADD COLUMN prodcode_converted VARCHAR;

UPDATE ndc2012
SET prodcode_converted = REPLACE(prodcode, '*', '0');

ALTER TABLE ndc2012 ADD COLUMN pkgcode_converted VARCHAR;

UPDATE ndc2012
SET pkgcode_converted = REPLACE(pkgcode, '*', '0');


--  Remove any rows with missing or unusable NDC codes

DELETE FROM ndc2012
WHERE lblcode_trimmed IS NULL;

DELETE FROM ndc2012
WHERE prodcode_converted IS NULL;

DELETE FROM ndc2012
WHERE pkgcode_converted IS NULL;


DELETE FROM ndc2012
WHERE NOT lblcode_trimmed ~ '^[0-9\.]+$';

DELETE FROM ndc2012
WHERE NOT prodcode_converted ~ '^[0-9\.]+$';

DELETE FROM ndc2012
WHERE NOT pkgcode_converted ~ '^[0-9\.]+$';


DELETE FROM ndc2012
WHERE LENGTH(pkgcode_converted) <> 2;


SELECT COUNT(*) FROM ndc2012;

--      RESULT: 182769          The number of remaining rows
--                                  (57 rows were deleted)


--  Assemble the complete NDC11 code & descriptions

ALTER TABLE ndc2012 ADD COLUMN ndc11 VARCHAR;

UPDATE ndc2012
SET ndc11 = lblcode_trimmed || prodcode_converted || pkgcode_converted;


ALTER TABLE ndc2012 ADD COLUMN desc_long VARCHAR;

UPDATE ndc2012
SET desc_long = tradename || ' (' || strength || ' ' || unit || ') - ' || packsize;

UPDATE ndc2012
SET desc_long = tradename || ' (' || strength || ' ' || unit || ')'
WHERE packsize IS NULL;

UPDATE ndc2012
SET desc_long = tradename || ' - ' || packsize
WHERE strength IS NULL OR unit IS NULL;

--  Add shortened descriptions.

ALTER TABLE ndc2012 ADD COLUMN desc_short VARCHAR;

UPDATE ndc2012
SET desc_short = tradename
WHERE LENGTH(tradename) <= 29;

UPDATE ndc2012
SET desc_short = SUBSTRING(tradename, 1, 29) || '...'
WHERE LENGTH(tradename) > 29;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Convert NDC-10 to NDC-11 in the 2025 & 2018 datasets
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

--  2018 Dataset
-- --------------------------------------------------------------------------------------------------------------------

-- divide the NDC-10 package code into the 3 segments

ALTER TABLE ndc2018_package
ADD seg_1 VARCHAR(5);

UPDATE ndc2018_package
SET seg_1 = SUBSTRING( ndc10 FROM '^[0-9]*') ;


ALTER TABLE ndc2018_package
ADD seg_2 VARCHAR(4);

UPDATE ndc2018_package
SET seg_2 = TRIM(BOTH '-' FROM SUBSTRING( ndc10 FROM '-[0-9]*-'));


ALTER TABLE ndc2018_package
ADD seg_3 VARCHAR(2);

UPDATE ndc2018_package
SET seg_3 = SUBSTRING( ndc10 FROM '[0-9]*$');

-- combine the 3 segments into NDC-11

ALTER TABLE ndc2018_package
ADD COLUMN ndc11 VARCHAR(13);

UPDATE ndc2018_package
SET ndc11 = '0' || seg_1 || seg_2 || seg_3
WHERE LENGTH(seg_1) = 4;

UPDATE ndc2018_package
SET ndc11 = seg_1 || '0' || seg_2 || seg_3
WHERE LENGTH(seg_2) = 3;

UPDATE ndc2018_package
SET ndc11 = seg_1 || seg_2 || '0' || seg_3
WHERE LENGTH(seg_3) = 1;


-- drop all single segment columns that were created for conversion

ALTER TABLE ndc2018_package
DROP COLUMN seg_1;

ALTER TABLE ndc2018_package
DROP COLUMN seg_2;

ALTER TABLE ndc2018_package
DROP COLUMN seg_3;


--  2025 Dataset
-- --------------------------------------------------------------------------------------------------------------------

-- divide the NDC-10 package code into the 3 segments

ALTER TABLE ndc2025_package
ADD seg_1 VARCHAR(5);

UPDATE ndc2025_package
SET seg_1 = SUBSTRING( ndc10 FROM '^[0-9]*') ;


ALTER TABLE ndc2025_package
ADD seg_2 VARCHAR(4);

UPDATE ndc2025_package
SET seg_2 = TRIM(BOTH '-' FROM SUBSTRING( ndc10 FROM '-[0-9]*-'));


ALTER TABLE ndc2025_package
ADD seg_3 VARCHAR(2);

UPDATE ndc2025_package
SET seg_3 = SUBSTRING( ndc10 FROM '[0-9]*$');

-- combine the 3 segments into NDC-11

ALTER TABLE ndc2025_package
ADD COLUMN ndc11 VARCHAR(13);

UPDATE ndc2025_package
SET ndc11 = '0' || seg_1 || seg_2 || seg_3
WHERE LENGTH(seg_1) = 4;

UPDATE ndc2025_package
SET ndc11 = seg_1 || '0' || seg_2 || seg_3
WHERE LENGTH(seg_2) = 3;

UPDATE ndc2025_package
SET ndc11 = seg_1 || seg_2 || '0' || seg_3
WHERE LENGTH(seg_3) = 1;

-- drop all single segment columns that were created for conversion

ALTER TABLE ndc2025_package
DROP COLUMN seg_1;

ALTER TABLE ndc2025_package
DROP COLUMN seg_2;

ALTER TABLE ndc2025_package
DROP COLUMN seg_3;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Assemble the 2025 and 2018 descriptions tables
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE ndc2018_package RENAME COLUMN product_ndc TO ndc8_prod;

DROP TABLE IF EXISTS ndc2018;
CREATE TABLE ndc2018 (
    ndc11 VARCHAR,
    ndc8_prod VARCHAR,
    desc_long VARCHAR
);

INSERT INTO ndc2018
SELECT b.ndc11,
        b.ndc8_prod,
        RTRIM(SPLIT_PART(b.package_description, '(', 1))
FROM ndc2018_package b;


ALTER TABLE ndc2025_package RENAME COLUMN product_ndc TO ndc8_prod;

DROP TABLE IF EXISTS ndc2025;
CREATE TABLE ndc2025 (
    ndc11 VARCHAR,
    ndc8_prod VARCHAR,
    desc_long VARCHAR
);

INSERT INTO ndc2025
SELECT b.ndc11,
        b.ndc8_prod,
        RTRIM(SPLIT_PART(b.package_description, '(', 1))
FROM ndc2025_package b;

--  Combine the product & package descriptions

UPDATE ndc2018 a
SET desc_long = b.proprietary_name || ' - ' || desc_long
FROM ndc2018_product b
WHERE a.ndc8_prod = b.product_ndc;

UPDATE ndc2025 a
SET desc_long = b.proprietary_name || ' - ' || desc_long
FROM ndc2025_product b
WHERE a.ndc8_prod = b.product_ndc;


--  Add shortened descriptions.

ALTER TABLE ndc2018 ADD COLUMN desc_short VARCHAR;

UPDATE ndc2018 a
SET desc_short = b.proprietary_name
FROM ndc2018_product b
WHERE a.ndc8_prod = b.product_ndc
    AND LENGTH(b.proprietary_name) <= 29;

UPDATE ndc2018 a
SET desc_short = SUBSTRING(b.proprietary_name, 1, 29) || '...'
FROM ndc2018_product b
WHERE a.ndc8_prod = b.product_ndc
    AND LENGTH(b.proprietary_name) > 29;


ALTER TABLE ndc2025 ADD COLUMN desc_short VARCHAR;

UPDATE ndc2025 a
SET desc_short = b.proprietary_name
FROM ndc2025_product b
WHERE a.ndc8_prod = b.product_ndc
    AND LENGTH(b.proprietary_name) <= 29;

UPDATE ndc2025 a
SET desc_short = SUBSTRING(b.proprietary_name, 1, 29) || '...'
FROM ndc2025_product b
WHERE a.ndc8_prod = b.product_ndc
    AND LENGTH(b.proprietary_name) > 29;


-- --------------------------------------------------------------------------------------------------------------------
--  Combine all of the NDC information into one complete table
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ndc_combined;
CREATE TABLE ndc_combined (
    ndc11 VARCHAR UNIQUE,
    desc_short VARCHAR,
    desc_long VARCHAR
);

INSERT INTO ndc_combined
SELECT ndc11, desc_short, desc_long
FROM ndc2008
ON CONFLICT (ndc11) DO NOTHING;

INSERT INTO ndc_combined
SELECT ndc11, desc_short, desc_long
FROM ndc2010
ON CONFLICT (ndc11) DO NOTHING;

INSERT INTO ndc_combined
SELECT ndc11, desc_short, desc_long
FROM ndc2012
ON CONFLICT (ndc11) DO NOTHING;

INSERT INTO ndc_combined
SELECT ndc11, desc_short, desc_long
FROM ndc2018
ON CONFLICT (ndc11) DO NOTHING;

INSERT INTO ndc_combined
SELECT ndc11, desc_short, desc_long
FROM ndc2025
ON CONFLICT (ndc11) DO NOTHING;


SELECT ndc11, count(*) AS count FROM ndc_combined GROUP BY ndc11 HAVING count(*) > 1;


-- --------------------------------------------------------------------------------------------------------------------
-- Remove Old, Uneccessary Tables
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ndc2008_listings;
DROP TABLE IF EXISTS ndc2008_packages;
DROP TABLE IF EXISTS ndc2010_listings;
DROP TABLE IF EXISTS ndc2010_packages;
DROP TABLE IF EXISTS ndc2012_listings;
DROP TABLE IF EXISTS ndc2012_packages;

DROP TABLE IF EXISTS ndc2018_package;
DROP TABLE IF EXISTS ndc2018_product;
DROP TABLE IF EXISTS ndc2025_package;
DROP TABLE IF EXISTS ndc2025_product;

DROP TABLE IF EXISTS icd9_excluded;
DROP TABLE IF EXISTS icd9_included;

DROP TABLE IF EXISTS hcpcs17;

DROP TABLE IF EXISTS cms_rvu_2010;

DROP TABLE IF EXISTS ndc2008;
DROP TABLE IF EXISTS ndc2010;
DROP TABLE IF EXISTS ndc2012;
DROP TABLE IF EXISTS ndc2018;
DROP TABLE IF EXISTS ndc2025;


-- --------------------------------------------------------------------------------------------------------------------
--  Save the full NDC, ICD, and HCPCS lists as Save Point 3
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS Save3_hcpcs;
DROP TABLE IF EXISTS Save3_icd9;
DROP TABLE IF EXISTS Save3_ndc;

CREATE TABLE Save3_hcpcs AS TABLE hcpcs;
CREATE TABLE Save3_icd9 AS TABLE icd9;
CREATE TABLE Save3_ndc AS TABLE ndc_combined;
