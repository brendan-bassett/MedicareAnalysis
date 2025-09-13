/*
-----------------------------------------------------------------------------------------------------------------------
	A collection of various queries that were used to asses the data as it was in the process of preparation.
-----------------------------------------------------------------------------------------------------------------------
*/


-- --------------------------------------------------------------------------------------------------------------------
-- List the 20 most common ICD diagnosis codes used in carrier claims for patients with diabetes.
-- --------------------------------------------------------------------------------------------------------------------

--      We have to create a table for this data so the descriptions can be shown with the icd9 
--          codes without creating issues with the 'group by' statement.

DROP TABLE IF EXISTS cc_icd_diabetes;
CREATE TABLE cc_icd_diabetes (
    icd_count BIGINT,
    icd9 VARCHAR,
    desc_long VARCHAR
);

INSERT INTO cc_icd_diabetes (icd9, icd_count)
SELECT i.icd9, COUNT(i.icd9) as icd_count
FROM ma_beneficiarysummary b 
    INNER JOIN ma_carrierclaims c 
        ON b.bs_id = c.bs_id
    INNER JOIN ma_cc_icd9_dgns d
        ON c.clm_id = d.clm_id
    INNER JOIN ma_icd i
        ON d.icd9_id = i.icd_id
WHERE b.sp_diabetes = True
GROUP BY i.icd9
ORDER BY icd_count DESC
LIMIT 20;

UPDATE cc_icd_diabetes c
SET desc_long = i.desc_long
FROM ma_icd i
WHERE c.icd9 = i.icd9;

SELECT * FROM cc_icd_diabetes;

DROP TABLE IF EXISTS cc_icd_diabetes;

/*
        RESULT:

icd_count   icd9    desc_long

212969	4019	Unspecified essential hypertension
180226	4011	Benign hypertension
125372	25000	Diabetes mellitus without mention of complication, type II or unspecified type, not stated as uncontrolled
116808	2724	Other and unspecified hyperlipidemia
69138	2720	Pure hypercholesterolemia
58206	42731	Atrial fibrillation
49053	2449	Unspecified acquired hypothyroidism
49009	V5869	V5869 - unidentified
48031	78079	Other malaise and fatigue
47403	2859	Anemia, unspecified
43342	4280	Congestive heart failure, unspecified
43144	7295	Pain in limb
40710	496	    Chronic airway obstruction, not elsewhere classified
40038	2722	Mixed hyperlipidemia
37739	41400	Coronary atherosclerosis of unspecified type of vessel, native or graft
37148	78650	Chest pain, unspecified
34132	41401	Coronary atherosclerosis of native coronary artery
33736	7242	Lumbago
31157	V5861	V5861 - unidentified
30476	5990	Urinary tract infection, site not specified

*/

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Merge hcpcs17 and cms_rvu descriptions.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

--      List and count every hcpcs code listed in desynpuf_outpatientclaims that does not correspond to an etry in the hcpcs17 table

SELECT oc.hcpcs_cd_1, COUNT(*) FROM ma_outpatientclaims oc LEFT JOIN hcpcs17 h ON oc.hcpcs_cd_1 = h.hcpc WHERE h.hcpc IS NULL GROUP BY oc.hcpcs_cd_1;

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

SELECT c.hcpcs, c.description, COUNT(*) FROM ma_outpatientclaims oc RIGHT JOIN cms_rvu_2010 c ON oc.hcpcs_cd_1 = c.hcpcs WHERE c.hcpcs IS NULL GROUP BY c.hcpcs, c.description;

--      RESULT: -- no rows --

--      The cms_rvu table has hcpcs descriptions for every code in the Medicare DeSynPUF dataset

--      Just to double-check. Let's count the number of hcpcs codes in the outpatient claims that do not appear in the cms_rvu

SELECT COUNT(*) FROM ma_outpatientclaims oc RIGHT JOIN cms_rvu_2010 c ON oc.hcpcs_cd_1 = c.hcpcs WHERE c.hcpcs IS NULL;

--      RESULT: 0

-- --------------------------------------------------------------------------------------------------------------------
--  Assess how much of the icd9 table covers diagnoses in the DeSynPUF dataset
-- --------------------------------------------------------------------------------------------------------------------

SELECT COUNT(DISTINCT oc.icd9_dgns_cd_1) 
FROM outpatient_claims oc 
LEFT JOIN icd9 i ON oc.icd9_dgns_cd_1 = i.code 
WHERE i.code IS NULL;

--      RESULT: 1357

SELECT COUNT(DISTINCT oc.icd9_dgns_cd_1) 
FROM outpatient_claims oc 
INNER JOIN icd9 i ON oc.icd9_dgns_cd_1 = i.code;

--      RESULT: 9776

--      87.8 % of the diagnoses in the outpatient claims are in the icd9 dataset 

--  -------------------------------------------------------------------------------------------------------------------
--  Compare the 5 NDC datasets
--  -------------------------------------------------------------------------------------------------------------------

-- Compare the NDC 2008 and 2010 datasets

SELECT COUNT(*) 
    FROM ndc2008 a 
LEFT JOIN ndc2010 b 
    ON a.ndc11 = b.ndc11 
    WHERE b.ndc11 IS NULL;

--      RESULT: 9892       unique ndc values that are in ndc2008 but not ndc2010

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

--      RESULT: 155761       unique ndc values that are in  BOTH ndc2008 and ndc2010

-- Compare the ndc codes which are shared between the ndc2008 and 2012 datasets, but where the descriptions 
--  are not exactly the same

SELECT a.ndc11, a.desc_long, b.desc_long 
    FROM ndc2008 a 
INNER JOIN ndc2010 b 
    ON a.ndc11 = b.ndc11 
    AND a.desc_long <> b.desc_long;

--  It seems that all the descriptions are pretty similar


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
--  Assess how much of the hcpcs table covers diagnoses in the DeSynPUF dataset
-- --------------------------------------------------------------------------------------------------------------------

SELECT COUNT(DISTINCT oc.icd9_dgns_cd_1) 
FROM outpatient_claims oc 
LEFT JOIN icd9 i ON oc.icd9_dgns_cd_1 = i.code 
WHERE i.code IS NULL;

--      RESULT: 1357

SELECT COUNT(DISTINCT oc.icd9_dgns_cd_1) 
FROM outpatient_claims oc 
INNER JOIN icd9 i ON oc.icd9_dgns_cd_1 = i.code;

-- --------------------------------------------------------------------------------------------------------------------
--  Assess whether the asterix in the 2008-2012 source data should dependably be converted to zeros
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

-- --------------------------------------------------------------------------------------------------------------------

-- So then what is the issue with the double-asterixes that created so many duplicates?

SELECT a.ndc11, a.lbl_code, b.lbl_code, a.prod_code, b.prod_code, a.pkg_code, b.pkg_code, a.desc_long, b.desc_long
FROM ndc2008_asterix a
INNER JOIN ndc2010_asterix b
ON a.ndc11 = b.ndc11
    AND a.pkg_code = '**';
  
-- It looks like even the double asterix represents a '00' in NDC11. Why is it creating duplicates then?
   
SELECT a.ndc11, a.lbl_code, b.lbl_code, a.prod_code, b.prod_code, a.pkg_code, b.pkg_code, a.desc_long, b.desc_long
FROM ndc2010_asterix a
INNER JOIN ndc2012_asterix b
ON a.ndc11 = b.ndc11
    AND a.pkg_code = '**';

SELECT a.ndc11, a.lbl_code, b.lbl_code, a.prod_code, b.prod_code, a.pkg_code, b.pkg_code, a.desc_long, b.desc_long
FROM ndc2012_asterix a
INNER JOIN ndc2018_asterix b
ON a.ndc11 = b.ndc11
    AND a.pkg_code = '**';
     
-- Create a new table for all of the double-asterix entries so we can identify the ones that do not match with 
--  a code in another NDC dataset

DROP TABLE IF EXISTS ndc_doubleasterix;
CREATE TABLE ndc_doubleasterix (
    ndc11 VARCHAR UNIQUE,
    lbl_code VARCHAR,
    prod_code VARCHAR,
    pkg_code VARCHAR,
    desc_long VARCHAR
);
   
INSERT INTO ndc_doubleasterix
SELECT ndc11, lbl_code, prod_code, pkg_code, desc_long
    FROM ndc2008_asterix
    WHERE pkg_code = '**'
ON CONFLICT DO NOTHING;
        
INSERT INTO ndc_doubleasterix
SELECT ndc11, lbl_code, prod_code, pkg_code, desc_long
    FROM ndc2010_asterix
    WHERE pkg_code = '**'
ON CONFLICT DO NOTHING;

INSERT INTO ndc_doubleasterix
SELECT ndc11, lbl_code, prod_code, pkg_code, desc_long
    FROM ndc2012_asterix
    WHERE pkg_code = '**'
ON CONFLICT DO NOTHING;
  

SELECT a.ndc11, a.lbl_code, a.prod_code, a.pkg_code, a.desc_long
FROM ndc_doubleasterix a
LEFT JOIN ndc_combined c
ON a.ndc11 = c.ndc11
WHERE c.ndc11 IS NULL;
     

SELECT a.ndc11, a.lbl_code, a.prod_code, a.pkg_code, a.desc_long, c.desc_long
FROM ndc_doubleasterix a
INNER JOIN ndc_combined c
ON a.ndc11 = c.ndc11;

-- It looks like most of the double-asterix entries are not creating duplicates. We should convert them to zeros 
--  and keep them in the dataset

-- --------------------------------------------------------------------------------------------------------------------


--  Clean up by deleting all the extra tables we just made

DROP TABLE ndc2008_asterix;
DROP TABLE ndc2010_asterix;
DROP TABLE ndc2012_asterix;
DROP TABLE ndc2018_asterix;

DROP TABLE ndc_doubleasterix;