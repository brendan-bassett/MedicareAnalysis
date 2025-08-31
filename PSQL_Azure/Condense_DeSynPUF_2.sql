/*
-----------------------------------------------------------------------------------------------------------------------
	Prepare the de-Syn_PUF data for efficient use in Power BI.

    ** PART 2 **

    The original de-Syn-PUF dataset is large and unweildy. If we try to import it into Power BI as-is then it's 
    unusably slow to manipulate. It's also very difficult to create workable relationships.
    
    This involves removing extra columns nad merging tables. Also creating lookup tables for codes such as hcpcs that 
    have multiple columns for the same category of data.
-----------------------------------------------------------------------------------------------------------------------
*/

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
		line_nch_pmt_amt INTEGER,
		line_bene_ptb_ddctbl_amt INTEGER,
		line_bene_prmry_pyr_pd_amt INTEGER,
		line_coinsrnc_amt INTEGER,
		line_alowd_chrg_amt NUMERIC,
		line_prcsg_ind_cd VARCHAR,
		line_icd9_dgns_cd VARCHAR
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

ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_1;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_2;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_3;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_4;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_5;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_6;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_7;
ALTER TABLE ma_carrierclaims DROP COLUMN icd9_dgns_cd_8;

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

VACUUM FULL ANALYZE;

/*

-- --------------------------------------------------------------------------------------------------------------------
-- Correlate NDC codes to Rx Drug Events
-- --------------------------------------------------------------------------------------------------------------------

ALTER TABLE ma_ndc ADD COLUMN ndc11_id SERIAL PRIMARY KEY;

ALTER TABLE ma_rxdrugevents ADD COLUMN ndc11_id INTEGER;

UPDATE ma_rxdrugevents a
SET ndc11_id, b.ndc11_id
FROM ma_ndc b
WHERE a.ndc11 = b.ndc11;

ALTER TABLE ma_rxdrugevents DROP COLUMN ndc11;


-- --------------------------------------------------------------------------------------------------------------------
-- Correlate ICD codes to each table
-- --------------------------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS correllate_icd;

CREATE OR REPLACE FUNCTION correllate_icd (
   source_table_name VARCHAR,
   dest_table_name VARCHAR,
   source_col_name VARCHAR
)

RETURNS TABLE ( 
	c BIGINT
)

LANGUAGE plpgsql

AS $$
	

BEGIN

	EXECUTE  format('INSERT INTO %1$I '
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
                'icd9');            -- 7

	RETURN QUERY EXECUTE format('SELECT COUNT(*) FROM %I;', 'ma_icd');

END
$$;


-- EXAMPLE:

--         INSERT INTO ma_ic_icd9_dgns
--         SELECT ma_icd.icd_id, ma_inpatientclaims.clm_id
--         FROM ma_inpatientclaims
--             INNER JOIN ma_icd
--             ON ma_inpatientclaims.icd9_dgns_cd_1 = ma_icd.icd9;


-- Inpatient Claims
-- ------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_ic_icd9_dgns;
CREATE TABLE ma_ic_icd9_dgns (
    icd9_id INTEGER,
    clm_id BIGINT
);

SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns', 'icd9_dgns_cd_1');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns', 'icd9_dgns_cd_2');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns', 'icd9_dgns_cd_3');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns', 'icd9_dgns_cd_4');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns', 'icd9_dgns_cd_5');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns', 'icd9_dgns_cd_6');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns', 'icd9_dgns_cd_7');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns', 'icd9_dgns_cd_8');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns', 'icd9_dgns_cd_9');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_dgns', 'icd9_dgns_cd_10');

SELECT COUNT(*) FROM ma_ic_icd9_dgns;

--      RESULT: 537271


DROP TABLE IF EXISTS ma_ic_icd9_prcdr;
CREATE TABLE ma_ic_icd9_prcdr (
    icd9_id INTEGER,
    clm_id BIGINT
);

SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr', 'icd9_prcdr_cd_1');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr', 'icd9_prcdr_cd_2');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr', 'icd9_prcdr_cd_3');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr', 'icd9_prcdr_cd_4');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr', 'icd9_prcdr_cd_5');
SELECT * FROM correllate_icd('ma_inpatientclaims', 'ma_ic_icd9_prcdr', 'icd9_prcdr_cd_6');

SELECT COUNT(*) FROM ma_ic_icd9_prcdr;

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

DROP TABLE IF EXISTS ma_oc_icd9_dgns;
CREATE TABLE ma_oc_icd9_dgns (
    icd9_id INTEGER,
    clm_id BIGINT
);

SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns', 'icd9_dgns_cd_1');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns', 'icd9_dgns_cd_2');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns', 'icd9_dgns_cd_3');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns', 'icd9_dgns_cd_4');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns', 'icd9_dgns_cd_5');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns', 'icd9_dgns_cd_6');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns', 'icd9_dgns_cd_7');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns', 'icd9_dgns_cd_8');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns', 'icd9_dgns_cd_9');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_dgns', 'icd9_dgns_cd_10');

SELECT COUNT(*) FROM ma_oc_icd9_dgns;

--      RESULT: 2073796


DROP TABLE IF EXISTS ma_oc_icd9_prcdr;
CREATE TABLE ma_oc_icd9_prcdr (
    icd9_id INTEGER,
    clm_id BIGINT
);

SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr', 'icd9_prcdr_cd_1');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr', 'icd9_prcdr_cd_2');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr', 'icd9_prcdr_cd_3');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr', 'icd9_prcdr_cd_4');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr', 'icd9_prcdr_cd_5');
SELECT * FROM correllate_icd('ma_outpatientclaims', 'ma_oc_icd9_prcdr', 'icd9_prcdr_cd_6');

SELECT COUNT(*) FROM ma_oc_icd9_prcdr;

--      RESULT: 508

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

ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_1;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_2;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_3;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_4;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_5;
ALTER TABLE ma_outpatientclaims DROP COLUMN icd9_prcdr_cd_6;

-- Carrier Claims
-- ------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ma_cc_icd9_dgns;
CREATE TABLE ma_cc_icd9_dgns (
    icd9_id INTEGER,
    clm_id BIGINT
);

SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns', 'icd9_dgns_cd_1');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns', 'icd9_dgns_cd_2');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns', 'icd9_dgns_cd_3');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns', 'icd9_dgns_cd_4');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns', 'icd9_dgns_cd_5');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns', 'icd9_dgns_cd_6');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns', 'icd9_dgns_cd_7');
SELECT * FROM correllate_icd('ma_carrierclaims', 'ma_cc_icd9_dgns', 'icd9_dgns_cd_8');

SELECT COUNT(*) FROM ma_cc_icd9_dgns;

--      RESULT: 


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

ALTER TABLE ma_carrierclaims_lineitems ADD COLUMN line_icd9_dgns_id INTEGER;

UPDATE ma_carrierclaims_lineitems a
SET line_icd9_dgns_id = b.icd9_id
FROM ma_icd b
WHERE a.line_icd9_dgns_cd = b.icd9;

ALTER TABLE ma_carrierclaims_lineitems DROP COLUMN line_icd9_dgns_cd;


VACUUM FULL ANALYZE;


-- --------------------------------------------------------------------------------------------------------------------
-- Correlate HCPCS codes to each table
-- --------------------------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS correllate_hcpcs;

CREATE OR REPLACE FUNCTION correllate_hcpcs (
   source_table_name VARCHAR,
   dest_table_name VARCHAR,
   source_col_name VARCHAR
)

RETURNS TABLE ( 
	c BIGINT
)

LANGUAGE plpgsql

AS $$
	

BEGIN

	EXECUTE  format('INSERT INTO %1$I '
                    || 'SELECT %2$I.%3$I, %5$I.%4$I '
                    || 'FROM %5$I '
                    || 'INNER JOIN %2$I '
                    || 'ON %5$I.%6$I = %2$I.%7$I;',
                dest_table_name,    -- 1
                'ma_hcpcs',           -- 2
                'icd_id',           -- 3
                'clm_id',           -- 4
                source_table_name,  -- 5
                source_col_name,    -- 6
                'hcpcs');            -- 7

	RETURN QUERY EXECUTE format('SELECT COUNT(*) FROM %I;', 'ma_hcpcs');

END
$$;

*/

-- --------------------------------------------------------------------------------------------------------------------
-- Run cleanup of dead tuples & maximize efficiency
-- --------------------------------------------------------------------------------------------------------------------

VACUUM FULL ANALYZE;