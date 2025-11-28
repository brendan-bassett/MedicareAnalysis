/*
-----------------------------------------------------------------------------------------------------------------------
    STEP 5
    
    Truncate numeric columns to INTEGER.

      Nearly every dollar-value in the entire dataset does not contain cent-precision information. The data-type 
      "numeric" uses approximately 12 bytes each for this datset, which is quite unnecessary. We will convert all
      of these values to 4-byte integers to conserve on storage space. This truncates each value to dollar-precision.
      The casting of each value from Numeric to Integer uses a large amount of storage and processing time.

      ** THIS IS AN EXTREMELY RESOURCE-HEAVY OPERATION **

      Multiple instances of "vacuum" are used to limit the amount of storage used in this operation
      Finally the database is saved so this hopefully does not have to be completed again. This is why the
      Condense_DeSynPUF sql files are divided into two segments.

        Run Time: 3.5 hr with increased compute capacity.

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

CREATE TABLE ma_beneficiarysummary AS TABLE Save4_ma_beneficiarysummary;
CREATE TABLE ma_carrierclaims AS TABLE Save4_ma_carrierclaims;
CREATE TABLE ma_hcpcs AS TABLE Save4_ma_hcpcs;
CREATE TABLE ma_icd AS TABLE Save4_ma_icd;
CREATE TABLE ma_inpatientclaims AS TABLE Save4_ma_inpatientclaims;
CREATE TABLE ma_ndc AS TABLE Save4_ma_ndc;
CREATE TABLE ma_outpatientclaims AS TABLE Save4_ma_outpatientclaims;
CREATE TABLE ma_rxdrugevents AS TABLE Save4_ma_rxdrugevents;
*/

-- --------------------------------------------------------------------------------------------------------------------
--  Truncate numeric columns to INTEGER.
-- --------------------------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS cast_col;

CREATE OR REPLACE FUNCTION cast_col (
   table_name VARCHAR,
   col_name VARCHAR
)

RETURNS TABLE ( 
	c BIGINT
)

LANGUAGE plpgsql

AS $$
	
DECLARE

	col_name_OLD VARCHAR;


BEGIN

    col_name_OLD := col_name || '_OLD';

	EXECUTE  format('ALTER TABLE %I RENAME COLUMN %I TO %I;',
                table_name, col_name, col_name_OLD);

	EXECUTE  format('ALTER TABLE %I ADD COLUMN %I INTEGER;',
                table_name, col_name);

	EXECUTE  format('UPDATE %I SET %I = CAST(%I AS INTEGER);',
                table_name, col_name, col_name_OLD);

	EXECUTE  format('ALTER TABLE %I DROP COLUMN %I;',
                table_name, col_name_OLD);

	RETURN QUERY EXECUTE format('SELECT COUNT(*) FROM %I;', table_name);

END
$$;


-- Beneficiary Summary

SELECT cast_col('ma_beneficiarysummary', 'medreimb_ip');
SELECT cast_col('ma_beneficiarysummary', 'benres_ip');
SELECT cast_col('ma_beneficiarysummary', 'pppymt_ip');
SELECT cast_col('ma_beneficiarysummary', 'medreimb_op');
SELECT cast_col('ma_beneficiarysummary', 'benres_op');
SELECT cast_col('ma_beneficiarysummary', 'pppymt_op');
SELECT cast_col('ma_beneficiarysummary', 'medreimb_car');
SELECT cast_col('ma_beneficiarysummary', 'benres_car');
SELECT cast_col('ma_beneficiarysummary', 'pppymt_car');

VACUUM FULL ANALYZE;

-- Carrier Claims

SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_1');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_2');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_3');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_4');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_5');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_6');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_7');

VACUUM FULL ANALYZE;

SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_8');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_9');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_10');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_11');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_12');
SELECT cast_col('ma_carrierclaims', 'line_nch_pmt_amt_13');

VACUUM FULL ANALYZE;

SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_1');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_2');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_3');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_4');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_5');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_6');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_7');

VACUUM FULL ANALYZE;

SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_8');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_9');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_10');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_11');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_12');
SELECT cast_col('ma_carrierclaims', 'line_bene_ptb_ddctbl_amt_13');

VACUUM FULL ANALYZE;

SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_1');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_2');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_3');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_4');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_5');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_6');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_7');

VACUUM FULL ANALYZE;

SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_8');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_9');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_10');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_11');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_12');
SELECT cast_col('ma_carrierclaims', 'line_bene_prmry_pyr_pd_amt_13');

VACUUM FULL ANALYZE;

SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_1');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_2');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_3');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_4');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_5');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_6');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_7');

VACUUM FULL ANALYZE;

SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_8');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_9');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_10');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_11');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_12');
SELECT cast_col('ma_carrierclaims', 'line_coinsrnc_amt_13');

VACUUM FULL ANALYZE;

SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_1');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_2');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_3');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_4');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_5');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_6');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_7');

VACUUM FULL ANALYZE;

SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_8');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_9');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_10');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_11');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_12');
SELECT cast_col('ma_carrierclaims', 'line_alowd_chrg_amt_13');

VACUUM FULL ANALYZE;

-- Inpatient Claims

SELECT cast_col('ma_inpatientclaims', 'clm_pmt_amt');
SELECT cast_col('ma_inpatientclaims', 'nch_prmry_pyr_clm_pd_amt');
SELECT cast_col('ma_inpatientclaims', 'clm_pass_thru_per_diem_amt');
SELECT cast_col('ma_inpatientclaims', 'nch_bene_ip_ddctbl_amt');
SELECT cast_col('ma_inpatientclaims', 'nch_bene_pta_coinsrnc_lblty_am');
SELECT cast_col('ma_inpatientclaims', 'nch_bene_blood_ddctbl_lblty_am');

VACUUM FULL ANALYZE;

-- Outpatient Claims

SELECT cast_col('ma_outpatientclaims', 'clm_pmt_amt');
SELECT cast_col('ma_outpatientclaims', 'nch_prmry_pyr_clm_pd_amt');
SELECT cast_col('ma_outpatientclaims', 'nch_bene_blood_ddctbl_lblty_am');
SELECT cast_col('ma_outpatientclaims', 'nch_bene_ptb_ddctbl_amt');
SELECT cast_col('ma_outpatientclaims', 'nch_bene_ptb_coinsrnc_amt');

-- Rx Drug Events

SELECT cast_col('ma_rxdrugevents', 'ptnt_pay_amt');
SELECT cast_col('ma_rxdrugevents', 'tot_rx_cst_amt');

VACUUM FULL ANALYZE;

-- --------------------------------------------------------------------------------------------------------------------
-- Copy Medicare-Analysis Tables as Save Point 5
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS Save5_ma_beneficiarysummary;
DROP TABLE IF EXISTS Save5_ma_carrierclaims;
DROP TABLE IF EXISTS Save5_ma_hcpcs;
DROP TABLE IF EXISTS Save5_ma_icd;
DROP TABLE IF EXISTS Save5_ma_inpatientclaims;
DROP TABLE IF EXISTS Save5_ma_ndc;
DROP TABLE IF EXISTS Save5_ma_outpatientclaims;
DROP TABLE IF EXISTS Save5_ma_rxdrugevents;

CREATE TABLE Save5_ma_beneficiarysummary AS TABLE ma_beneficiarysummary;
CREATE TABLE Save5_ma_carrierclaims AS TABLE ma_carrierclaims;
CREATE TABLE Save5_ma_hcpcs AS TABLE ma_hcpcs;
CREATE TABLE Save5_ma_icd AS TABLE ma_icd;
CREATE TABLE Save5_ma_inpatientclaims AS TABLE ma_inpatientclaims;
CREATE TABLE Save5_ma_ndc AS TABLE ma_ndc;
CREATE TABLE Save5_ma_outpatientclaims AS TABLE ma_outpatientclaims;
CREATE TABLE Save5_ma_rxdrugevents AS TABLE ma_rxdrugevents;


VACUUM FULL ANALYZE;