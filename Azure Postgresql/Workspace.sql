--  Merge the state coordinates into the state codes table.

ALTER TABLE ma_statecodes ADD COLUMN latitude REAL;
ALTER TABLE ma_statecodes ADD COLUMN longitude REAL;

--  Delete the duplicate entries from state_coordinates that will make it impossible to merge.

DELETE FROM state_coordinates 
WHERE state_coordinates.state_territory = 'PR'
    AND latitude = -66.10572;

DELETE FROM state_coordinates 
WHERE state_coordinates.state_territory = 'DC'
    AND latitude = 38.942142;

MERGE INTO ma_statecodes
USING state_coordinates
ON ma_statecodes.abbreviation = state_coordinates.state_territory
WHEN MATCHED THEN
  UPDATE SET ma_statecodes.latitude = state_coordinates.latitude,
             ma_statecodes.longitude = state_coordinates.longitude;

SELECT * FROM ma_statecodes
WHERE latitude IS NULL;

DROP TABLE IF EXISTS state_coordinates;


-- ---------------------------------------------------------------------------------------------------------------------------

--  Merge the FIPS Codes into the SSA county codes table.

ALTER TABLE ma_countycodes ADD COLUMN fips_statecounty INT;
ALTER TABLE ma_countycodes ADD COLUMN latitude DOUBLE;
ALTER TABLE ma_countycodes ADD COLUMN longitude DOUBLE;

--  Make sure there are no duplicate entries in the crosswalk table or the ssa county codes table.

-- SELECT COUNT(ssacounty), ssacounty FROM county_ssa_fips_crosswalk GROUP BY ssacounty HAVING COUNT(ssacounty) > 1; 
-- SELECT COUNT(fipscounty), fipscounty FROM county_ssa_fips_crosswalk GROUP BY fipscounty HAVING COUNT(fipscounty) > 1; 
-- SELECT COUNT(ssa_statecounty), ssa_statecounty FROM ma_countycodes GROUP BY ssa_statecounty HAVING COUNT(ssa_statecounty) > 1; 

MERGE INTO ma_countycodes AS cc
USING county_ssa_fips_crosswalk AS sfc
ON cc.ssa_statecounty = sfc.ssacounty
WHEN MATCHED THEN
  UPDATE SET cc.fips_statecounty = sfc.fipscounty;

-- Assess the codes that did not have a match in the crosswalk.

-- SELECT * FROM ma_countycodes
-- WHERE fips_statecounty IS NULL;

-- Most of these are from Alaska. Are there similar codes in the crosswalk?

-- SELECT * FROM county_ssa_fips_crosswalk
-- WHERE ssastate = 2;

-- All of the Alaska codes are the same from SSA to FIPS so we can copy the codes over for that state.

UPDATE ma_countycodes
SET fips_statecounty = ssa_statecounty
WHERE fips_statecounty IS NULL
    AND ssa_state = 2;

DROP TABLE IF EXISTS county_ssa_fips_crosswalk;

-- Merge in the latitude & longitude for each county.

MERGE INTO ma_countycodes AS cc
USING county_coordinates_fips AS ccf
ON cc.fips_statecounty = ccf.cfips
WHEN MATCHED THEN
  UPDATE SET cc.latitude = ccf.lat,
             cc.longitude = ccf.lng;

-- Assess the codes that did not have a latitude & longitude.

-- SELECT * FROM ma_countycodes
-- WHERE latitude IS NULL;

-- It's not very many rows. We'll just ignore them for now.

DROP TABLE IF EXISTS county_coordinates_fips;



     
