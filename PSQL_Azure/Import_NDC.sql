

-- --------------------------------------------------------------------------------------------------------------------
--  merge ndc2010_packages and ndc2010_listings
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


--  merge ndc2012_packages and ndc2012_listings
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


-- --------------------------------------------------------------------------------------------------------------------
--  Assemble the complete NDC11 code & descriptions for 2010 and 2012
-- --------------------------------------------------------------------------------------------------------------------

--  Remove the leading zero in NDC label code so the result is a 5-digit code

--  First, show that EVERY label code contains an unnecessary leading '0' character.

SELECT * FROM ndc2010 WHERE SUBSTRING(lblcode, 0, 2) <> '0' LIMIT 50;

--      RESULT: NULL

ALTER TABLE ndc2010 ADD COLUMN lblcode_trimmed VARCHAR;

UPDATE ndc2010
SET lblcode_trimmed = SUBSTRING(lblcode, 2);

--  Many package codes have '*' characters. It is unclear what the significance of these are.
--  For the most part we will assume they can be replaced with zeros.

ALTER TABLE ndc2010 ADD COLUMN prodcode_converted VARCHAR;

UPDATE ndc2010
SET prodcode_converted = REPLACE(prodcode, '*', '0');

ALTER TABLE ndc2010 ADD COLUMN pkgcode_converted VARCHAR;

UPDATE ndc2010
SET pkgcode_converted = REPLACE(pkgcode, '*', '0');

--  Remove any rows with missing or unusable NDC codes

SELECT COUNT(*) FROM ndc2010;

--      RESULT: 172259

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

--  There are quite a few rows where the package code is '**'. These produce a lot of double-entries for NDC11 codes 
--  later on, so we should delete them.

SELECT COUNT(*) FROM ndc2010 WHERE pkgcode = '**';

--      RESULT: 807

DELETE FROM ndc2010
WHERE pkgcode = '**';


SELECT COUNT(*) FROM ndc2010;

--      RESULT: 172191          (68 rows have been deleted OVERALL)

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


--  Assemble ndc2012
-- --------------------------------------------------------------------------------------------------------------------

ALTER TABLE ndc2012 ADD COLUMN lblcode_trimmed VARCHAR;

UPDATE ndc2012
SET lblcode_trimmed = SUBSTRING(lblcode, 2);

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

DELETE FROM ndc2012
WHERE pkgcode = '**';


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


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Convert NDC-10 to NDC-11 in the 2025 & 2018 datasets
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

--  2025 Dataset
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


--  2018 Dataset
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

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Assemble the 2025 and 2018 descriptions tables
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE ndc2018_package RENAME COLUMN product_ndc TO ndc8_prod;
ALTER TABLE ndc2025_package RENAME COLUMN product_ndc TO ndc8_prod;

CREATE TABLE ndc2018 (
    ndc11 VARCHAR,
    ndc8_prod VARCHAR,
    desc_long VARCHAR
);

CREATE TABLE ndc2025 (
    ndc11 VARCHAR,
    ndc8_prod VARCHAR,
    desc_long VARCHAR
);

INSERT INTO ndc2018
SELECT b.ndc11,
        b.ndc8_prod,
        RTRIM(SPLIT_PART(b.package_description, '(', 1))
FROM ndc2018_package b;

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

--  -------------------------------------------------------------------------------------------------------------------
--  Compare the 4 NDC datasets
--  -------------------------------------------------------------------------------------------------------------------

-- Compare the NDC 2010 and 2012 datasets

SELECT COUNT(*) 
    FROM ndc2010 a 
LEFT JOIN ndc2012 b 
    ON a.ndc11 = b.ndc11 
    WHERE b.ndc11 IS NULL;

--      RESULT: 15628       unique ndc values that are in ndc2010 but not ndc2012

SELECT COUNT(*) 
    FROM ndc2012 a 
LEFT JOIN ndc2010 b 
    ON a.ndc11 = b.ndc11 
    WHERE b.ndc11 IS NULL;

--      RESULT: 27012       unique ndc values that are in ndc2012 but not ndc2010

SELECT COUNT(*) 
    FROM ndc2012 a 
INNER JOIN ndc2010 b 
    ON a.ndc11 = b.ndc11;

--      RESULT: 155761       unique ndc values that are in  BOTH ndc2010 and ndc2012

-- Compare the ndc codes which are shared between the 2010 and 2012 datasets, but where the descriptions 
--  are not exactly the same

SELECT a.ndc11, a.desc_long, b.desc_long 
    FROM ndc2010 a 
INNER JOIN ndc2012 b 
    ON a.ndc11 = b.ndc11 
    AND a.desc_long <> b.desc_long;

--  It seems that all the descriptions are pretty similar


-- Compare the NDC 2012 and 2018 datasets
--  -------------------------------------------------------------------------------------------------------------------

SELECT COUNT(*) 
    FROM ndc2012 a 
LEFT JOIN ndc2018 b 
    ON a.ndc11 = b.ndc11 
    WHERE b.ndc11 IS NULL;

--      RESULT: 127387       unique ndc values that are in ndc2012 but not ndc2018

SELECT COUNT(*) 
    FROM ndc2018 a 
LEFT JOIN ndc2012 b 
    ON a.ndc11 = b.ndc11 
    WHERE b.ndc11 IS NULL;

--      RESULT: 353442       unique ndc values that are in ndc2018 but not ndc2012

SELECT COUNT(*) 
    FROM ndc2018 a 
INNER JOIN ndc2012 b 
    ON a.ndc11 = b.ndc11;

--      RESULT: 110764       unique ndc values that are in  BOTH ndc2012 and ndc2018

-- Compare the ndc codes which are shared between the 2012 and 2018 datasets, but where the descriptions 
--  are not exactly the same

SELECT a.ndc11, a.desc_long, b.desc_long 
    FROM ndc2012 a 
INNER JOIN ndc2018 b 
    ON a.ndc11 = b.ndc11 
    AND a.desc_long <> b.desc_long;

--  It seems that all the descriptions are pretty similar


-- Compare the NDC 2018 and 2025 datasets
--  -------------------------------------------------------------------------------------------------------------------

SELECT COUNT(*) 
    FROM ndc2018 a 
LEFT JOIN ndc2025 b 
    ON a.ndc11 = b.ndc11 
    WHERE b.ndc11 IS NULL;

--      RESULT: 342252       unique ndc values that are in ndc2018 but not ndc2025

SELECT COUNT(*) 
    FROM ndc2025 a 
LEFT JOIN ndc2018 b 
    ON a.ndc11 = b.ndc11 
    WHERE b.ndc11 IS NULL;

--      RESULT: 151352       unique ndc values that are in ndc2025 but not ndc2018

SELECT COUNT(*) 
    FROM ndc2025 a 
INNER JOIN ndc2018 b 
    ON a.ndc11 = b.ndc11;

--      RESULT: 121946       unique ndc values that are in  BOTH ndc2018 and ndc2025

-- Compare the ndc codes which are shared between the 2012 and 2018 datasets, but where the descriptions 
--  are not exactly the same

SELECT a.ndc11, a.desc_long, b.desc_long 
    FROM ndc2018 a 
INNER JOIN ndc2025 b 
    ON a.ndc11 = b.ndc11 
    AND a.desc_long <> b.desc_long;

--  It seems that all the descriptions are pretty similar


-- --------------------------------------------------------------------------------------------------------------------
--  Combine all the NDC code & description tables into one combined table
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ndc_combined;

CREATE TABLE ndc_combined (
    ndc11 VARCHAR UNIQUE,
    desc_long VARCHAR
);

INSERT INTO ndc_combined 
SELECT ndc11, desc_long
    FROM ndc2010
ON CONFLICT DO NOTHING;

INSERT INTO ndc_combined 
SELECT ndc11, desc_long
    FROM ndc2012
ON CONFLICT DO NOTHING;

INSERT INTO ndc_combined 
SELECT ndc11, desc_long
    FROM ndc2018
ON CONFLICT DO NOTHING;

INSERT INTO ndc_combined 
SELECT ndc11, desc_long
    FROM ndc2025
ON CONFLICT DO NOTHING;


SELECT COUNT(*) FROM ndc_combined;

--      RESULT: 525299      unique NDCs with descriptions 


-- --------------------------------------------------------------------------------------------------------------------
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
            False	109872
            True	158691

    59 % of the NDC codes referred to in the desynpuf dataset have matching descriptions
*/


-- --------------------------------------------------------------------------------------------------------------------
--  Clean up the extra data
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ndc2010_listings;
DROP TABLE IF EXISTS ndc2012_listings;

DROP TABLE IF EXISTS ndc2010_packages;
DROP TABLE IF EXISTS ndc2012_packages;

DROP TABLE IF EXISTS ndc2018_packages;
DROP TABLE IF EXISTS ndc2025_packages;

DROP TABLE IF EXISTS ndc2018_product;
DROP TABLE IF EXISTS ndc2025_product;


VACUUM FULL ANALYZE;

