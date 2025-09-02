/*
-----------------------------------------------------------------------------------------------------------------------
	Format the Inpatient and Outpatient claims that are split between multiple segments

    Some information from segments 1 and 2 must be combined, and some should be split. However, 

-----------------------------------------------------------------------------------------------------------------------
*/


-- --------------------------------------------------------------------------------------------------------------------
-- Recover Medicare Analysis Tables from save point at end of Condense_DeSynPUF_2.sql
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_beneficiarysummary;
DROP TABLE IF EXISTS ma_carrierclaims;
DROP TABLE IF EXISTS ma_carrierclaims_lineitems;
DROP TABLE IF EXISTS ma_cc_icd9_dgns;
DROP TABLE IF EXISTS ma_countycodes;
DROP TABLE IF EXISTS ma_hcpcs;
DROP TABLE IF EXISTS ma_ic_icd9_dgns;
DROP TABLE IF EXISTS ma_ic_icd9_prcdr;
DROP TABLE IF EXISTS ma_icd;
DROP TABLE IF EXISTS ma_inpatientclaims;
DROP TABLE IF EXISTS ma_line_prcsg_ind_cd;
DROP TABLE IF EXISTS ma_ndc;
DROP TABLE IF EXISTS ma_oc_hcpcs;
DROP TABLE IF EXISTS ma_oc_icd9_dgns;
DROP TABLE IF EXISTS ma_oc_icd9_prcdr;
DROP TABLE IF EXISTS ma_outpatientclaims;
DROP TABLE IF EXISTS ma_rxdrugevents;
DROP TABLE IF EXISTS ma_statecodes;

CREATE TABLE ma_beneficiarysummary AS TABLE ma2_bs;
CREATE TABLE ma_carrierclaims AS TABLE ma2_cc;
CREATE TABLE ma_carrierclaims_lineitems AS TABLE ma2_cc_li;
CREATE TABLE ma_cc_icd9_dgns AS TABLE ma2_cc_icd_d;
CREATE TABLE ma_countycodes AS TABLE ma2_county;
CREATE TABLE ma_hcpcs AS TABLE ma2_h;
CREATE TABLE ma_ic_icd9_dgns AS TABLE ma2_ic_icd_d;
CREATE TABLE ma_ic_icd9_prcdr AS TABLE ma2_ic_icd_p;
CREATE TABLE ma_icd AS TABLE ma2_i;
CREATE TABLE ma_inpatientclaims AS TABLE ma2_ic;
CREATE TABLE ma_line_prcsg_ind_cd AS TABLE ma2_l_p_i_c;
CREATE TABLE ma_ndc AS TABLE ma2_n;
CREATE TABLE ma_oc_hcpcs AS TABLE ma2_oc_h;
CREATE TABLE ma_oc_icd9_dgns AS TABLE ma2_oc_icd_d;
CREATE TABLE ma_oc_icd9_prcdr AS TABLE ma2_oc_icd_p;
CREATE TABLE ma_outpatientclaims AS TABLE ma2_oc;
CREATE TABLE ma_rxdrugevents AS TABLE ma2_rde;
CREATE TABLE ma_statecodes AS TABLE ma2_state;


-- --------------------------------------------------------------------------------------------------------------------
-- Merge the two-segment claims within Inpatient Claims
-- --------------------------------------------------------------------------------------------------------------------

--      Fill a secondary table with both segments from each two-segment inpatient claim

DROP TABLE IF EXISTS ma_inpatientclaims_seg2;
CREATE TABLE ma_inpatientclaims_seg2 AS TABLE ma_inpatientclaims;

TRUNCATE TABLE ma_inpatientclaims_seg2;

INSERT INTO ma_inpatientclaims_seg2
SELECT * FROM ma_inpatientclaims WHERE segment = 2;

INSERT INTO ma_inpatientclaims_seg2
SELECT ma_inpatientclaims.* FROM ma_inpatientclaims
INNER JOIN ma_inpatientclaims_seg2
ON ma_inpatientclaims.clm_id = ma_inpatientclaims_seg2.clm_id 
AND ma_inpatientclaims.segment = 1;

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
    FROM ma_inpatientclaims_seg2 a
INNER JOIN ma_inpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.segment = 1
    AND b.segment = 2;

--      There are enought similarities between the majority of these claims that they can all be merged together.

--      Merge each two-segment claim into a single segment

DROP TABLE IF EXISTS ma_inpatientclaims_seg2_merged;
CREATE TABLE ma_inpatientclaims_seg2_merged AS TABLE ma_inpatientclaims_seg2;

TRUNCATE TABLE ma_inpatientclaims_seg2_merged;

INSERT INTO ma_inpatientclaims_seg2_merged
SELECT a.clm_id,
        a.segment,
        a.clm_from_dt,
        a.clm_thru_dt,
        a.prvdr_num,
        a.at_physn_npi,
        a.op_physn_npi,
        a.ot_physn_npi,
        b.clm_admsn_dt,
        a.admtng_icd9_dgns_cd,
        a.clm_utlztn_day_cnt,
        b.nch_bene_dschrg_dt,
        a.clm_drg_cd,
        a.bs_id,
        a.patient_id,
        a.clm_pmt_amt + b.clm_pmt_amt,        
        a.nch_prmry_pyr_clm_pd_amt + b.nch_prmry_pyr_clm_pd_amt,
        a.clm_pass_thru_per_diem_amt + b.clm_pass_thru_per_diem_amt,
        b.nch_bene_ip_ddctbl_amt,
        a.nch_bene_pta_coinsrnc_lblty_am + a.nch_bene_pta_coinsrnc_lblty_am,
        a.nch_bene_blood_ddctbl_lblty_am
    FROM ma_inpatientclaims_seg2 a
INNER JOIN ma_inpatientclaims_seg2 b
ON a.clm_id = b.clm_id
    AND a.segment = 1
    AND b.segment = 2;


--      Delete the claims from the source table, then add in the merged data

DELETE FROM ma_inpatientclaims
USING ma_inpatientclaims_seg2_merged
WHERE ma_inpatientclaims.clm_id = ma_inpatientclaims_seg2_merged.clm_id;

INSERT INTO ma_inpatientclaims
SELECT * FROM ma_inpatientclaims_seg2_merged;

--      Get rid of the tables used for merging & remove the segment column from the source table

DROP TABLE IF EXISTS ma_inpatientclaims_seg2;
DROP TABLE IF EXISTS ma_inpatientclaims_seg2_merged;

ALTER TABLE ma_inpatientclaims DROP COLUMN segment;


-- --------------------------------------------------------------------------------------------------------------------
-- Format the two-segment claims within Outpatient Claims
-- --------------------------------------------------------------------------------------------------------------------

--      Fill secondary tables with respective segments from each two-segment outpatient claim
--  -------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_outpatientclaims_seg2;
CREATE TABLE ma_outpatientclaims_seg2 AS TABLE ma_outpatientclaims;

TRUNCATE TABLE ma_outpatientclaims_seg2;

INSERT INTO ma_outpatientclaims_seg2
SELECT * FROM ma_outpatientclaims WHERE segment = 2;

--      RESULT: INSERT 0 11253


DROP TABLE IF EXISTS ma_outpatientclaims_seg1;
CREATE TABLE ma_outpatientclaims_seg1 AS TABLE ma_outpatientclaims_seg2;

TRUNCATE TABLE ma_outpatientclaims_seg1;

INSERT INTO ma_outpatientclaims_seg1
SELECT ma_outpatientclaims.* FROM ma_outpatientclaims
INNER JOIN ma_outpatientclaims_seg2
ON ma_outpatientclaims.clm_id = ma_outpatientclaims_seg2.clm_id 
AND ma_outpatientclaims.segment = 1;

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

DELETE FROM ma_outpatientclaims
USING ma_outpatientclaims_nomatch
WHERE ma_outpatientclaims.clm_id = ma_outpatientclaims_nomatch.clm_id;

DELETE FROM ma_outpatientclaims_seg2
USING ma_outpatientclaims_nomatch
WHERE ma_outpatientclaims_seg2.clm_id = ma_outpatientclaims_nomatch.clm_id;

DROP TABLE IF EXISTS ma_outpatientclaims_nomatch;


-- Compare segment 1 and segment 2 of each claim and determine how to merge or separate their data.
-- -------------------------------------------------------------------------------------

--      View each column side-by-side from segment 1 to segment 2 of each claim

SELECT a.clm_id, b.clm_id,
        a.segment, b.segment,
        a.clm_from_dt, b.clm_from_dt,
        a.clm_thru_dt, b.clm_thru_dt,
        a.prvdr_num, b.prvdr_num,
        a.at_physn_npi, b.at_physn_npi,
        a.op_physn_npi, b.op_physn_npi,
        a.ot_physn_npi, b.ot_physn_npi,
        a.admtng_icd9_dgns_cd, b.admtng_icd9_dgns_cd,
        a.bs_id, b.bs_id,
        a.patient_id, b.patient_id,
        a.clm_pmt_amt, b.clm_pmt_amt,
        a.nch_prmry_pyr_clm_pd_amt, b.nch_prmry_pyr_clm_pd_amt,
        a.nch_bene_blood_ddctbl_lblty_am, b.nch_bene_blood_ddctbl_lblty_am,
        a.nch_bene_ptb_ddctbl_amt, b.nch_bene_ptb_ddctbl_amt,
        a.nch_bene_ptb_coinsrnc_amt, b.nch_bene_ptb_coinsrnc_amt
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

--      For every claim that has the same provider number between both segments, 
--      merge each two-segment claim into a single segment.

DROP TABLE IF EXISTS ma_outpatientclaims_segmerged;
CREATE TABLE ma_outpatientclaims_segmerged AS TABLE ma_outpatientclaims_seg2;

TRUNCATE TABLE ma_outpatientclaims_segmerged;

INSERT INTO ma_outpatientclaims_segmerged
SELECT a.clm_id,
        1,
        a.clm_from_dt,
        a.clm_thru_dt,
        a.prvdr_num,    
        a.at_physn_npi,
        a.op_physn_npi,
        a.ot_physn_npi,
        a.admtng_icd9_dgns_cd,
        a.bs_id,
        a.patient_id,
        a.clm_pmt_amt + b.clm_pmt_amt,
        a.nch_prmry_pyr_clm_pd_amt + b.nch_prmry_pyr_clm_pd_amt,
        a.nch_bene_blood_ddctbl_lblty_am,
        a.nch_bene_ptb_ddctbl_amt, 
        a.nch_bene_ptb_coinsrnc_amt + b.nch_bene_ptb_coinsrnc_amt
FROM ma_outpatientclaims_seg1 a
    INNER JOIN ma_outpatientclaims_seg2 b
    ON a.clm_id = b.clm_id
        AND a.prvdr_num = b.prvdr_num;


--      Delete the claims that have been merged from ma_outpatientclaims_seg1 and ma_outpatientclaims_seg2

DELETE FROM ma_outpatientclaims_seg1
USING ma_outpatientclaims_segmerged
WHERE ma_outpatientclaims_seg1.clm_id = ma_outpatientclaims_segmerged.clm_id;

DELETE FROM ma_outpatientclaims_seg2
USING ma_outpatientclaims_segmerged
WHERE ma_outpatientclaims_seg2.clm_id = ma_outpatientclaims_segmerged.clm_id;

--      The remaining claims in ma_outpatientclaims_seg1 and ma_outpatientclaims_seg2 have different provider 
--      numbers between their corresponding claims.


--  Replace all the claims in ma_outpatientclaims that have been merged or split
-- --------------------------------------------------------------------------------------

DELETE FROM ma_outpatientclaims
USING ma_outpatientclaims_segmerged
WHERE ma_outpatientclaims.clm_id = ma_outpatientclaims_segmerged.clm_id;

INSERT INTO ma_outpatientclaims
SELECT * FROM ma_outpatientclaims_segmerged;

DELETE FROM ma_outpatientclaims
USING ma_outpatientclaims_seg1
WHERE ma_outpatientclaims.clm_id = ma_outpatientclaims_seg1.clm_id;

INSERT INTO ma_outpatientclaims
SELECT * FROM ma_outpatientclaims_seg1;

DELETE FROM ma_outpatientclaims
USING ma_outpatientclaims_seg2
WHERE ma_outpatientclaims.clm_id = ma_outpatientclaims_seg2.clm_id;

INSERT INTO ma_outpatientclaims
SELECT * FROM ma_outpatientclaims_seg2;


--      Get rid of the tables used for merging & remove the segment column from the source table
-- --------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_outpatientclaims_seg1;
DROP TABLE IF EXISTS ma_outpatientclaims_seg2;
DROP TABLE IF EXISTS ma_outpatientclaims_segmerged;

ALTER TABLE ma_outpatientclaims DROP COLUMN segment;
