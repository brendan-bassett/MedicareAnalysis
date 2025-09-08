
-- --------------------------------------------------------------------------------------------------------------------
-- Copy Medicare-Analysis Tables as Save Point
-- --------------------------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS ma2_n;
DROP TABLE IF EXISTS ma2_rde;

ALTER TABLE ma_ndc RENAME TO ma2_n;
ALTER TABLE ma_rxdrugevents RENAME TO ma2_rde;

CREATE TABLE ma_ndc AS TABLE ma2_n;
CREATE TABLE ma_rxdrugevents AS TABLE ma2_rde;

/*

SELECT MAX(Length(desc_long)) FROM ma_hcpcs;
SELECT MAX(Length(desc_long)) FROM ma_icd;


ALTER TABLE ma_hcpcs RENAME COLUMN description TO desc_long;
ALTER TABLE ma_hcpcs ADD COLUMN desc_short;

*/