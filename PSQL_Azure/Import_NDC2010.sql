

-- --------------------------------------------------------------------------------------------------------------------
--  Create NDC 2010 & 2012 Tables
-- --------------------------------------------------------------------------------------------------------------------

CREATE TABLE NDC2010_listings (

    listing_seq_no INT,
    lblcode VARCHAR,
    prodcode VARCHAR,
    strength VARCHAR,
    unit VARCHAR,
    rx_otc VARCHAR,
    tradename VARCHAR
);

CREATE TABLE NDC2010_packages (

    listing_seq_no INT,
    pkgcode VARCHAR,
    packsize VARCHAR,
    packtype VARCHAR
);

CREATE TABLE NDC2012_listings (

    listing_seq_no INT,
    lblcode VARCHAR,
    prodcode VARCHAR,
    strength VARCHAR,
    unit VARCHAR,
    rx_otc VARCHAR,
    tradename VARCHAR
);

CREATE TABLE NDC2012_packages (

    listing_seq_no INT,
    pkgcode VARCHAR,
    packsize VARCHAR,
    packtype VARCHAR
);

-- --------------------------------------------------------------------------------------------------------------------
--  merge ndc2010_packages and ndc2010_listings
-- --------------------------------------------------------------------------------------------------------------------

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
--  Assemble the complete NDC11 code & descriptions
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


-- --------------------------------------------------------------------------------------------------------------------
--  Sort throught the NDC codes in the DeSynPUF database that can be identified, and the ones that cant
-- --------------------------------------------------------------------------------------------------------------------

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
SELECT COUNT(DISTINCT ndc11) FROM ndc_nomatch;


ALTER TABLE ndc_matches DROP COLUMN id;
ALTER TABLE ndc_nomatch DROP COLUMN id;


--  Reconcile the remaining ndc codes that have not matched, using the 2025 dataset.

INSERT INTO ndc_matches
SELECT nm.ndc11, n.package_description
FROM ndc_nomatch nm
INNER JOIN ndc2025_package n
ON nm.ndc11 = n.ndc_package11;

DELETE FROM ndc_nomatch nm
USING ndc_matches m
WHERE nm.ndc11 = m.ndc11;

SELECT COUNT(*) FROM ndc_matches;

--  RESULT: 144490

SELECT COUNT(*) FROM ndc_nomatch;

--  RESULT: 124073