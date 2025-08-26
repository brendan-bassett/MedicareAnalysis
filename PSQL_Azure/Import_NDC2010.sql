
-- --------------------------------------------------------------------------------------------------------------------
--  Create NDC 2010 Tables
-- --------------------------------------------------------------------------------------------------------------------

/*

-- SKIP application file. This wont be needed

CREATE TABLE NDC2010_doseform (

    listing_seq_no INT,
    doseform VARCHAR,
    dosage_name VARCHAR
);

CREATE TABLE NDC2010_firms (

    lblcode VARCHAR,
    firm_name VARCHAR,
    addr_header VARCHAR,
    street VARCHAR,
    po_box VARCHAR,
    foreign_addr VARCHAR,
    city VARCHAR,
    state VARCHAR,
    zip VARCHAR,
    province VARCHAR,
    country_name VARCHAR
);

CREATE TABLE NDC2010_formulat (

    listing_seq_no INT,
    strength VARCHAR,
    unit VARCHAR,
    ingredient_name VARCHAR
);

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

-- SKIP registration sites file. This wont be needed

CREATE TABLE NDC2010_routes (

    listing_seq_no INT,
    route_code VARCHAR,
    route_name VARCHAR
);

CREATE TABLE NDC2010_schedule (

    listing_seq_no INT,
    Schedule VARCHAR
);

-- SKIP tbldosage file. This wont be needed
-- SKIP tblroute file. This wont be needed
-- SKIP tblunit file. This wont be needed

*/

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
