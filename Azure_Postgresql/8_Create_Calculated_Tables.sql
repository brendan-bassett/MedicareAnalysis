
/*
-----------------------------------------------------------------------------------------------------------------------
    STEP 8

    Create metatables that determine overall trends in the DeSynPUF dataset.

-----------------------------------------------------------------------------------------------------------------------
*/

-- --------------------------------------------------------------------------------------------------------------------
--  Count the number of patients in each state & county
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS patients_by_state;
CREATE TABLE patients_by_state (
  pt_count INT,
  state_name VARCHAR, 
  ssa_state CHAR(2),
  latitude REAL,
  longitude REAL
);


INSERT INTO patients_by_state
SELECT COUNT(DISTINCT patient_id) AS pt_count, 
        s.state_name, s.ssa_state, s.latitude, s.longitude
FROM ma_beneficiarysummary AS bs
INNER JOIN ma_statecodes AS s
ON bs.ssa_state = s.ssa_state
GROUP BY s.state_name, s.ssa_state, s.latitude, s.longitude
ORDER BY pt_count DESC;

-- ----------------------------------------------------------

-- Ensure that the majority of the county codes in ma_beneficiarysummaries are also in the ma_countycodes table.

SELECT COUNT(DISTINCT ssa_statecounty) FROM ma_beneficiarysummary;

--      RESULT: 3088

SELECT COUNT(DISTINCT ma_beneficiarysummary.ssa_statecounty) FROM ma_beneficiarysummary
LEFT JOIN ma_countycodes 
ON ma_beneficiarysummary.ssa_statecounty = ma_countycodes.ssa_statecounty
WHERE ma_countycodes.ssa_statecounty IS NULL;

--      RESULT: 0

--  Most county codes in the ma_beneficiarysummary table are also in the ma_countycodes table.


DROP TABLE IF EXISTS patients_by_counties;
CREATE TABLE patients_by_counties (
  pt_count INT,
  county_name VARCHAR, 
  state_abbr VARCHAR, 
  latitude REAL,
  longitude REAL
);

INSERT INTO patients_by_counties
SELECT COUNT(DISTINCT patient_id) AS pt_count, c.county_name, c.state_abbr, c.latitude, c.longitude
FROM ma_beneficiarysummary AS bs
INNER JOIN ma_countycodes AS c
ON bs.ssa_statecounty = c.ssa_statecounty
GROUP BY c.county_name, c.state_abbr, c.latitude, c.longitude
ORDER BY pt_count DESC;


-- --------------------------------------------------------------------------------------------------------------------
--  Incorporate Data for Chronic Conditions
-- --------------------------------------------------------------------------------------------------------------------

ALTER TABLE patients_by_state ADD COLUMN ct_alzhdmta INT;
ALTER TABLE patients_by_state ADD COLUMN ct_chrnkidn INT;
ALTER TABLE patients_by_state ADD COLUMN ct_cncr INT;
ALTER TABLE patients_by_state ADD COLUMN ct_copd INT;
ALTER TABLE patients_by_state ADD COLUMN ct_depressn INT;
ALTER TABLE patients_by_state ADD COLUMN ct_diabetes INT;
ALTER TABLE patients_by_state ADD COLUMN ct_ischmcht INT;
ALTER TABLE patients_by_state ADD COLUMN ct_osteoprs INT;
ALTER TABLE patients_by_state ADD COLUMN ct_ra_oa INT;
ALTER TABLE patients_by_state ADD COLUMN ct_strketia INT;

ALTER TABLE patients_by_state ADD COLUMN per_alzhdmta DECIMAL(10, 2);
ALTER TABLE patients_by_state ADD COLUMN per_chrnkidn DECIMAL(10, 2);
ALTER TABLE patients_by_state ADD COLUMN per_cncr DECIMAL(10, 2);
ALTER TABLE patients_by_state ADD COLUMN per_copd DECIMAL(10, 2);
ALTER TABLE patients_by_state ADD COLUMN per_depressn DECIMAL(10, 2);
ALTER TABLE patients_by_state ADD COLUMN per_diabetes DECIMAL(10, 2);
ALTER TABLE patients_by_state ADD COLUMN per_ischmcht DECIMAL(10, 2);
ALTER TABLE patients_by_state ADD COLUMN per_osteoprs DECIMAL(10, 2);
ALTER TABLE patients_by_state ADD COLUMN per_ra_oa DECIMAL(10, 2);
ALTER TABLE patients_by_state ADD COLUMN per_strketia DECIMAL(10, 2);

MERGE INTO patients_by_state AS pbs
USING
  (SELECT COUNT(DISTINCT patient_id) AS pt_count, 
        s.ssa_state
  FROM ma_beneficiarysummary AS bs
  INNER JOIN ma_statecodes AS s
  ON bs.ssa_state = s.ssa_state
  WHERE bs.sp_alzhdmta IS TRUE
  GROUP BY s.ssa_state)
  AS source
ON source.ssa_state = pbs.ssa_state
WHEN MATCHED THEN UPDATE SET
    ct_alzhdmta = source.pt_count;

UPDATE patients_by_state
SET per_alzhdmta = ct_alzhdmta::FLOAT / pt_count * 100;

SELECT state_name, pt_count, ct_alzhdmta, per_alzhdmta
FROM patients_by_state
ORDER BY per_alzhdmta DESC;

