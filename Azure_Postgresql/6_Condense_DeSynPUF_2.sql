/*
-----------------------------------------------------------------------------------------------------------------------
	STEP 6
    
    Prepare the de-Syn_PUF data for efficient use in Power BI.

    ** PART 2 **

    The original de-Syn-PUF dataset is large and unweildy. If we try to import it into Power BI as-is then it's 
    unusably slow to manipulate. It's also very difficult to create workable relationships.
    
    This involves removing extra columns nad merging tables. Also creating lookup tables for codes such as hcpcs that 
    have multiple columns for the same category of data.

        Summary:
            Merge the two-segment claims within Inpatient Claims.
            Merge the two-segment claims within Outpatient Claims.
            Separate single claim line items from Carrier Claims.
            Correlate NDC codes to Rx Drug Events using an NDC index id.
            Correlate ICD codes to each Medicare Analysis table using an ICD index id.
            Correlate HCPCS codes to each Medicare Analysis table using an HCPCS index id.

        Run Time:  18 min with increased compute capacity.

-----------------------------------------------------------------------------------------------------------------------
*/

/*
-- --------------------------------------------------------------------------------------------------------------------
--  Load from the previous save point.
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_beneficiarysummary;
DROP TABLE IF EXISTS ma_carrierclaims;
DROP TABLE IF EXISTS ma_hcpcs;
DROP TABLE IF EXISTS ma_icd;
DROP TABLE IF EXISTS ma_inpatientclaims;
DROP TABLE IF EXISTS ma_ndc;
DROP TABLE IF EXISTS ma_outpatientclaims;
DROP TABLE IF EXISTS ma_rxdrugevents;

CREATE TABLE ma_beneficiarysummary AS TABLE Save5_ma_beneficiarysummary;
CREATE TABLE ma_carrierclaims AS TABLE Save5_ma_carrierclaims;
CREATE TABLE ma_hcpcs AS TABLE Save5_ma_hcpcs;
CREATE TABLE ma_icd AS TABLE Save5_ma_icd;
CREATE TABLE ma_inpatientclaims AS TABLE Save5_ma_inpatientclaims;
CREATE TABLE ma_ndc AS TABLE Save5_ma_ndc;
CREATE TABLE ma_outpatientclaims AS TABLE Save5_ma_outpatientclaims;
CREATE TABLE ma_rxdrugevents AS TABLE Save5_ma_rxdrugevents;

*/

-- --------------------------------------------------------------------------------------------------------------------
-- Merge the two-segment claims within Inpatient Claims.
-- --------------------------------------------------------------------------------------------------------------------

--      Fill a secondary table with both segments from each two-segment inpatient claim

DROP TABLE IF EXISTS ma_inpatientclaims_seg1;
CREATE TABLE ma_inpatientclaims_seg1 AS TABLE ma_inpatientclaims;

TRUNCATE TABLE ma_inpatientclaims_seg1;

DROP TABLE IF EXISTS ma_inpatientclaims_seg2;
CREATE TABLE ma_inpatientclaims_seg2 AS TABLE ma_inpatientclaims;

TRUNCATE TABLE ma_inpatientclaims_seg2;

INSERT INTO ma_inpatientclaims_seg2
SELECT * FROM ma_inpatientclaims WHERE segment = 2;

INSERT INTO ma_inpatientclaims_seg1
SELECT ma_inpatientclaims.* FROM ma_inpatientclaims
INNER JOIN ma_inpatientclaims_seg2
ON ma_inpatientclaims.clm_id = ma_inpatientclaims_seg2.clm_id 
AND ma_inpatientclaims.segment = 1;

SELECT COUNT(*) FROM ma_inpatientclaims_seg1;
SELECT COUNT(*) FROM ma_inpatientclaims_seg2;

--      RESULT:     68

--      Compare each column side-by-side from segment 1 to segment 2 of each claim


SELECT a.admtng_icd9_dgns_cd, b.admtng_icd9_dgns_cd,
        a.at_physn_npi, b.at_physn_npi,
        a.bs_id, b.bs_id,
        a.clm_admsn_dt, b.clm_admsn_dt,
        a.clm_drg_cd, b.clm_drg_cd,
        a.clm_from_dt, b.clm_from_dt,
        a.clm_id, b.clm_id,
        a.clm_pass_thru_per_diem_amt, b.clm_pass_thru_per_diem_amt,
        a.clm_pmt_amt, b.clm_pmt_amt,
        a.clm_thru_dt, b.clm_thru_dt,
        a.clm_utlztn_day_cnt, b.clm_utlztn_day_cnt,
        a.nch_bene_blood_ddctbl_lblty_am, b.nch_bene_blood_ddctbl_lblty_am,
        a.nch_bene_dschrg_dt, b.nch_bene_dschrg_dt,
        a.nch_bene_ip_ddctbl_amt, b.nch_bene_ip_ddctbl_amt,
        a.nch_bene_pta_coinsrnc_lblty_am, b.nch_bene_pta_coinsrnc_lblty_am,
        a.nch_prmry_pyr_clm_pd_amt, b.nch_prmry_pyr_clm_pd_amt,
        a.op_physn_npi, b.op_physn_npi,
        a.ot_physn_npi, b.ot_physn_npi,
        a.patient_id, b.patient_id,
        a.prvdr_num, b.prvdr_num,
        a.segment, b.segment
FROM ma_inpatientclaims_seg1 a
INNER JOIN ma_inpatientclaims_seg2 b
ON a.clm_id = b.clm_id;


SELECT COUNT(*) FROM ma_inpatientclaims_seg1 a
INNER JOIN ma_inpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num = b.prvdr_num;

--      RESULT:     20

--      There are enought similarities between the majority of these claims that they can all be merged together.


-- Merge all the ICD & HCPCS codes to preserve as much of that information as possible
-- --------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS merge_code;

CREATE OR REPLACE FUNCTION merge_code (
   col_name VARCHAR
)

RETURNS VARCHAR

LANGUAGE plpgsql

AS $$

DECLARE

    s VARCHAR;
	

BEGIN

	s :=  format('UPDATE ma_inpatientclaims_seg1 a '
                    || 'SET %1$I = b.%1$I '
                    || 'FROM ma_inpatientclaims_seg2 b '
                    || 'WHERE a.clm_id = b.clm_id '
                    || 'AND a.prvdr_num = b.prvdr_num '
                    || 'AND NOT a.%1$I IS NULL;',
                col_name);

    EXECUTE s;

	RETURN s;

END
$$;

SELECT merge_code('admtng_icd9_dgns_cd');

SELECT merge_code('icd9_dgns_cd_1');
SELECT merge_code('icd9_dgns_cd_2');
SELECT merge_code('icd9_dgns_cd_3');
SELECT merge_code('icd9_dgns_cd_4');
SELECT merge_code('icd9_dgns_cd_5');
SELECT merge_code('icd9_dgns_cd_6');
SELECT merge_code('icd9_dgns_cd_8');
SELECT merge_code('icd9_dgns_cd_9');
SELECT merge_code('icd9_dgns_cd_10');

SELECT merge_code('icd9_prcdr_cd_1');
SELECT merge_code('icd9_prcdr_cd_2');
SELECT merge_code('icd9_prcdr_cd_3');
SELECT merge_code('icd9_prcdr_cd_4');
SELECT merge_code('icd9_prcdr_cd_5');
SELECT merge_code('icd9_prcdr_cd_6');

--      Merge each two-segment claim into a single segment

DROP TABLE IF EXISTS ma_inpatientclaims_segmerged;
CREATE TABLE ma_inpatientclaims_segmerged AS TABLE ma_inpatientclaims_seg1;

UPDATE ma_inpatientclaims_segmerged
SET clm_admsn_dt = b.clm_admsn_dt,
    nch_bene_dschrg_dt = b.nch_bene_dschrg_dt,
    clm_pmt_amt = a.clm_pmt_amt + b.clm_pmt_amt,        
    nch_prmry_pyr_clm_pd_amt = a.nch_prmry_pyr_clm_pd_amt + b.nch_prmry_pyr_clm_pd_amt,
    clm_pass_thru_per_diem_amt = a.clm_pass_thru_per_diem_amt + b.clm_pass_thru_per_diem_amt,
    nch_bene_ip_ddctbl_amt = b.nch_bene_ip_ddctbl_amt,
    nch_bene_pta_coinsrnc_lblty_am = a.nch_bene_pta_coinsrnc_lblty_am + a.nch_bene_pta_coinsrnc_lblty_am
FROM ma_inpatientclaims_seg1 a
INNER JOIN ma_inpatientclaims_seg2 b
ON a.clm_id = b.clm_id;


--      Delete the corresponding claims from the source table, then add in the merged data

DELETE FROM ma_inpatientclaims
USING ma_inpatientclaims_segmerged
WHERE ma_inpatientclaims.clm_id = ma_inpatientclaims_segmerged.clm_id;

INSERT INTO ma_inpatientclaims
SELECT * FROM ma_inpatientclaims_segmerged;

--      Get rid of the tables used for merging & remove the segment column from the source table

DROP TABLE IF EXISTS ma_inpatientclaims_seg1;
DROP TABLE IF EXISTS ma_inpatientclaims_seg2;
DROP TABLE IF EXISTS ma_inpatientclaims_segmerged;

ALTER TABLE ma_inpatientclaims DROP COLUMN segment;


DROP TABLE IF EXISTS ma_oc_convert;
CREATE TABLE ma_oc_convert AS TABLE ma_outpatientclaims;


-- --------------------------------------------------------------------------------------------------------------------
--  Merge the two-segment claims within Inpatient Claims.
-- --------------------------------------------------------------------------------------------------------------------

--  Both Inpatient and Outpatient claims have multiple segments per claim.
--  While the Inpatient Claims will be merged, the Outpatient Claims may be merged or split depending on the kind 
--  of data they contain. We need to create the claim conversion column here so we can identify each 

--  Create a table that lists the claim_ids with duplicates

DROP TABLE IF EXISTS claim_id_conversion;
CREATE TABLE claim_id_conversion (
    old_claim_id BIGINT,
    c BIGINT
);

INSERT INTO claim_id_conversion
SELECT clm_id, COUNT(*)
FROM ma_outpatientclaims 
GROUP BY clm_id HAVING COUNT(*) > 1;

ALTER TABLE claim_id_conversion DROP COLUMN c;

--  This sequence will increment new claim ids

DROP SEQUENCE IF EXISTS new_clm_id_gen;
CREATE SEQUENCE new_clm_id_gen
START 111000000000000
INCREMENT 1;

ALTER TABLE ma_oc_convert ADD COLUMN new_col_id BIGINT;

UPDATE ma_oc_convert a
SET new_col_id = clm_id;

UPDATE ma_oc_convert a
SET new_col_id = nextval('new_clm_id_gen')
FROM claim_id_conversion b
WHERE a.clm_id = b.old_claim_id;

DROP TABLE IF EXISTS claim_id_conversion;
DROP SEQUENCE IF EXISTS new_clm_id_gen;

--      Now each separate claim & segment has an old_id and new_id in the Outpatient Claims table 


--      Fill secondary tables with respective segments from each two-segment outpatient claim
--  -------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_outpatientclaims_seg2;
CREATE TABLE ma_outpatientclaims_seg2 AS TABLE ma_oc_convert;

TRUNCATE TABLE ma_outpatientclaims_seg2;

INSERT INTO ma_outpatientclaims_seg2
SELECT * FROM ma_oc_convert WHERE segment = 2;

--      RESULT: INSERT 0 11253


DROP TABLE IF EXISTS ma_outpatientclaims_seg1;
CREATE TABLE ma_outpatientclaims_seg1 AS TABLE ma_outpatientclaims_seg2;

TRUNCATE TABLE ma_outpatientclaims_seg1;

INSERT INTO ma_outpatientclaims_seg1
SELECT ma_oc_convert.* FROM ma_oc_convert
INNER JOIN ma_outpatientclaims_seg2
ON ma_oc_convert.clm_id = ma_outpatientclaims_seg2.clm_id 
AND ma_oc_convert.segment = 1;

--      RESULT: INSERT 0 10975

--      There are more segment-2 claims than corresponding segment-1 claims. 
--      Let's take a look at those segment-2 claims which have no segment-1 claim to match

--      Fill secondary tables with respective segments from each two-segment outpatient claim

DROP TABLE IF EXISTS ma_outpatientclaims_nomatch;
CREATE TABLE ma_outpatientclaims_nomatch AS TABLE ma_outpatientclaims_seg2;

INSERT INTO ma_outpatientclaims_nomatch
SELECT * FROM ma_outpatientclaims_seg1;

DELETE FROM ma_outpatientclaims_nomatch
USING ma_outpatientclaims_seg1
WHERE ma_outpatientclaims_nomatch.segment = 2
    AND ma_outpatientclaims_nomatch.clm_id = ma_outpatientclaims_seg1.clm_id;

DELETE FROM ma_outpatientclaims_nomatch
USING ma_outpatientclaims_seg2
WHERE ma_outpatientclaims_nomatch.segment = 1
    AND ma_outpatientclaims_nomatch.clm_id = ma_outpatientclaims_seg2.clm_id;

SELECT * FROM ma_outpatientclaims_nomatch;

--      These have very little relevant information. It seems we can safely drop them from the source table.

DELETE FROM ma_oc_convert
USING ma_outpatientclaims_nomatch
WHERE ma_oc_convert.clm_id = ma_outpatientclaims_nomatch.clm_id;

DELETE FROM ma_outpatientclaims_seg2
USING ma_outpatientclaims_nomatch
WHERE ma_outpatientclaims_seg2.clm_id = ma_outpatientclaims_nomatch.clm_id;

DROP TABLE IF EXISTS ma_outpatientclaims_nomatch;

--      We wont need the old table of converted claim_ids any more. Theyre saved in the ma_outpatientclaims_seg tables

DROP TABLE IF EXISTS ma_oc_convert;


-- Compare segment 1 and segment 2 of each claim and determine how to merge or separate their data.
-- -------------------------------------------------------------------------------------

--      View each column side-by-side from segment 1 to segment 2 of each claim

--      This skips all of the icd and hcpcs codes that will be merged & split accordingly later

SELECT a.clm_id, b.clm_id,
        a.segment, b.segment,
        a.clm_from_dt, b.clm_from_dt,
        a.clm_thru_dt, b.clm_thru_dt,
        a.prvdr_num, b.prvdr_num,
        a.at_physn_npi, b.at_physn_npi,
        a.op_physn_npi, b.op_physn_npi,
        a.ot_physn_npi, b.ot_physn_npi,
        a.bs_id, b.bs_id,
        a.patient_id, b.patient_id,
        a.clm_pmt_amt, b.clm_pmt_amt,
        a.nch_prmry_pyr_clm_pd_amt, b.nch_prmry_pyr_clm_pd_amt,
        a.nch_bene_blood_ddctbl_lblty_am, b.nch_bene_blood_ddctbl_lblty_am,
        a.nch_bene_ptb_ddctbl_amt, b.nch_bene_ptb_ddctbl_amt,
        a.nch_bene_ptb_coinsrnc_amt, b.nch_bene_ptb_coinsrnc_amt,
        a.admtng_icd9_dgns_cd, b.admtng_icd9_dgns_cd
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
LIMIT 500;


SELECT * FROM ma_outpatientclaims_seg2 WHERE NOT clm_from_dt IS NULL;
SELECT * FROM ma_outpatientclaims_seg2 WHERE NOT clm_thru_dt IS NULL;
SELECT * FROM ma_outpatientclaims_seg2 WHERE NOT at_physn_npi IS NULL;
SELECT * FROM ma_outpatientclaims_seg2 WHERE NOT op_physn_npi IS NULL;
SELECT * FROM ma_outpatientclaims_seg2 WHERE NOT ot_physn_npi IS NULL;
SELECT * FROM ma_outpatientclaims_seg2 WHERE NOT admtng_icd9_dgns_cd IS NULL;
SELECT * FROM ma_outpatientclaims_seg2 WHERE NOT bs_id IS NULL;

--      The results of each of those is NULL.

--      Copy over those values from segment 1 of each claim to segment 2

UPDATE ma_outpatientclaims_seg2 a
SET clm_from_dt = b.clm_from_dt,
    clm_thru_dt = b.clm_thru_dt,
    at_physn_npi = b.at_physn_npi,
    op_physn_npi = b.op_physn_npi,
    ot_physn_npi = b.ot_physn_npi,
    admtng_icd9_dgns_cd = b.admtng_icd9_dgns_cd,
    bs_id = b.bs_id
FROM ma_outpatientclaims_seg1 b
WHERE a.clm_id = b.clm_id;


--  Assess prvdr_num
--  -----------------------------------

SELECT  COUNT(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num = b.prvdr_num;

--      RESULT:     3320

--      68% of the 2-segment claims have different provider numbers between the 1st and 2nd segments.
--      We will split these into two respective claims.

--      The other 32% with the same provider numbers will be merged.


--  Assess clm_pmt_amt
--  -----------------------------------

SELECT  COUNT(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.clm_pmt_amt = b.clm_pmt_amt;

--      RESULT:     618

--      We will add these two together for the merged claims, and keep them separate for the separated claims.


--  Assess nch_prmry_pyr_clm_pd_amt
--  -----------------------------------

SELECT  COUNT(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.nch_prmry_pyr_clm_pd_amt = b.nch_prmry_pyr_clm_pd_amt;

--      RESULT:     10875

--      Most claims have the same value for nch_prmry_pyr_clm_pd_amt in both segments.

SELECT  a.nch_prmry_pyr_clm_pd_amt, b.nch_prmry_pyr_clm_pd_amt
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num = b.prvdr_num
    AND a.nch_prmry_pyr_clm_pd_amt <> b.nch_prmry_pyr_clm_pd_amt;

SELECT  count(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num = b.prvdr_num
    AND a.nch_prmry_pyr_clm_pd_amt <> b.nch_prmry_pyr_clm_pd_amt;

--  RESULT:     33

SELECT  count(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num = b.prvdr_num
    AND a.nch_prmry_pyr_clm_pd_amt = b.nch_prmry_pyr_clm_pd_amt
    AND a.nch_prmry_pyr_clm_pd_amt = 0;
    
--  RESULT:     3287

--      For those claims that will be merged based on provider number, the value is either 0 in both or 0 in one 
--      segment and non-zero in the other.

--      That means when we merge claims based on provider number, we can add the values between each segment.

SELECT  count(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num <> b.prvdr_num
    AND a.nch_prmry_pyr_clm_pd_amt <> b.nch_prmry_pyr_clm_pd_amt;

--  RESULT:     67

SELECT  count(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num <> b.prvdr_num
    AND a.nch_prmry_pyr_clm_pd_amt = b.nch_prmry_pyr_clm_pd_amt
    AND a.nch_prmry_pyr_clm_pd_amt = 0;

--  RESULT:     7587

--      The remaining claims that will be separated will keep their respective value for nch_prmry_pyr_clm_pd_amt.


--  Assess nch_bene_blood_ddctbl_lblty_am
--  -----------------------------------

SELECT  COUNT(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.nch_bene_blood_ddctbl_lblty_am = b.nch_bene_blood_ddctbl_lblty_am;

--      RESULT:     10974

SELECT  count(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.nch_bene_blood_ddctbl_lblty_am = 0;
    
--      RESULT:     10975

SELECT  a.clm_id, a.prvdr_num, b.prvdr_num, a.nch_bene_blood_ddctbl_lblty_am, b.nch_bene_blood_ddctbl_lblty_am
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.nch_bene_blood_ddctbl_lblty_am <> b.nch_bene_blood_ddctbl_lblty_am;

--      There is only one claim set with a value for nch_bene_blood_ddctbl_lblty_am that is not 0. 
--      That claim will be separated by prvdr_num so we will keep it separate.


--  Assess nch_bene_ptb_ddctbl_amt
--  -----------------------------------

SELECT  COUNT(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.nch_bene_ptb_ddctbl_amt = b.nch_bene_ptb_ddctbl_amt;

--      RESULT:     10409

SELECT  count(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num = b.prvdr_num
    AND a.nch_bene_ptb_ddctbl_amt <> b.nch_bene_ptb_ddctbl_amt;
    
--      RESULT:     172

--      Of the claims that will be merged based on provider number, there are 172 claims with different amounts 
--      for nch_bene_ptb_ddctbl_amt between segment 1 and 2.

SELECT  a.clm_id, a.prvdr_num, b.prvdr_num, a.nch_bene_ptb_ddctbl_amt, b.nch_bene_ptb_ddctbl_amt
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num = b.prvdr_num
    AND a.nch_bene_ptb_ddctbl_amt <> b.nch_bene_ptb_ddctbl_amt;

SELECT  Count(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num = b.prvdr_num
    AND a.nch_bene_ptb_ddctbl_amt <> b.nch_bene_ptb_ddctbl_amt
    AND a.nch_bene_ptb_ddctbl_amt <> 0
    AND b.nch_bene_ptb_ddctbl_amt <> 0;

--      RESULT:     1

--      Most of them are 0 in one segment, and non-zero in the other.

--      What do we do when we merge the two segments? Do we then keep the higher deductible? Do we flatten both to 0? 
--      Either option truncates information that may be relevant. Within the context of this project, the information 
--      is unlikely to be used anyways. We will keep the higher deductible between the two claims when they are merged.

UPDATE ma_outpatientclaims_seg1 a
SET nch_bene_ptb_ddctbl_amt = b.nch_bene_ptb_ddctbl_amt
FROM ma_outpatientclaims_seg2 b
WHERE a.clm_id = b.clm_id
    AND a.prvdr_num = b.prvdr_num
    AND a.nch_bene_ptb_ddctbl_amt < b.nch_bene_ptb_ddctbl_amt;

--      Now for the merge segment 1 will have the value we will keep.

--      As for the claims that will be separated, we will keep those values separate.


--  Assess nch_bene_ptb_coinsrnc_amt
--  -----------------------------------

SELECT  COUNT(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.nch_bene_ptb_coinsrnc_amt = b.nch_bene_ptb_coinsrnc_amt;

--      RESULT:     1519

--      Most claims have different values for nch_bene_ptb_coinsrnc_amt between segments 1 and 2

SELECT  COUNT(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num = b.prvdr_num
    AND a.nch_bene_ptb_coinsrnc_amt = b.nch_bene_ptb_coinsrnc_amt;

--      RESULT:     464

SELECT  COUNT(*)
    FROM ma_outpatientclaims_seg1 a
INNER JOIN ma_outpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.prvdr_num = b.prvdr_num
    AND a.nch_bene_ptb_coinsrnc_amt <> b.nch_bene_ptb_coinsrnc_amt;

--      RESULT:     2856

--      We will add these two together for the merged claims, and keep them separate for the separated claims.


-- Merge the claims where segments 1 and 2 have the same prvdr_num
-- --------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS merge_code;

CREATE OR REPLACE FUNCTION merge_code (
   col_name VARCHAR
)

RETURNS VARCHAR

LANGUAGE plpgsql

AS $$

DECLARE

    s VARCHAR;
	

BEGIN

	s :=  format('UPDATE ma_outpatientclaims_seg1 a '
                    || 'SET %1$I = b.%1$I '
                    || 'FROM ma_outpatientclaims_seg2 b '
                    || 'WHERE a.clm_id = b.clm_id '
                    || 'AND a.prvdr_num = b.prvdr_num '
                    || 'AND NOT a.%1$I IS NULL;',
                col_name);

    EXECUTE s;

	RETURN s;

END
$$;

SELECT merge_code('admtng_icd9_dgns_cd');

SELECT merge_code('hcpcs_cd_1');
SELECT merge_code('hcpcs_cd_2');
SELECT merge_code('hcpcs_cd_3');
SELECT merge_code('hcpcs_cd_4');
SELECT merge_code('hcpcs_cd_5');
SELECT merge_code('hcpcs_cd_6');
SELECT merge_code('hcpcs_cd_7');
SELECT merge_code('hcpcs_cd_8');
SELECT merge_code('hcpcs_cd_9');
SELECT merge_code('hcpcs_cd_10');
SELECT merge_code('hcpcs_cd_11');
SELECT merge_code('hcpcs_cd_12');
SELECT merge_code('hcpcs_cd_13');
SELECT merge_code('hcpcs_cd_14');
SELECT merge_code('hcpcs_cd_15');
SELECT merge_code('hcpcs_cd_16');
SELECT merge_code('hcpcs_cd_17');
SELECT merge_code('hcpcs_cd_18');
SELECT merge_code('hcpcs_cd_19');
SELECT merge_code('hcpcs_cd_20');
SELECT merge_code('hcpcs_cd_21');
SELECT merge_code('hcpcs_cd_22');
SELECT merge_code('hcpcs_cd_23');
SELECT merge_code('hcpcs_cd_24');
SELECT merge_code('hcpcs_cd_25');
SELECT merge_code('hcpcs_cd_26');
SELECT merge_code('hcpcs_cd_27');
SELECT merge_code('hcpcs_cd_28');
SELECT merge_code('hcpcs_cd_29');
SELECT merge_code('hcpcs_cd_30');
SELECT merge_code('hcpcs_cd_31');
SELECT merge_code('hcpcs_cd_32');
SELECT merge_code('hcpcs_cd_33');
SELECT merge_code('hcpcs_cd_34');
SELECT merge_code('hcpcs_cd_35');
SELECT merge_code('hcpcs_cd_36');
SELECT merge_code('hcpcs_cd_37');
SELECT merge_code('hcpcs_cd_38');
SELECT merge_code('hcpcs_cd_39');
SELECT merge_code('hcpcs_cd_40');
SELECT merge_code('hcpcs_cd_41');
SELECT merge_code('hcpcs_cd_42');
SELECT merge_code('hcpcs_cd_43');
SELECT merge_code('hcpcs_cd_44');
SELECT merge_code('hcpcs_cd_45');

SELECT merge_code('icd9_dgns_cd_1');
SELECT merge_code('icd9_dgns_cd_2');
SELECT merge_code('icd9_dgns_cd_3');
SELECT merge_code('icd9_dgns_cd_4');
SELECT merge_code('icd9_dgns_cd_5');
SELECT merge_code('icd9_dgns_cd_6');
SELECT merge_code('icd9_dgns_cd_8');
SELECT merge_code('icd9_dgns_cd_9');
SELECT merge_code('icd9_dgns_cd_10');

SELECT merge_code('icd9_prcdr_cd_1');
SELECT merge_code('icd9_prcdr_cd_2');
SELECT merge_code('icd9_prcdr_cd_3');
SELECT merge_code('icd9_prcdr_cd_4');
SELECT merge_code('icd9_prcdr_cd_5');
SELECT merge_code('icd9_prcdr_cd_6');

--      For every claim that has the same provider number between both segments, 
--      merge each two-segment claim into a single segment.

DROP TABLE IF EXISTS ma_outpatientclaims_segmerged;
CREATE TABLE ma_outpatientclaims_segmerged AS TABLE ma_outpatientclaims_seg1;

DELETE FROM ma_outpatientclaims_segmerged a
USING ma_outpatientclaims_seg2 b
WHERE a.clm_id = b.clm_id
    AND a.prvdr_num <> b.prvdr_num;

UPDATE ma_outpatientclaims_segmerged a
SET clm_pmt_amt = a.clm_pmt_amt + b.clm_pmt_amt,
    nch_prmry_pyr_clm_pd_amt = a.nch_prmry_pyr_clm_pd_amt + b.nch_prmry_pyr_clm_pd_amt,
    nch_bene_ptb_coinsrnc_amt = a.nch_bene_ptb_coinsrnc_amt + b.nch_bene_ptb_coinsrnc_amt
FROM ma_outpatientclaims_seg2 b
WHERE a.clm_id = b.clm_id;


--      Delete the claims that have been merged from ma_outpatientclaims_seg1 and ma_outpatientclaims_seg2

DELETE FROM ma_outpatientclaims_seg1
USING ma_outpatientclaims_segmerged
WHERE ma_outpatientclaims_seg1.clm_id = ma_outpatientclaims_segmerged.clm_id;

DELETE FROM ma_outpatientclaims_seg2
USING ma_outpatientclaims_segmerged
WHERE ma_outpatientclaims_seg2.clm_id = ma_outpatientclaims_segmerged.clm_id;

--      The remaining claims in ma_outpatientclaims_seg1 and ma_outpatientclaims_seg2 have different provider 
--      numbers between their corresponding claims.


--  Replace all the old claims in ma_outpatientclaims that will be replaced
-- --------------------------------------------------------------------------------------

-- Delete from the original table using the old claim_id

DELETE FROM ma_outpatientclaims
USING ma_outpatientclaims_segmerged
WHERE ma_outpatientclaims.clm_id = ma_outpatientclaims_segmerged.clm_id;

DELETE FROM ma_outpatientclaims
USING ma_outpatientclaims_seg1
WHERE ma_outpatientclaims.clm_id = ma_outpatientclaims_seg1.clm_id;

-- Switch over the formatted claims to the new claim_id

UPDATE ma_outpatientclaims_seg1
SET clm_id = new_col_id;

ALTER TABLE ma_outpatientclaims_seg1
DROP COLUMN new_col_id;


UPDATE ma_outpatientclaims_seg2
SET clm_id = new_col_id;

ALTER TABLE ma_outpatientclaims_seg2
DROP COLUMN new_col_id;


UPDATE ma_outpatientclaims_segmerged
SET clm_id = new_col_id;

ALTER TABLE ma_outpatientclaims_segmerged
DROP COLUMN new_col_id;

-- Move the formatted claims back into the source table

INSERT INTO ma_outpatientclaims
SELECT * FROM ma_outpatientclaims_segmerged;

INSERT INTO ma_outpatientclaims
SELECT * FROM ma_outpatientclaims_seg1;

INSERT INTO ma_outpatientclaims
SELECT * FROM ma_outpatientclaims_seg2;


--      Get rid of the tables used for merging & remove the segment column from the source table
-- --------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_outpatientclaims_seg1;
DROP TABLE IF EXISTS ma_outpatientclaims_seg2;
DROP TABLE IF EXISTS ma_outpatientclaims_segmerged;

ALTER TABLE ma_outpatientclaims DROP COLUMN segment;


-- --------------------------------------------------------------------------------------------------------------------
-- Separate single claim line items from Carrier Claims
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_carrierclaims_lineitems;
CREATE TABLE ma_carrierclaims_lineitems (
    
	 	clm_id BIGINT,
        line SMALLINT,
		prf_physn_npi BIGINT,
		tax_num BIGINT,
		hcpcs_cd VARCHAR, 
		nch_pmt_amt INTEGER,
		bene_ptb_ddctbl_amt INTEGER,
		bene_prmry_pyr_pd_amt INTEGER,
		coinsrnc_amt INTEGER,
		alowd_chrg_amt INTEGER,
		prcsg_ind_cd VARCHAR,
		icd_dgns_cd VARCHAR
);


--  1
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        1, 
        prf_physn_npi_1,
        tax_num_1,
        hcpcs_cd_1,
        line_nch_pmt_amt_1,
		line_bene_ptb_ddctbl_amt_1,
		line_bene_prmry_pyr_pd_amt_1,
		line_coinsrnc_amt_1,
		line_alowd_chrg_amt_1,
		line_prcsg_ind_cd_1,
		line_icd9_dgns_cd_1
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_1 IS NULL
    AND tax_num_1 IS NULL
    AND hcpcs_cd_1 IS NULL
    AND line_nch_pmt_amt_1 = 0
    AND line_bene_ptb_ddctbl_amt_1 = 0
    AND line_bene_prmry_pyr_pd_amt_1 = 0
    AND line_coinsrnc_amt_1 = 0
    AND line_alowd_chrg_amt_1 = 0
    AND line_prcsg_ind_cd_1 IS NULL
    AND line_icd9_dgns_cd_1 IS NULL);

--  2
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        2, 
        prf_physn_npi_2,
        tax_num_2,
        hcpcs_cd_2,
        line_nch_pmt_amt_2,
		line_bene_ptb_ddctbl_amt_2,
		line_bene_prmry_pyr_pd_amt_2,
		line_coinsrnc_amt_2,
		line_alowd_chrg_amt_2,
		line_prcsg_ind_cd_2,
		line_icd9_dgns_cd_2
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_2 IS NULL
    AND tax_num_2 IS NULL
    AND hcpcs_cd_2 IS NULL
    AND line_nch_pmt_amt_2 = 0
    AND line_bene_ptb_ddctbl_amt_2 = 0
    AND line_bene_prmry_pyr_pd_amt_2 = 0
    AND line_coinsrnc_amt_2 = 0
    AND line_alowd_chrg_amt_2 = 0
    AND line_prcsg_ind_cd_2 IS NULL
    AND line_icd9_dgns_cd_2 IS NULL);

--  3
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        3, 
        prf_physn_npi_3,
        tax_num_3,
        hcpcs_cd_3,
        line_nch_pmt_amt_3,
		line_bene_ptb_ddctbl_amt_3,
		line_bene_prmry_pyr_pd_amt_3,
		line_coinsrnc_amt_3,
		line_alowd_chrg_amt_3,
		line_prcsg_ind_cd_3,
		line_icd9_dgns_cd_3
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_3 IS NULL
    AND tax_num_3 IS NULL
    AND hcpcs_cd_3 IS NULL
    AND line_nch_pmt_amt_3 = 0
    AND line_bene_ptb_ddctbl_amt_3 = 0
    AND line_bene_prmry_pyr_pd_amt_3 = 0
    AND line_coinsrnc_amt_3 = 0
    AND line_alowd_chrg_amt_3 = 0
    AND line_prcsg_ind_cd_3 IS NULL
    AND line_icd9_dgns_cd_3 IS NULL);

--  4
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        4, 
        prf_physn_npi_4,
        tax_num_4,
        hcpcs_cd_4,
        line_nch_pmt_amt_4,
		line_bene_ptb_ddctbl_amt_4,
		line_bene_prmry_pyr_pd_amt_4,
		line_coinsrnc_amt_4,
		line_alowd_chrg_amt_4,
		line_prcsg_ind_cd_4,
		line_icd9_dgns_cd_4
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_4 IS NULL
    AND tax_num_4 IS NULL
    AND hcpcs_cd_4 IS NULL
    AND line_nch_pmt_amt_4 = 0
    AND line_bene_ptb_ddctbl_amt_4 = 0
    AND line_bene_prmry_pyr_pd_amt_4 = 0
    AND line_coinsrnc_amt_4 = 0
    AND line_alowd_chrg_amt_4 = 0
    AND line_prcsg_ind_cd_4 IS NULL
    AND line_icd9_dgns_cd_4 IS NULL);

--  5
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        5, 
        prf_physn_npi_5,
        tax_num_5,
        hcpcs_cd_5,
        line_nch_pmt_amt_5,
		line_bene_ptb_ddctbl_amt_5,
		line_bene_prmry_pyr_pd_amt_5,
		line_coinsrnc_amt_5,
		line_alowd_chrg_amt_5,
		line_prcsg_ind_cd_5,
		line_icd9_dgns_cd_5
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_5 IS NULL
    AND tax_num_5 IS NULL
    AND hcpcs_cd_5 IS NULL
    AND line_nch_pmt_amt_5 = 0
    AND line_bene_ptb_ddctbl_amt_5 = 0
    AND line_bene_prmry_pyr_pd_amt_5 = 0
    AND line_coinsrnc_amt_5 = 0
    AND line_alowd_chrg_amt_5 = 0
    AND line_prcsg_ind_cd_5 IS NULL
    AND line_icd9_dgns_cd_5 IS NULL);

--  6
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        6, 
        prf_physn_npi_6,
        tax_num_6,
        hcpcs_cd_6,
        line_nch_pmt_amt_6,
		line_bene_ptb_ddctbl_amt_6,
		line_bene_prmry_pyr_pd_amt_6,
		line_coinsrnc_amt_6,
		line_alowd_chrg_amt_6,
		line_prcsg_ind_cd_6,
		line_icd9_dgns_cd_6
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_6 IS NULL
    AND tax_num_6 IS NULL
    AND hcpcs_cd_6 IS NULL
    AND line_nch_pmt_amt_6 = 0
    AND line_bene_ptb_ddctbl_amt_6 = 0
    AND line_bene_prmry_pyr_pd_amt_6 = 0
    AND line_coinsrnc_amt_6 = 0
    AND line_alowd_chrg_amt_6 = 0
    AND line_prcsg_ind_cd_6 IS NULL
    AND line_icd9_dgns_cd_6 IS NULL);

--  7
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        7, 
        prf_physn_npi_7,
        tax_num_7,
        hcpcs_cd_7,
        line_nch_pmt_amt_7,
		line_bene_ptb_ddctbl_amt_7,
		line_bene_prmry_pyr_pd_amt_7,
		line_coinsrnc_amt_7,
		line_alowd_chrg_amt_7,
		line_prcsg_ind_cd_7,
		line_icd9_dgns_cd_7
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_7 IS NULL
    AND tax_num_7 IS NULL
    AND hcpcs_cd_7 IS NULL
    AND line_nch_pmt_amt_7 = 0
    AND line_bene_ptb_ddctbl_amt_7 = 0
    AND line_bene_prmry_pyr_pd_amt_7 = 0
    AND line_coinsrnc_amt_7 = 0
    AND line_alowd_chrg_amt_7 = 0
    AND line_prcsg_ind_cd_7 IS NULL
    AND line_icd9_dgns_cd_7 IS NULL);

--  8
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        8, 
        prf_physn_npi_8,
        tax_num_8,
        hcpcs_cd_8,
        line_nch_pmt_amt_8,
		line_bene_ptb_ddctbl_amt_8,
		line_bene_prmry_pyr_pd_amt_8,
		line_coinsrnc_amt_8,
		line_alowd_chrg_amt_8,
		line_prcsg_ind_cd_8,
		line_icd9_dgns_cd_8
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_8 IS NULL
    AND tax_num_8 IS NULL
    AND hcpcs_cd_8 IS NULL
    AND line_nch_pmt_amt_8 = 0
    AND line_bene_ptb_ddctbl_amt_8 = 0
    AND line_bene_prmry_pyr_pd_amt_8 = 0
    AND line_coinsrnc_amt_8 = 0
    AND line_alowd_chrg_amt_8 = 0
    AND line_prcsg_ind_cd_8 IS NULL
    AND line_icd9_dgns_cd_8 IS NULL);

--  9
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        9, 
        prf_physn_npi_9,
        tax_num_9,
        hcpcs_cd_9,
        line_nch_pmt_amt_9,
		line_bene_ptb_ddctbl_amt_9,
		line_bene_prmry_pyr_pd_amt_9,
		line_coinsrnc_amt_9,
		line_alowd_chrg_amt_9,
		line_prcsg_ind_cd_9,
		line_icd9_dgns_cd_9
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_9 IS NULL
    AND tax_num_9 IS NULL
    AND hcpcs_cd_9 IS NULL
    AND line_nch_pmt_amt_9 = 0
    AND line_bene_ptb_ddctbl_amt_9 = 0
    AND line_bene_prmry_pyr_pd_amt_9 = 0
    AND line_coinsrnc_amt_9 = 0
    AND line_alowd_chrg_amt_9 = 0
    AND line_prcsg_ind_cd_9 IS NULL
    AND line_icd9_dgns_cd_9 IS NULL);

--  10
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        10, 
        prf_physn_npi_10,
        tax_num_10,
        hcpcs_cd_10,
        line_nch_pmt_amt_10,
		line_bene_ptb_ddctbl_amt_10,
		line_bene_prmry_pyr_pd_amt_10,
		line_coinsrnc_amt_10,
		line_alowd_chrg_amt_10,
		line_prcsg_ind_cd_10,
		line_icd9_dgns_cd_10
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_10 IS NULL
    AND tax_num_10 IS NULL
    AND hcpcs_cd_10 IS NULL
    AND line_nch_pmt_amt_10 = 0
    AND line_bene_ptb_ddctbl_amt_10 = 0
    AND line_bene_prmry_pyr_pd_amt_10 = 0
    AND line_coinsrnc_amt_10 = 0
    AND line_alowd_chrg_amt_10 = 0
    AND line_prcsg_ind_cd_10 IS NULL
    AND line_icd9_dgns_cd_10 IS NULL);

--  11
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        11, 
        prf_physn_npi_11,
        tax_num_11,
        hcpcs_cd_11,
        line_nch_pmt_amt_11,
		line_bene_ptb_ddctbl_amt_11,
		line_bene_prmry_pyr_pd_amt_11,
		line_coinsrnc_amt_11,
		line_alowd_chrg_amt_11,
		line_prcsg_ind_cd_11,
		line_icd9_dgns_cd_11
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_11 IS NULL
    AND tax_num_11 IS NULL
    AND hcpcs_cd_11 IS NULL
    AND line_nch_pmt_amt_11 = 0
    AND line_bene_ptb_ddctbl_amt_11 = 0
    AND line_bene_prmry_pyr_pd_amt_11 = 0
    AND line_coinsrnc_amt_11 = 0
    AND line_alowd_chrg_amt_11 = 0
    AND line_prcsg_ind_cd_11 IS NULL
    AND line_icd9_dgns_cd_11 IS NULL);

--  12
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        12, 
        prf_physn_npi_12,
        tax_num_12,
        hcpcs_cd_12,
        line_nch_pmt_amt_12,
		line_bene_ptb_ddctbl_amt_12,
		line_bene_prmry_pyr_pd_amt_12,
		line_coinsrnc_amt_12,
		line_alowd_chrg_amt_12,
		line_prcsg_ind_cd_12,
		line_icd9_dgns_cd_12
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_12 IS NULL
    AND tax_num_12 IS NULL
    AND hcpcs_cd_12 IS NULL
    AND line_nch_pmt_amt_12 = 0
    AND line_bene_ptb_ddctbl_amt_12 = 0
    AND line_bene_prmry_pyr_pd_amt_12 = 0
    AND line_coinsrnc_amt_12 = 0
    AND line_alowd_chrg_amt_12 = 0
    AND line_prcsg_ind_cd_12 IS NULL
    AND line_icd9_dgns_cd_12 IS NULL);

--  13
-- --------------------------------------------------------------------------------------

INSERT INTO ma_carrierclaims_lineitems
SELECT clm_id, 
        13, 
        prf_physn_npi_13,
        tax_num_13,
        hcpcs_cd_13,
        line_nch_pmt_amt_13,
		line_bene_ptb_ddctbl_amt_13,
		line_bene_prmry_pyr_pd_amt_13,
		line_coinsrnc_amt_13,
		line_alowd_chrg_amt_13,
		line_prcsg_ind_cd_13,
		line_icd9_dgns_cd_13
FROM ma_carrierclaims
WHERE NOT 
    (prf_physn_npi_13 IS NULL
    AND tax_num_13 IS NULL
    AND hcpcs_cd_13 IS NULL
    AND line_nch_pmt_amt_13 = 0
    AND line_bene_ptb_ddctbl_amt_13 = 0
    AND line_bene_prmry_pyr_pd_amt_13 = 0
    AND line_coinsrnc_amt_13 = 0
    AND line_alowd_chrg_amt_13 = 0
    AND line_prcsg_ind_cd_13 IS NULL
    AND line_icd9_dgns_cd_13 IS NULL);


--      Drop the unneeded columns.

ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_1;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_2;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_3;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_4;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_5;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_6;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_7;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_8;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_9;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_10;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_11;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_12;
ALTER TABLE ma_carrierclaims DROP COLUMN prf_physn_npi_13;

ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_1;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_2;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_3;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_4;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_5;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_6;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_7;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_8;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_9;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_10;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_11;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_12;
ALTER TABLE ma_carrierclaims DROP COLUMN tax_num_13;

ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_1;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_2;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_3;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_4;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_5;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_6;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_7;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_8;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_9;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_10;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_11;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_12;
ALTER TABLE ma_carrierclaims DROP COLUMN hcpcs_cd_13;

ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_1;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_2;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_3;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_4;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_5;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_6;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_7;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_8;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_9;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_10;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_11;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_12;
ALTER TABLE ma_carrierclaims DROP COLUMN line_nch_pmt_amt_13;

ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_1;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_2;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_3;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_4;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_5;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_6;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_7;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_8;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_9;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_10;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_11;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_12;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_ptb_ddctbl_amt_13;

ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_1;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_2;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_3;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_4;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_5;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_6;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_7;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_8;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_9;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_10;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_11;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_12;
ALTER TABLE ma_carrierclaims DROP COLUMN line_bene_prmry_pyr_pd_amt_13;

ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_1;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_2;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_3;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_4;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_5;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_6;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_7;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_8;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_9;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_10;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_11;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_12;
ALTER TABLE ma_carrierclaims DROP COLUMN line_coinsrnc_amt_13;

ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_1;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_2;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_3;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_4;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_5;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_6;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_7;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_8;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_9;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_10;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_11;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_12;
ALTER TABLE ma_carrierclaims DROP COLUMN line_alowd_chrg_amt_13;

ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_1;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_2;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_3;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_4;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_5;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_6;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_7;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_8;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_9;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_10;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_11;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_12;
ALTER TABLE ma_carrierclaims DROP COLUMN line_prcsg_ind_cd_13;

ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_1;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_2;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_3;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_4;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_5;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_6;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_7;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_8;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_9;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_10;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_11;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_12;
ALTER TABLE ma_carrierclaims DROP COLUMN line_icd9_dgns_cd_13;


-- --------------------------------------------------------------------------------------------------------------------
--  Correlate NDC codes to Rx Drug Events using an NDC index id.
-- --------------------------------------------------------------------------------------------------------------------

ALTER TABLE ma_rxdrugevents ADD COLUMN ndc11_id INTEGER;

UPDATE ma_rxdrugevents a
SET ndc11_id = b.ndc11_id
FROM ma_ndc b
WHERE a.ndc11 = b.ndc11;

ALTER TABLE ma_rxdrugevents DROP COLUMN ndc11;


-- --------------------------------------------------------------------------------------------------------------------
-- Correlate ICD codes to each Medicare Analysis table using an ICD index id.
-- --------------------------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS correllate_icd;

CREATE OR REPLACE FUNCTION correllate_icd (
   source_table_name VARCHAR,
   dest_table_name VARCHAR,
   source_col_name VARCHAR
)

RETURNS VARCHAR

LANGUAGE plpgsql

AS $$

DECLARE

    s VARCHAR;
	

BEGIN

	s :=  format('INSERT INTO %1$I '
                    || 'SELECT %2$I.%3$I, %5$I.%4$I '
                    || 'FROM %5$I '
                    || 'INNER JOIN %2$I '
                    || 'ON %5$I.%6$I = %2$I.%7$I;',
                dest_table_name,    -- 1
                'ma_icd',           -- 2
                'icd_id',           -- 3
                'clm_id',           -- 4
                source_table_name,  -- 5
                source_col_name,    -- 6
                'icd');            -- 7

    EXECUTE s;

	RETURN s;

END
$$;


-- EXAMPLE:

--         INSERT INTO ma_ic_icd_dgns
--         SELECT ma_icd.icd_id, ma_inpatientclaims.clm_id
--         FROM ma_inpatientclaims
--             INNER JOIN ma_icd
--             ON ma_inpatientclaims.icd_dgns_cd_1 = ma_icd.icd;


-- Inpatient Claims
-- ------------------------------------------------------------------------------------------------

ALTER TABLE ma_inpatientclaims ADD COLUMN admtng_icd_dgns_id INTEGER;

UPDATE ma_inpatientclaims a
SET admtng_icd_dgns_id = b.icd_id
FROM ma_icd b
WHERE a.admtng_icd9_dgns_cd = b.icd;

ALTER TABLE ma_inpatientclaims DROP COLUMN admtng_icd9_dgns_cd;


DROP TABLE IF EXISTS ma_ic_icd_dgns;
CREATE TABLE ma_ic_icd_dgns (
    icd_id INTEGER,
    clm_id BIGINT
);

SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_dgns', 'icd9_dgns_cd_1');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_dgns', 'icd9_dgns_cd_2');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_dgns', 'icd9_dgns_cd_3');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_dgns', 'icd9_dgns_cd_4');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_dgns', 'icd9_dgns_cd_5');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_dgns', 'icd9_dgns_cd_6');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_dgns', 'icd9_dgns_cd_7');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_dgns', 'icd9_dgns_cd_8');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_dgns', 'icd9_dgns_cd_9');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_dgns', 'icd9_dgns_cd_10');

SELECT COUNT(*) FROM ma_ic_icd_dgns;

--      RESULT: 537271

DROP TABLE IF EXISTS ma_ic_icd_prcdr;
CREATE TABLE ma_ic_icd_prcdr (
    icd9_id INTEGER,
    clm_id BIGINT
);

SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_prcdr', 'icd9_prcdr_cd_1');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_prcdr', 'icd9_prcdr_cd_2');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_prcdr', 'icd9_prcdr_cd_3');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_prcdr', 'icd9_prcdr_cd_4');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_prcdr', 'icd9_prcdr_cd_5');
SELECT correllate_icd('ma_inpatientclaims', 'ma_ic_icd_prcdr', 'icd9_prcdr_cd_6');

SELECT COUNT(*) FROM ma_ic_icd_prcdr;

--      RESULT: 95871


ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_1;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_2;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_3;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_4;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_5;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_6;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_7;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_8;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_9;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_dgns_cd_10;

ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_1;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_2;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_3;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_4;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_5;
ALTER TABLE ma_inpatientclaims DROP COLUMN icd9_prcdr_cd_6;


-- Outpatient Claims
-- ------------------------------------------------------------------------------------------------

ALTER TABLE ma_outpatientclaims ADD COLUMN admtng_icd_dgns_id INTEGER;

UPDATE ma_outpatientclaims a
SET admtng_icd_dgns_id = b.icd_id
FROM ma_icd b
WHERE a.admtng_icd9_dgns_cd = b.icd;

ALTER TABLE ma_outpatientclaims DROP COLUMN admtng_icd9_dgns_cd;


DROP TABLE IF EXISTS ma_oc_icd_dgns;
CREATE TABLE ma_oc_icd_dgns (
    icd_id INTEGER,
    clm_id BIGINT
);

SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_dgns', 'icd9_dgns_cd_1');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_dgns', 'icd9_dgns_cd_2');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_dgns', 'icd9_dgns_cd_3');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_dgns', 'icd9_dgns_cd_4');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_dgns', 'icd9_dgns_cd_5');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_dgns', 'icd9_dgns_cd_6');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_dgns', 'icd9_dgns_cd_7');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_dgns', 'icd9_dgns_cd_8');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_dgns', 'icd9_dgns_cd_9');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_dgns', 'icd9_dgns_cd_10');

SELECT COUNT(*) FROM ma_oc_icd_dgns;

--      RESULT: 2073796

ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_1;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_2;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_3;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_4;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_5;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_6;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_7;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_8;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_9;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_dgns_cd_10;


DROP TABLE IF EXISTS ma_oc_icd_prcdr;
CREATE TABLE ma_oc_icd_prcdr (
    icd_id INTEGER,
    clm_id BIGINT
);

SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_prcdr', 'icd9_prcdr_cd_1');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_prcdr', 'icd9_prcdr_cd_2');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_prcdr', 'icd9_prcdr_cd_3');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_prcdr', 'icd9_prcdr_cd_4');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_prcdr', 'icd9_prcdr_cd_5');
SELECT correllate_icd('ma_outpatientclaims', 'ma_oc_icd_prcdr', 'icd9_prcdr_cd_6');

SELECT COUNT(*) FROM ma_oc_icd_prcdr;

--      RESULT: 508

ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_1;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_2;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_3;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_4;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_5;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_6;


-- Carrier Claims
-- ------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_cc_icd_dgns;
CREATE TABLE ma_cc_icd_dgns (
    icd_id INTEGER,
    clm_id BIGINT
);

SELECT correllate_icd('ma_carrierclaims', 'ma_cc_icd_dgns', 'icd9_dgns_cd_1');
SELECT correllate_icd('ma_carrierclaims', 'ma_cc_icd_dgns', 'icd9_dgns_cd_2');
SELECT correllate_icd('ma_carrierclaims', 'ma_cc_icd_dgns', 'icd9_dgns_cd_3');
SELECT correllate_icd('ma_carrierclaims', 'ma_cc_icd_dgns', 'icd9_dgns_cd_4');
SELECT correllate_icd('ma_carrierclaims', 'ma_cc_icd_dgns', 'icd9_dgns_cd_5');
SELECT correllate_icd('ma_carrierclaims', 'ma_cc_icd_dgns', 'icd9_dgns_cd_6');
SELECT correllate_icd('ma_carrierclaims', 'ma_cc_icd_dgns', 'icd9_dgns_cd_7');
SELECT correllate_icd('ma_carrierclaims', 'ma_cc_icd_dgns', 'icd9_dgns_cd_8');

SELECT COUNT(*) FROM ma_cc_icd_dgns;

--      RESULT: 10122005

ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_1;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_2;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_3;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_4;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_5;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_6;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_7;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_8;


-- Carrier Claims - Line Items
-- ------------------------------------------------------------------------------------------------

ALTER TABLE ma_carrierclaims_lineitems ADD COLUMN icd_dgns_id INTEGER;


UPDATE ma_carrierclaims_lineitems a
SET icd_dgns_id = b.icd_id
FROM ma_icd b
WHERE a.icd_dgns_cd = b.icd;

ALTER TABLE ma_carrierclaims_lineitems DROP COLUMN icd_dgns_cd;


-- --------------------------------------------------------------------------------------------------------------------
--  Correlate HCPCS codes to each Medicare Analysis table using an HCPCS index id.
-- --------------------------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS correllate_hcpcs;

CREATE OR REPLACE FUNCTION correllate_hcpcs (
   source_table_name VARCHAR,
   dest_table_name VARCHAR,
   source_col_name VARCHAR
)

RETURNS VARCHAR

LANGUAGE plpgsql

AS $$

DECLARE

    s VARCHAR;
	

BEGIN

	s :=  format('INSERT INTO %1$I '
                    || 'SELECT %2$I.%3$I, %5$I.%4$I '
                    || 'FROM %5$I '
                    || 'INNER JOIN %2$I '
                    || 'ON %5$I.%6$I = %2$I.%7$I;',
                dest_table_name,    -- 1
                'ma_hcpcs',         -- 2
                'hcpcs_id',         -- 3
                'clm_id',           -- 4
                source_table_name,  -- 5
                source_col_name,    -- 6
                'hcpcs');           -- 7

    EXECUTE s;

	RETURN s;

END
$$;


-- EXAMPLE:

--        INSERT INTO ma_ic_hcpcs 
--        SELECT ma_hcpcs.hcpcs_id, ma_inpatientclaims.clm_id 
--        FROM ma_inpatientclaims 
--        INNER JOIN ma_hcpcs 
--        ON ma_inpatientclaims.hcpcs_cd_1 = ma_hcpcs.hcpcs;


-- Inpatient Claims
-- ------------------------------------------------------------------------------------------------

--      THERE ARE NO HCPCS CODES ASSOCIATED WITH INPATIENT CLAIMS. This has been verified with the source CSV data.

--      We can drop the ma_ic_hcpcs table entirely because it has no purpose.



-- Outpatient Claims
-- ------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_oc_hcpcs;
CREATE TABLE ma_oc_hcpcs (
    hcpcs_id INTEGER,
    clm_id BIGINT
);

SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_1');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_2');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_3');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_4');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_5');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_6');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_7');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_8');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_9');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_10');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_11');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_12');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_13');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_14');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_15');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_16');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_17');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_18');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_19');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_20');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_21');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_22');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_23');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_24');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_25');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_26');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_27');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_28');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_29');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_30');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_31');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_32');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_33');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_34');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_35');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_36');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_37');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_38');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_39');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_40');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_41');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_42');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_43');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_44');
SELECT correllate_hcpcs('ma_outpatientclaims', 'ma_oc_hcpcs', 'hcpcs_cd_45');

SELECT COUNT(*) FROM ma_oc_hcpcs;

--      RESULT: 3774339

ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_1;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_2;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_3;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_4;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_5;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_6;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_7;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_8;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_9;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_10;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_11;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_12;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_13;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_14;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_15;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_16;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_17;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_18;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_19;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_20;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_21;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_22;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_23;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_24;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_25;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_26;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_27;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_28;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_29;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_30;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_31;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_32;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_33;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_34;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_35;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_36;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_37;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_38;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_39;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_40;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_41;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_42;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_43;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_44;
ALTER TABLE ma_outpatientclaims DROP COLUMN hcpcs_cd_45;


-- Carrier Claims - Line Items
-- ------------------------------------------------------------------------------------------------

ALTER TABLE ma_carrierclaims_lineitems ADD COLUMN hcpcs_id INTEGER;

UPDATE ma_carrierclaims_lineitems a
SET hcpcs_id = b.hcpcs_id
FROM ma_hcpcs b
WHERE a.hcpcs_cd = b.hcpcs;

ALTER TABLE ma_carrierclaims_lineitems DROP COLUMN hcpcs_cd;

-- --------------------------------------------------------------------------------------------------------------------
-- Copy Medicare-Analysis Tables as Save Point 6
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS Save6_ma_beneficiarysummary;
DROP TABLE IF EXISTS Save6_ma_carrierclaims;
DROP TABLE IF EXISTS Save6_ma_carrierclaims_lineitems;
DROP TABLE IF EXISTS Save6_ma_cc_icd_dgns;
DROP TABLE IF EXISTS Save6_ma_hcpcs;
DROP TABLE IF EXISTS Save6_ma_ic_icd_dgns;
DROP TABLE IF EXISTS Save6_ma_ic_icd_prcdr;
DROP TABLE IF EXISTS Save6_ma_icd;
DROP TABLE IF EXISTS Save6_ma_inpatientclaims;
DROP TABLE IF EXISTS Save6_ma_line_prcsg_ind_cd;
DROP TABLE IF EXISTS Save6_ma_ndc;
DROP TABLE IF EXISTS Save6_ma_oc_hcpcs;
DROP TABLE IF EXISTS Save6_ma_oc_icd_dgns;
DROP TABLE IF EXISTS Save6_ma_oc_icd_prcdr;
DROP TABLE IF EXISTS Save6_ma_outpatientclaims;
DROP TABLE IF EXISTS Save6_ma_rxdrugevents;


CREATE TABLE Save6_ma_beneficiarysummary AS TABLE ma_beneficiarysummary;
CREATE TABLE Save6_ma_carrierclaims AS TABLE ma_carrierclaims;
CREATE TABLE Save6_ma_carrierclaims_lineitems AS TABLE ma_carrierclaims_lineitems;
CREATE TABLE Save6_ma_cc_icd_dgns AS TABLE ma_cc_icd_dgns;
CREATE TABLE Save6_ma_hcpcs AS TABLE ma_hcpcs;
CREATE TABLE Save6_ma_ic_icd_dgns AS TABLE ma_ic_icd_dgns;
CREATE TABLE Save6_ma_ic_icd_prcdr AS TABLE ma_ic_icd_prcdr;
CREATE TABLE Save6_ma_icd AS TABLE ma_icd;
CREATE TABLE Save6_ma_inpatientclaims AS TABLE ma_inpatientclaims;
CREATE TABLE Save6_ma_line_prcsg_ind_cd AS TABLE ma_line_prcsg_ind_cd;
CREATE TABLE Save6_ma_ndc AS TABLE ma_ndc;
CREATE TABLE Save6_ma_oc_hcpcs AS TABLE ma_oc_hcpcs;
CREATE TABLE Save6_ma_oc_icd_dgns AS TABLE ma_oc_icd_dgns;
CREATE TABLE Save6_ma_oc_icd_prcdr AS TABLE ma_oc_icd_prcdr;
CREATE TABLE Save6_ma_outpatientclaims AS TABLE ma_outpatientclaims;
CREATE TABLE Save6_ma_rxdrugevents AS TABLE ma_rxdrugevents;

-- --------------------------------------------------------------------------------------------------------------------
-- Run cleanup of dead tuples & maximize efficiency
-- --------------------------------------------------------------------------------------------------------------------

VACUUM FULL ANALYZE;
