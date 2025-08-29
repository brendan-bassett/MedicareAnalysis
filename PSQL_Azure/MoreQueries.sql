
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
