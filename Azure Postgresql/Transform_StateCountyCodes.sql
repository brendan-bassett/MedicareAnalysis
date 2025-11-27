

-- --------------------------------------------------------------------------------------------------------------------
--  Merge the SSA state codes used in the deSynPUF dataset with their latitude and longitude coordinates.
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
                longitude = coord.longitude;

-- Update the latitude and longitude of the 'Other' state code to the geographical center of the continental US.

UPDATE state_codes
SET state_name = 'OTHER', latitude = 39.8283, longitude = -98.5795
WHERE state_code = 54;


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


-- Convert SSA state codes to smallint so later comparison is more efficient and standard.

ALTER TABLE state_codes ADD COLUMN ssa_state SMALLINT;

UPDATE state_codes
SET ssa_state = CAST(state_code AS SMALLINT);

ALTER TABLE state_codes DROP COLUMN state_code;

-- Rename the ssa state code column in the Medicare Analysis database 

ALTER TABLE ma_beneficiarysummary RENAME COLUMN sp_state_code TO ssa_state;


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


-- Save the county and state codes tables as part of the Medicare Analysis dataset

DROP TABLE IF EXISTS ma_statecodes;
CREATE TABLE ma_statecodes AS TABLE state_codes;
DROP TABLE IF EXISTS state_codes;

DROP TABLE IF EXISTS ma_countycodes;
CREATE TABLE ma_countycodes AS TABLE county_codes;
DROP TABLE IF EXISTS county_codes;

