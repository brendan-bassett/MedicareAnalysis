

/*

-- --------------------------------------------------------------------------------------------------------------------
--  Fill new tables for identifying the asterix issue
-- --------------------------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS ndc2008_asterix;
CREATE TABLE ndc2008_asterix (
    ndc11 VARCHAR,
    lbl_code VARCHAR,
    prod_code VARCHAR,
    pkg_code VARCHAR,
    desc_long VARCHAR
);

DROP TABLE IF EXISTS ndc2010_asterix;
CREATE TABLE ndc2010_asterix (
    ndc11 VARCHAR,
    lbl_code VARCHAR,
    prod_code VARCHAR,
    pkg_code VARCHAR,
    desc_long VARCHAR
);

DROP TABLE IF EXISTS ndc2012_asterix;
CREATE TABLE ndc2012_asterix (
    ndc11 VARCHAR,
    lbl_code VARCHAR,
    prod_code VARCHAR,
    pkg_code VARCHAR,
    desc_long VARCHAR
);

INSERT INTO ndc2008_asterix
SELECT ndc11, lblcode, prodcode, pkgcode, desc_long
    FROM ndc2008
    WHERE NOT prodcode  ~ '^[0-9\.]+$'
        OR NOT pkgcode ~ '^[0-9\.]+$';
        
INSERT INTO ndc2010_asterix
SELECT ndc11, lblcode, prodcode, pkgcode, desc_long
    FROM ndc2010
    WHERE NOT prodcode  ~ '^[0-9\.]+$'
        OR NOT pkgcode ~ '^[0-9\.]+$';
        
INSERT INTO ndc2012_asterix
SELECT ndc11, lblcode, prodcode, pkgcode, desc_long
    FROM ndc2012
    WHERE NOT prodcode  ~ '^[0-9\.]+$'
        OR NOT pkgcode ~ '^[0-9\.]+$';


-- 2018

DROP TABLE IF EXISTS ndc2018_asterix;
CREATE TABLE ndc2018_asterix (
    ndc11 VARCHAR,
    lbl_code VARCHAR,
    prod_code VARCHAR,
    pkg_code VARCHAR,
    desc_long VARCHAR
);

INSERT INTO ndc2018_asterix
SELECT b.ndc11,
    SUBSTRING( b.ndc10 FROM '^[0-9]*'),
    TRIM(BOTH '-' FROM SUBSTRING( b.ndc10 FROM '-[0-9]*-')),
    SUBSTRING( b.ndc10 FROM '[0-9]*$'),
    RTRIM(SPLIT_PART(b.package_description, '(', 1))
FROM ndc2018_package b;

-- --------------------------------------------------------------------------------------------------------------------

-- Identify any codes with asterix where the asterix was later filled in

SELECT a.ndc11, a.lbl_code, b.lbl_code, a.prod_code, b.prod_code, a.pkg_code, b.pkg_code, a.desc_long, b.desc_long
FROM ndc2008_asterix a
INNER JOIN ndc2010_asterix b
ON a.ndc11 = b.ndc11
    AND (a.prod_code <> b.prod_code
        OR a.pkg_code <> b.pkg_code) ;

-- Clearly in all of these cases the single asterix represents a '0' in NDC11

SELECT a.ndc11, a.lbl_code, b.lbl_code, a.prod_code, b.prod_code, a.pkg_code, b.pkg_code, a.desc_long, b.desc_long
FROM ndc2010_asterix a
INNER JOIN ndc2012_asterix b
ON a.ndc11 = b.ndc11
    AND (a.prod_code <> b.prod_code
        OR a.pkg_code <> b.pkg_code) ;

-- Clearly in all of these cases the single asterix represents a '0' in NDC11

SELECT a.ndc11, a.lbl_code, b.lbl_code, a.prod_code, b.prod_code, a.pkg_code, b.pkg_code, a.desc_long, b.desc_long
FROM ndc2012_asterix a
INNER JOIN ndc2018_asterix b
ON a.ndc11 = b.ndc11
    AND (a.prod_code <> b.prod_code
        OR a.pkg_code <> b.pkg_code);
        
-- Even between datasets with very different source formatting, the single asterix in the 2008-2012 datasets represent a '0' in NDC11

-- So then what is the issue with the double-asterixes that created so many duplicates?

SELECT a.ndc11, a.lbl_code, b.lbl_code, a.prod_code, b.prod_code, a.pkg_code, b.pkg_code, a.desc_long, b.desc_long
FROM ndc2008_asterix a
INNER JOIN ndc2010_asterix b
ON a.ndc11 = b.ndc11
    AND a.pkg_code = '**';
        
*/

SELECT * FROM ndc2025_package LIMIT 50;