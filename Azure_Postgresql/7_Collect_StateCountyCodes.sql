
/*
-----------------------------------------------------------------------------------------------------------------------
    STEP 7

    Standardize SSA state & county codes, correlate with FIPS county codes and incorporate their latitude 
    & longitude coordinates.
    
        Run Time:  1 min with increased compute capacity.

-----------------------------------------------------------------------------------------------------------------------
*/

/*
-- --------------------------------------------------------------------------------------------------------------------
--  Load from the previous save point.
-- --------------------------------------------------------------------------------------------------------------------

-- Only the ma_beneficiarysummary table needs to be reloaded for this file.

DROP TABLE IF EXISTS ma_beneficiarysummary;
CREATE TABLE ma_beneficiarysummary AS TABLE Save6_ma_beneficiarysummary;


-- All the rest of the MA tables from save 6 below in case a full reload is needed.

DROP TABLE IF EXISTS ma_carrierclaims;
DROP TABLE IF EXISTS ma_carrierclaims_lineitems;
DROP TABLE IF EXISTS ma_cc_icd_dgns;
DROP TABLE IF EXISTS ma_hcpcs;
DROP TABLE IF EXISTS ma_ic_icd_dgns;
DROP TABLE IF EXISTS ma_ic_icd_prcdr;
DROP TABLE IF EXISTS ma_icd;
DROP TABLE IF EXISTS ma_inpatientclaims;
DROP TABLE IF EXISTS ma_line_prcsg_ind_cd;
DROP TABLE IF EXISTS ma_ndc;
DROP TABLE IF EXISTS ma_oc_hcpcs;
DROP TABLE IF EXISTS ma_oc_icd_dgns;
DROP TABLE IF EXISTS ma_oc_icd_prcdr;
DROP TABLE IF EXISTS ma_outpatientclaims;
DROP TABLE IF EXISTS ma_rxdrugevents;

CREATE TABLE ma_carrierclaims AS TABLE Save6_ma_carrierclaims;
CREATE TABLE ma_carrierclaims_lineitems AS TABLE Save6_ma_carrierclaims_lineitems;
CREATE TABLE ma_cc_icd_dgns AS TABLE Save6_ma_cc_icd_dgns;
CREATE TABLE ma_hcpcs AS TABLE Save6_ma_hcpcs;
CREATE TABLE ma_ic_icd_dgns AS TABLE Save6_ma_ic_icd_dgns;
CREATE TABLE ma_ic_icd_prcdr AS TABLE Save6_ma_ic_icd_prcdr;
CREATE TABLE ma_icd AS TABLE Save6_ma_icd;
CREATE TABLE ma_inpatientclaims AS TABLE Save6_ma_inpatientclaims;
CREATE TABLE ma_line_prcsg_ind_cd AS TABLE Save6_ma_line_prcsg_ind_cd;
CREATE TABLE ma_ndc AS TABLE Save6_ma_ndc;
CREATE TABLE ma_oc_hcpcs AS TABLE Save6_ma_oc_hcpcs;
CREATE TABLE ma_oc_icd_dgns AS TABLE Save6_ma_oc_icd_dgns;
CREATE TABLE ma_oc_icd_prcdr AS TABLE Save6_ma_oc_icd_prcdr;
CREATE TABLE ma_outpatientclaims AS TABLE Save6_ma_outpatientclaims;
CREATE TABLE ma_rxdrugevents AS TABLE Save6_ma_rxdrugevents;

*/

/*

-- --------------------------------------------------------------------------------------------------------------------
-- Merge state & county codes into a single 5-digit standard state-county SSA code in beneficiary summary.
-- --------------------------------------------------------------------------------------------------------------------

ALTER TABLE ma_beneficiarysummary RENAME COLUMN sp_state_code TO ssa_state_int;
ALTER TABLE ma_beneficiarysummary RENAME COLUMN bene_county_cd TO ssa_county_int;

ALTER TABLE ma_beneficiarysummary ADD COLUMN ssa_state CHAR(2);
ALTER TABLE ma_beneficiarysummary ADD COLUMN ssa_county CHAR(3);

UPDATE ma_beneficiarysummary
SET ssa_state = LPAD(ssa_state_int::CHAR(2), 2, '0'),
    ssa_county = LPAD(ssa_county_int::CHAR(3), 3, '0');
    
UPDATE ma_beneficiarysummary
SET ssa_statecounty = ssa_state || ssa_county;

ALTER TABLE ma_beneficiarysummary DROP COLUMN ssa_state_int;
ALTER TABLE ma_beneficiarysummary DROP COLUMN ssa_county_int;

*/

-- --------------------------------------------------------------------------------------------------------------------
-- Merge the SSA state codes used in the deSynPUF dataset with their latitude and longitude coordinates.
-- --------------------------------------------------------------------------------------------------------------------

ALTER TABLE state_codes ADD COLUMN latitude REAL;
ALTER TABLE state_codes ADD COLUMN longitude REAL;

--  Delete the duplicate entries from state_coordinates that will make it impossible to merge.

DELETE FROM state_coordinates 
WHERE state_coordinates.state_territory = 'PR'
    AND latitude < 0;

DELETE FROM state_coordinates 
WHERE state_coordinates.state_territory = 'DC'
    AND latitude > 38.91;

MERGE INTO state_codes AS sc
USING state_coordinates AS coord
ON sc.state_abbr = coord.state_territory
WHEN MATCHED THEN
    UPDATE SET latitude = coord.latitude,
                longitude = coord.longitude,
                state_name = coord.state_name;


-- Update the latitude and longitude of the 'Other' state code to the geographical center of the continental US.

UPDATE state_codes
SET state_name = 'OTHER', latitude = 39.8283, longitude = -98.5795
WHERE state_code = '54';


-- Double-check that all of the entries in state_codes have lat & long coordinates.

-- SELECT * FROM state_codes
--    WHERE latitude IS NULL;


DROP TABLE IF EXISTS state_coordinates;


-- Double-check that the state_codes table includes all SSA codes used in the deSynPUF dataset.

-- SELECT bs.ssa_state, COUNT(bs.ssa_state) AS count 
-- FROM ma_beneficiarysummary AS bs
-- LEFT JOIN state_codes AS sc
--     ON bs.ssa_state = sc.ssa_state
-- WHERE sc.ssa_state IS NULL
-- GROUP BY bs.ssa_state;

--      RESULT: null


-- --------------------------------------------------------------------------------------------------------------------
--  Merge all the SSA and FIPS county codes with their latitude and longitude coordinates.
-- --------------------------------------------------------------------------------------------------------------------

--  The county lat & long coordinates are in FIPS county codes. We will use the the FIPS to SSA crosswalk 
--     to merge the data into one complete county code table.


--  Merge the FIPS Codes into the SSA county codes table.

ALTER TABLE county_codes ADD COLUMN fips_statecounty VARCHAR;
ALTER TABLE county_codes ADD COLUMN latitude REAL;
ALTER TABLE county_codes ADD COLUMN longitude REAL;


--  Make sure there are no duplicate entries in the crosswalk table or the ssa county codes table.

-- SELECT COUNT(ssacounty), ssacounty FROM county_ssa_fips_crosswalk 
-- GROUP BY ssacounty HAVING COUNT(ssacounty) > 1; 

-- SELECT COUNT(fipscounty), fipscounty FROM county_ssa_fips_crosswalk 
-- GROUP BY fipscounty HAVING COUNT(fipscounty) > 1; 

-- SELECT COUNT(statecounty), statecounty FROM county_codes 
-- GROUP BY statecounty HAVING COUNT(statecounty) > 1; 

MERGE INTO county_codes AS cc
USING county_ssa_fips_crosswalk AS sfc
ON cc.ssa_county_code = sfc.ssacounty
WHEN MATCHED THEN
    UPDATE SET fips_statecounty = sfc.fipscounty;


-- Assess the codes that did not have a match in the crosswalk.

-- SELECT * FROM county_codes
-- WHERE fips_statecounty IS NULL;

-- Most of these are from Alaska. Are there similar codes in the crosswalk?

-- SELECT * FROM county_ssa_fips_crosswalk
-- WHERE state = “AK”;


-- All of the Alaska codes are the same between SSA and FIPS so we can copy the codes over for that state.
    
UPDATE county_codes
    SET fips_statecounty = ssa_county_code
    WHERE county_codes.state_abbr = 'AK'
        AND fips_statecounty IS NULL;
    
DROP TABLE IF EXISTS county_ssa_fips_crosswalk;


-- Merge in the latitude & longitude for each county.
    
MERGE INTO county_codes AS cc
    USING county_coordinates_fips AS ccf
    ON cc.fips_statecounty = ccf.cfips
    WHEN MATCHED THEN
      UPDATE SET latitude = ccf.latitude,
                longitude = ccf.longitude;

    
-- Assess the codes that did not have a latitude & longitude.

-- SELECT * FROM county_codes
-- WHERE latitude IS NULL;

-- It's not very many rows. We'll just ignore them for now.

DROP TABLE IF EXISTS county_coordinates_fips;


-- Separate the SSA state & county codes

ALTER TABLE county_codes RENAME COLUMN ssa_county_code TO ssa_statecounty;
ALTER TABLE county_codes ADD COLUMN ssa_county VARCHAR;
ALTER TABLE county_codes ADD COLUMN ssa_state VARCHAR;

UPDATE county_codes
SET ssa_state = SUBSTRING(ssa_statecounty, 1, 2);

UPDATE county_codes
SET ssa_county = SUBSTRING(ssa_statecounty, 3);


--  Deterine how many ssa_statecounty codes are part of the 'OTHER' designated state 
--    and not defined in ma_countycodes.

SELECT COUNT(*) AS count
FROM ma_beneficiarysummary bs
LEFT JOIN county_codes cc
ON bs.ssa_statecounty = cc.ssa_statecounty
WHERE cc.ssa_statecounty IS NULL
  AND bs.ssa_state = '54';

--    RESULT:  4817


-- Drop the columns that are not relevant for this project.

ALTER TABLE county_codes DROP COLUMN eligibles;
ALTER TABLE county_codes DROP COLUMN enrollees;
ALTER TABLE county_codes DROP COLUMN part_a_aged;
ALTER TABLE county_codes DROP COLUMN part_ab_aged;
ALTER TABLE county_codes DROP COLUMN part_b_aged;
ALTER TABLE county_codes DROP COLUMN penetration;


--  Incorporate the missing ssa_statecounty codes using default information.

INSERT INTO county_codes
SELECT 'OT',              -- state_abbr
      'OTHER',            -- county_name
      bs.ssa_statecounty, -- ssa_statecounty
      bs.ssa_statecounty, -- fips_statecounty   (make same as SSA statecounty)
      39.8283,            -- latitude   (latitude of geographical center of continental US)
      -98.5795,           -- longitude  (longitude of geographical center of continental US)
      bs.ssa_county,      -- ssa_county
      bs.ssa_state        -- ssa_state
FROM ma_beneficiarysummary bs
LEFT JOIN county_codes cc
ON bs.ssa_statecounty = cc.ssa_statecounty
WHERE cc.ssa_statecounty IS NULL
  AND bs.ssa_state = '54'
GROUP BY bs.ssa_statecounty, bs.ssa_state, bs.ssa_county
ORDER BY bs.ssa_statecounty;


--  Deterine how many ssa_statecounty codes are NOT part of the 'OTHER' designated state 
--    and not defined in county_codes.

SELECT COUNT(*) AS count
FROM ma_beneficiarysummary bs
LEFT JOIN county_codes cc
ON bs.ssa_statecounty = cc.ssa_statecounty
WHERE cc.ssa_statecounty IS NULL
  AND bs.ssa_state <> '54';
  
--    RESULT:  92

--  This isnt enough entries to be consequential, considering there are 116,352 distinct patients in the dataset.
--  Incorporate the missing ssa_statecounty codes using similar default information.


INSERT INTO county_codes
SELECT '--',              -- state_abbr
      'UNKNOWN',          -- county_name
      bs.ssa_statecounty, -- ssa_statecounty
      bs.ssa_statecounty, -- fips_statecounty   (make same as SSA statecounty)
      39.8283,            -- latitude   (latitude of geographical center of continental US)
      -98.5795,           -- longitude  (longitude of geographical center of continental US)
      bs.ssa_county,      -- ssa_county
      bs.ssa_state        -- ssa_state
FROM ma_beneficiarysummary bs
LEFT JOIN county_codes cc
ON bs.ssa_statecounty = cc.ssa_statecounty
WHERE cc.ssa_statecounty IS NULL
  AND bs.ssa_state <> '54'
GROUP BY bs.ssa_statecounty, bs.ssa_state, bs.ssa_county
ORDER BY bs.ssa_statecounty;


--  Replace the state_abbr so it is appropriate for the ssa_state code.

UPDATE county_codes cc
SET state_abbr = sc.state_abbr
FROM ma_statecodes sc
WHERE cc.ssa_state = CAST(sc.ssa_state AS CHAR(2))
  AND cc.state_abbr = '--';


-- There are 48 codes with 'xxx' for ssa_county, representing 'Under-11' category. 
--  These are not present in the De-SynPUF dataset. Delete them.

DELETE FROM county_codes 
WHERE ssa_county LIKE '%x%';


-- --------------------------------------------------------------------------------------------------------------------
--  Save the county and state codes tables as part of the Medicare Analysis dataset
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_statecodes;
ALTER TABLE state_codes RENAME TO ma_statecodes;

DROP TABLE IF EXISTS ma_countycodes;
ALTER TABLE county_codes RENAME TO ma_countycodes;


-- --------------------------------------------------------------------------------------------------------------------
--  Copy State & County Code Tables as Save Point 7
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS Save7_ma_statecodes;
DROP TABLE IF EXISTS Save7_ma_countycodes;

CREATE TABLE Save7_ma_statecodes AS TABLE ma_statecodes;
CREATE TABLE Save7_ma_countycodes AS TABLE ma_countycodes;
