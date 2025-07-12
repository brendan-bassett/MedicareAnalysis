/*
-----------------------------------------------------------------------------------------------------------------------
	Import CSV files into local postgresql server
   
	Uses only sample 1 of 20 in the De-SynPUF dataset
	(3-5 min processing time)
-----------------------------------------------------------------------------------------------------------------------
*/

/*
-----------------------------------------------------------------------------------------------------------------------
   Import Beneficiary Summaries
-----------------------------------------------------------------------------------------------------------------------
*/
	
-- Executing code within functions allows for RAISE INFO messages and quick reimporting of data later

CREATE OR REPLACE FUNCTION import_beneficiary_summaries ()
RETURNS BOOLEAN
LANGUAGE plpgsql
AS

$$
BEGIN

	DROP TABLE IF EXISTS beneficiary_summary_2008;
	DROP TABLE IF EXISTS beneficiary_summary_2009;
	DROP TABLE IF EXISTS beneficiary_summary_2010;
	
	RAISE INFO 'Import beneficiary_summary_2008 ...';
	
	CREATE TABLE beneficiary_summary_2008 (
	
	  -- No hex data type in postgresql, and cannot read from csv directly to bigint.
	  -- Read as bytea, then convert later into
	  -- Will convert to bigint in later steps so it's usable in Power BI
	  desynpuf_id BYTEA, 
	  
	  bene_birth_dt DATE,
	  bene_death_dt DATE,
	  bene_sex_ident_cd SMALLINT,
	  bene_race_cd SMALLINT,
	  bene_esrd_ind CHAR(1),
	  sp_state_code SMALLINT,
	  bene_county_cd SMALLINT,
	
	  bene_hi_cvrage_tot_mons SMALLINT,
	  bene_smi_cvrage_tot_mons SMALLINT,
	  bene_hmo_cvrage_tot_mons SMALLINT,
	  plan_cvrg_mos_num SMALLINT,
	
	  sp_alzhdmta SMALLINT,
	  sp_chf SMALLINT,
	  sp_chrnkidn SMALLINT,
	  sp_cncr SMALLINT,
	  sp_copd SMALLINT,
	  sp_depressn SMALLINT,
	  sp_diabetes SMALLINT,
	  sp_ischmcht SMALLINT,
	  sp_osteoprs SMALLINT,
	  sp_ra_oa SMALLINT,
	  sp_strketia SMALLINT,
	
	  medreimb_ip NUMERIC(8, 2),
	  benres_ip NUMERIC(8, 2),
	  pppymt_ip NUMERIC(8, 2),
	  medreimb_op NUMERIC(8, 2),
	  benres_op NUMERIC(8, 2),
	  pppymt_op NUMERIC(8, 2),
	  medreimb_car NUMERIC(8, 2),
	  benres_car NUMERIC(6, 2),
	  pppymt_car NUMERIC(6, 2)
	);
	
	COPY beneficiary_summary_2008 (
	
		desynpuf_id, 
		bene_birth_dt, 
		bene_death_dt, 
		bene_sex_ident_cd, 
		bene_race_cd, 
		bene_esrd_ind, 
		sp_state_code, 
		bene_county_cd,  
	
		bene_hi_cvrage_tot_mons, 
		bene_smi_cvrage_tot_mons, 
		bene_hmo_cvrage_tot_mons, 
		plan_cvrg_mos_num, 
	
		sp_alzhdmta, 
		sp_chf, 
		sp_chrnkidn, 
		sp_cncr, 
		sp_copd, 
		sp_depressn, 
		sp_diabetes, 
		sp_ischmcht, 
		sp_osteoprs, 
		sp_ra_oa, 
		sp_strketia, 
	
		medreimb_ip, 
		benres_ip, 
		pppymt_ip, 
		medreimb_op, 
		benres_op, 
		pppymt_op, 
		medreimb_car, 
		benres_car, 
		pppymt_car
	)
	
	FROM 'F:\DE-SynPUFs\2008 Beneficiary Summary\DE1_0_2008_Beneficiary_Summary_File_Sample_1.csv'
	DELIMITER ','
	CSV HEADER;
	
	
	RAISE INFO 'Import beneficiary_summary_2009 ...';
	
	CREATE TABLE beneficiary_summary_2009 (
	
	  desynpuf_id BYTEA,
	  bene_birth_dt DATE,
	  bene_death_dt DATE,
	  bene_sex_ident_cd SMALLINT,
	  bene_race_cd SMALLINT,
	  bene_esrd_ind CHAR(1),
	  sp_state_code SMALLINT,
	  bene_county_cd SMALLINT,
	
	  bene_hi_cvrage_tot_mons SMALLINT,
	  bene_smi_cvrage_tot_mons SMALLINT,
	  bene_hmo_cvrage_tot_mons SMALLINT,
	  plan_cvrg_mos_num SMALLINT,
	
	  sp_alzhdmta SMALLINT,
	  sp_chf SMALLINT,
	  sp_chrnkidn SMALLINT,
	  sp_cncr SMALLINT,
	  sp_copd SMALLINT,
	  sp_depressn SMALLINT,
	  sp_diabetes SMALLINT,
	  sp_ischmcht SMALLINT,
	  sp_osteoprs SMALLINT,
	  sp_ra_oa SMALLINT,
	  sp_strketia SMALLINT,
	
	  medreimb_ip NUMERIC(8, 2),
	  benres_ip NUMERIC(8, 2),
	  pppymt_ip NUMERIC(8, 2),
	  medreimb_op NUMERIC(8, 2),
	  benres_op NUMERIC(8, 2),
	  pppymt_op NUMERIC(8, 2),
	  medreimb_car NUMERIC(8, 2),
	  benres_car NUMERIC(6, 2),
	  pppymt_car NUMERIC(6, 2)
	);
	
	COPY beneficiary_summary_2009 (
	
		desynpuf_id, 
		bene_birth_dt, 
		bene_death_dt, 
		bene_sex_ident_cd, 
		bene_race_cd, 
		bene_esrd_ind, 
		sp_state_code, 
		bene_county_cd,  
	
		bene_hi_cvrage_tot_mons, 
		bene_smi_cvrage_tot_mons, 
		bene_hmo_cvrage_tot_mons, 
		plan_cvrg_mos_num, 
	
		sp_alzhdmta, 
		sp_chf, 
		sp_chrnkidn, 
		sp_cncr, 
		sp_copd, 
		sp_depressn, 
		sp_diabetes, 
		sp_ischmcht, 
		sp_osteoprs, 
		sp_ra_oa, 
		sp_strketia, 
	
		medreimb_ip, 
		benres_ip, 
		pppymt_ip, 
		medreimb_op, 
		benres_op, 
		pppymt_op, 
		medreimb_car, 
		benres_car, 
		pppymt_car
	)
	
	FROM 'F:\DE-SynPUFs\2009 Beneficiary Summary\DE1_0_2009_Beneficiary_Summary_File_Sample_1.csv'
	DELIMITER ','
	CSV HEADER;
	
	
	RAISE INFO 'Import beneficiary_summary_2010 ...';
	
	CREATE TABLE beneficiary_summary_2010 (
	
	  desynpuf_id BYTEA,
	  bene_birth_dt DATE,
	  bene_death_dt DATE,
	  bene_sex_ident_cd SMALLINT,
	  bene_race_cd SMALLINT,
	  bene_esrd_ind CHAR(1),
	  sp_state_code SMALLINT,
	  bene_county_cd SMALLINT,
	
	  bene_hi_cvrage_tot_mons SMALLINT,
	  bene_smi_cvrage_tot_mons SMALLINT,
	  bene_hmo_cvrage_tot_mons SMALLINT,
	  plan_cvrg_mos_num SMALLINT,
	
	  sp_alzhdmta SMALLINT,
	  sp_chf SMALLINT,
	  sp_chrnkidn SMALLINT,
	  sp_cncr SMALLINT,
	  sp_copd SMALLINT,
	  sp_depressn SMALLINT,
	  sp_diabetes SMALLINT,
	  sp_ischmcht SMALLINT,
	  sp_osteoprs SMALLINT,
	  sp_ra_oa SMALLINT,
	  sp_strketia SMALLINT,
	
	  medreimb_ip NUMERIC(8, 2),
	  benres_ip NUMERIC(8, 2),
	  pppymt_ip NUMERIC(8, 2),
	  medreimb_op NUMERIC(8, 2),
	  benres_op NUMERIC(8, 2),
	  pppymt_op NUMERIC(8, 2),
	  medreimb_car NUMERIC(8, 2),
	  benres_car NUMERIC(6, 2),
	  pppymt_car NUMERIC(6, 2)
	);
	
	COPY beneficiary_summary_2010 (
	
		desynpuf_id, 
		bene_birth_dt, 
		bene_death_dt, 
		bene_sex_ident_cd, 
		bene_race_cd, 
		bene_esrd_ind, 
		sp_state_code, 
		bene_county_cd,  
	
		bene_hi_cvrage_tot_mons, 
		bene_smi_cvrage_tot_mons, 
		bene_hmo_cvrage_tot_mons, 
		plan_cvrg_mos_num, 
	
		sp_alzhdmta, 
		sp_chf, 
		sp_chrnkidn, 
		sp_cncr, 
		sp_copd, 
		sp_depressn, 
		sp_diabetes, 
		sp_ischmcht, 
		sp_osteoprs, 
		sp_ra_oa, 
		sp_strketia, 
	
		medreimb_ip, 
		benres_ip, 
		pppymt_ip, 
		medreimb_op, 
		benres_op, 
		pppymt_op, 
		medreimb_car, 
		benres_car, 
		pppymt_car
	)
	
	FROM 'F:\DE-SynPUFs\2010 Beneficiary Summary\DE1_0_2010_Beneficiary_Summary_File_Sample_1.csv'
	DELIMITER ','
	CSV HEADER;
	
	RETURN True;
	
END $$;
	
/*
-----------------------------------------------------------------------------------------------------------------------
   Import Inpatient Claims
-----------------------------------------------------------------------------------------------------------------------
*/

CREATE OR REPLACE FUNCTION import_inpatient_claims ()
RETURNS BOOLEAN
LANGUAGE plpgsql
AS

$$
BEGIN

	DROP TABLE IF EXISTS inpatient_claims;
	
	RAISE INFO 'Import inpatient_claims ...';
	
	CREATE TABLE inpatient_claims (
	
		desynpuf_id BYTEA,
	 	clm_id BIGINT,
		segment SMALLINT,
		clm_from_dt DATE,
		clm_thru_dt DATE,
		prvdr_num CHAR(6),
		clm_pmt_amt NUMERIC(8, 2),
		nch_prmry_pyr_clm_pd_amt NUMERIC(8, 2),
	
		at_physn_npi BIGINT,
		op_physn_npi BIGINT,
		ot_physn_npi BIGINT,
	
		clm_admsn_dt DATE,
		admtng_icd9_dgns_cd VARCHAR(5), 
		clm_pass_thru_per_diem_amt NUMERIC(8, 2),
		nch_bene_ip_ddctbl_amt NUMERIC(8, 2),
		nch_bene_pta_coinsrnc_lblty_am NUMERIC(8, 2),
		nch_bene_blood_ddctbl_lblty_am NUMERIC(8, 2),
		clm_utlztn_day_cnt SMALLINT,
		nch_bene_dschrg_dt DATE,
		clm_drg_cd VARCHAR(3), 
	
		icd9_dgns_cd_1 VARCHAR(5), 
		icd9_dgns_cd_2 VARCHAR(5), 
		icd9_dgns_cd_3 VARCHAR(5), 
		icd9_dgns_cd_4 VARCHAR(5), 
		icd9_dgns_cd_5 VARCHAR(5), 
		icd9_dgns_cd_6 VARCHAR(5), 
		icd9_dgns_cd_7 VARCHAR(5), 
		icd9_dgns_cd_8 VARCHAR(5), 
		icd9_dgns_cd_9 VARCHAR(5), 
		icd9_dgns_cd_10 VARCHAR(5), 
	
		icd9_prcdr_cd_1 VARCHAR(5), 
		icd9_prcdr_cd_2 VARCHAR(5), 
		icd9_prcdr_cd_3 VARCHAR(5), 
		icd9_prcdr_cd_4 VARCHAR(5), 
		icd9_prcdr_cd_5 VARCHAR(5), 
		icd9_prcdr_cd_6 VARCHAR(5), 
	
		hcpcs_cd_1 VARCHAR(5), 
		hcpcs_cd_2 VARCHAR(5), 
		hcpcs_cd_3 VARCHAR(5), 
		hcpcs_cd_4 VARCHAR(5), 
		hcpcs_cd_5 VARCHAR(5), 
		hcpcs_cd_6 VARCHAR(5), 
		hcpcs_cd_7 VARCHAR(5), 
		hcpcs_cd_8 VARCHAR(5), 
		hcpcs_cd_9 VARCHAR(5), 
		hcpcs_cd_10 VARCHAR(5), 
		hcpcs_cd_11 VARCHAR(5), 
		hcpcs_cd_12 VARCHAR(5), 
		hcpcs_cd_13 VARCHAR(5), 
		hcpcs_cd_14 VARCHAR(5), 
		hcpcs_cd_15 VARCHAR(5), 
		hcpcs_cd_16 VARCHAR(5), 
		hcpcs_cd_17 VARCHAR(5), 
		hcpcs_cd_18 VARCHAR(5), 
		hcpcs_cd_19 VARCHAR(5), 
		hcpcs_cd_20 VARCHAR(5), 
		hcpcs_cd_21 VARCHAR(5), 
		hcpcs_cd_22 VARCHAR(5), 
		hcpcs_cd_23 VARCHAR(5), 
		hcpcs_cd_24 VARCHAR(5), 
		hcpcs_cd_25 VARCHAR(5), 
		hcpcs_cd_26 VARCHAR(5), 
		hcpcs_cd_27 VARCHAR(5), 
		hcpcs_cd_28 VARCHAR(5), 
		hcpcs_cd_29 VARCHAR(5), 
		hcpcs_cd_30 VARCHAR(5), 
		hcpcs_cd_31 VARCHAR(5), 
		hcpcs_cd_32 VARCHAR(5), 
		hcpcs_cd_33 VARCHAR(5), 
		hcpcs_cd_34 VARCHAR(5), 
		hcpcs_cd_35 VARCHAR(5), 
		hcpcs_cd_36 VARCHAR(5), 
		hcpcs_cd_37 VARCHAR(5), 
		hcpcs_cd_38 VARCHAR(5), 
		hcpcs_cd_39 VARCHAR(5), 
		hcpcs_cd_40 VARCHAR(5), 
		hcpcs_cd_41 VARCHAR(5), 
		hcpcs_cd_42 VARCHAR(5), 
		hcpcs_cd_43 VARCHAR(5), 
		hcpcs_cd_44 VARCHAR(5), 
		hcpcs_cd_45 VARCHAR(5)
	);
	
	COPY inpatient_claims (
	
		desynpuf_id,
	 	clm_id,
		segment,
		clm_from_dt,
		clm_thru_dt,
		prvdr_num,
		clm_pmt_amt,
		nch_prmry_pyr_clm_pd_amt,
	
		at_physn_npi,
		op_physn_npi,
		ot_physn_npi,
	
		clm_admsn_dt,
		admtng_icd9_dgns_cd,
		clm_pass_thru_per_diem_amt,
		nch_bene_ip_ddctbl_amt, 
		nch_bene_pta_coinsrnc_lblty_am,
		nch_bene_blood_ddctbl_lblty_am,
		clm_utlztn_day_cnt,
		nch_bene_dschrg_dt,
		clm_drg_cd,
	
		icd9_dgns_cd_1,
		icd9_dgns_cd_2,
		icd9_dgns_cd_3,
		icd9_dgns_cd_4,
		icd9_dgns_cd_5,
		icd9_dgns_cd_6,
		icd9_dgns_cd_7,
		icd9_dgns_cd_8,
		icd9_dgns_cd_9,
		icd9_dgns_cd_10,
	
		icd9_prcdr_cd_1,
		icd9_prcdr_cd_2,
		icd9_prcdr_cd_3,
		icd9_prcdr_cd_4,
		icd9_prcdr_cd_5,
		icd9_prcdr_cd_6,
	
		hcpcs_cd_1,
		hcpcs_cd_2,
		hcpcs_cd_3,
		hcpcs_cd_4,
		hcpcs_cd_5,
		hcpcs_cd_6,
		hcpcs_cd_7,
		hcpcs_cd_8,
		hcpcs_cd_9,
		hcpcs_cd_10,
		hcpcs_cd_11,
		hcpcs_cd_12,
		hcpcs_cd_13,
		hcpcs_cd_14,
		hcpcs_cd_15,
		hcpcs_cd_16,
		hcpcs_cd_17,
		hcpcs_cd_18,
		hcpcs_cd_19,
		hcpcs_cd_20,
		hcpcs_cd_21,
		hcpcs_cd_22,
		hcpcs_cd_23,
		hcpcs_cd_24,
		hcpcs_cd_25,
		hcpcs_cd_26,
		hcpcs_cd_27,
		hcpcs_cd_28,
		hcpcs_cd_29,
		hcpcs_cd_30,
		hcpcs_cd_31,
		hcpcs_cd_32,
		hcpcs_cd_33,
		hcpcs_cd_34,
		hcpcs_cd_35,
		hcpcs_cd_36,
		hcpcs_cd_37,
		hcpcs_cd_38,
		hcpcs_cd_39,
		hcpcs_cd_40,
		hcpcs_cd_41,
		hcpcs_cd_42,
		hcpcs_cd_43,
		hcpcs_cd_44,
		hcpcs_cd_45)
	
	FROM 'F:\DE-SynPUFs\2008 to 2010 Inpatient Claims\DE1_0_2008_to_2010_Inpatient_Claims_Sample_1.csv'
	DELIMITER ','
	CSV HEADER;
	
	RETURN True;
	
END $$;
	
/*
-----------------------------------------------------------------------------------------------------------------------
   Import Outpatient Claims
-----------------------------------------------------------------------------------------------------------------------
*/

CREATE OR REPLACE FUNCTION import_outpatient_claims ()
RETURNS BOOLEAN
LANGUAGE plpgsql
AS

$$
BEGIN

	DROP TABLE IF EXISTS outpatient_claims;
	
	RAISE INFO 'Import outpatient_claims ...';
	
	CREATE TABLE outpatient_claims (
	
		desynpuf_id BYTEA,
	 	clm_id BIGINT,
		segment SMALLINT,
		clm_from_dt DATE,
		clm_thru_dt DATE,
		prvdr_num CHAR(6),
		clm_pmt_amt NUMERIC(8, 2),
		nch_prmry_pyr_clm_pd_amt NUMERIC(8, 2),
	
		at_physn_npi BIGINT,
		op_physn_npi BIGINT,
		ot_physn_npi BIGINT,
	
		nch_bene_blood_ddctbl_lblty_am NUMERIC(8, 2),
	
		icd9_dgns_cd_1 VARCHAR(5), 
		icd9_dgns_cd_2 VARCHAR(5), 
		icd9_dgns_cd_3 VARCHAR(5), 
		icd9_dgns_cd_4 VARCHAR(5), 
		icd9_dgns_cd_5 VARCHAR(5), 
		icd9_dgns_cd_6 VARCHAR(5), 
		icd9_dgns_cd_7 VARCHAR(5), 
		icd9_dgns_cd_8 VARCHAR(5), 
		icd9_dgns_cd_9 VARCHAR(5), 
		icd9_dgns_cd_10 VARCHAR(5), 
	
		icd9_prcdr_cd_1 VARCHAR(5), 
		icd9_prcdr_cd_2 VARCHAR(5), 
		icd9_prcdr_cd_3 VARCHAR(5), 
		icd9_prcdr_cd_4 VARCHAR(5), 
		icd9_prcdr_cd_5 VARCHAR(5), 
		icd9_prcdr_cd_6 VARCHAR(5), 
		
		nch_bene_ptb_ddctbl_amt NUMERIC(8, 2),
		nch_bene_ptb_coinsrnc_amt NUMERIC(8, 2),
		admtng_icd9_dgns_cd VARCHAR(5),
	
		hcpcs_cd_1 VARCHAR(5), 
		hcpcs_cd_2 VARCHAR(5), 
		hcpcs_cd_3 VARCHAR(5), 
		hcpcs_cd_4 VARCHAR(5), 
		hcpcs_cd_5 VARCHAR(5), 
		hcpcs_cd_6 VARCHAR(5), 
		hcpcs_cd_7 VARCHAR(5), 
		hcpcs_cd_8 VARCHAR(5), 
		hcpcs_cd_9 VARCHAR(5), 
		hcpcs_cd_10 VARCHAR(5), 
		hcpcs_cd_11 VARCHAR(5), 
		hcpcs_cd_12 VARCHAR(5), 
		hcpcs_cd_13 VARCHAR(5), 
		hcpcs_cd_14 VARCHAR(5), 
		hcpcs_cd_15 VARCHAR(5), 
		hcpcs_cd_16 VARCHAR(5), 
		hcpcs_cd_17 VARCHAR(5), 
		hcpcs_cd_18 VARCHAR(5), 
		hcpcs_cd_19 VARCHAR(5), 
		hcpcs_cd_20 VARCHAR(5), 
		hcpcs_cd_21 VARCHAR(5), 
		hcpcs_cd_22 VARCHAR(5), 
		hcpcs_cd_23 VARCHAR(5), 
		hcpcs_cd_24 VARCHAR(5), 
		hcpcs_cd_25 VARCHAR(5), 
		hcpcs_cd_26 VARCHAR(5), 
		hcpcs_cd_27 VARCHAR(5), 
		hcpcs_cd_28 VARCHAR(5), 
		hcpcs_cd_29 VARCHAR(5), 
		hcpcs_cd_30 VARCHAR(5), 
		hcpcs_cd_31 VARCHAR(5), 
		hcpcs_cd_32 VARCHAR(5), 
		hcpcs_cd_33 VARCHAR(5), 
		hcpcs_cd_34 VARCHAR(5), 
		hcpcs_cd_35 VARCHAR(5), 
		hcpcs_cd_36 VARCHAR(5), 
		hcpcs_cd_37 VARCHAR(5), 
		hcpcs_cd_38 VARCHAR(5), 
		hcpcs_cd_39 VARCHAR(5), 
		hcpcs_cd_40 VARCHAR(5), 
		hcpcs_cd_41 VARCHAR(5), 
		hcpcs_cd_42 VARCHAR(5), 
		hcpcs_cd_43 VARCHAR(5), 
		hcpcs_cd_44 VARCHAR(5), 
		hcpcs_cd_45 VARCHAR(5)
	);
	
	COPY outpatient_claims (
	
		desynpuf_id,
	 	clm_id,
		segment,
		clm_from_dt,
		clm_thru_dt,
		prvdr_num,
		clm_pmt_amt,
		nch_prmry_pyr_clm_pd_amt,
	
		at_physn_npi,
		op_physn_npi,
		ot_physn_npi,
	
		nch_bene_blood_ddctbl_lblty_am,
	
		icd9_dgns_cd_1,
		icd9_dgns_cd_2,
		icd9_dgns_cd_3,
		icd9_dgns_cd_4,
		icd9_dgns_cd_5,
		icd9_dgns_cd_6,
		icd9_dgns_cd_7,
		icd9_dgns_cd_8,
		icd9_dgns_cd_9,
		icd9_dgns_cd_10,
	
		icd9_prcdr_cd_1,
		icd9_prcdr_cd_2,
		icd9_prcdr_cd_3,
		icd9_prcdr_cd_4,
		icd9_prcdr_cd_5,
		icd9_prcdr_cd_6,
	
		nch_bene_ptb_ddctbl_amt,
		nch_bene_ptb_coinsrnc_amt,
		admtng_icd9_dgns_cd,
		
		hcpcs_cd_1,
		hcpcs_cd_2,
		hcpcs_cd_3,
		hcpcs_cd_4,
		hcpcs_cd_5,
		hcpcs_cd_6,
		hcpcs_cd_7,
		hcpcs_cd_8,
		hcpcs_cd_9,
		hcpcs_cd_10,
		hcpcs_cd_11,
		hcpcs_cd_12,
		hcpcs_cd_13,
		hcpcs_cd_14,
		hcpcs_cd_15,
		hcpcs_cd_16,
		hcpcs_cd_17,
		hcpcs_cd_18,
		hcpcs_cd_19,
		hcpcs_cd_20,
		hcpcs_cd_21,
		hcpcs_cd_22,
		hcpcs_cd_23,
		hcpcs_cd_24,
		hcpcs_cd_25,
		hcpcs_cd_26,
		hcpcs_cd_27,
		hcpcs_cd_28,
		hcpcs_cd_29,
		hcpcs_cd_30,
		hcpcs_cd_31,
		hcpcs_cd_32,
		hcpcs_cd_33,
		hcpcs_cd_34,
		hcpcs_cd_35,
		hcpcs_cd_36,
		hcpcs_cd_37,
		hcpcs_cd_38,
		hcpcs_cd_39,
		hcpcs_cd_40,
		hcpcs_cd_41,
		hcpcs_cd_42,
		hcpcs_cd_43,
		hcpcs_cd_44,
		hcpcs_cd_45)
	
	FROM 'F:\DE-SynPUFs\2008 to 2010 Outpatient Claims\DE1_0_2008_to_2010_Outpatient_Claims_Sample_1.csv'
	DELIMITER ','
	CSV HEADER;

	RETURN TRUE;	

END $$;
	
/*
-----------------------------------------------------------------------------------------------------------------------
   Import Carrier Claims
-----------------------------------------------------------------------------------------------------------------------
*/
		
CREATE OR REPLACE FUNCTION import_carrier_claims ()
RETURNS BOOLEAN
LANGUAGE plpgsql
AS

$$
BEGIN

	DROP TABLE IF EXISTS carrier_claims;
	
	RAISE INFO 'Import carrier_claims - Part A ...';
	
	CREATE TABLE carrier_claims (
	  
		desynpuf_id BYTEA,
	 	clm_id BIGINT,
		clm_from_dt DATE,
		clm_thru_dt DATE,
	
		icd9_dgns_cd_1 VARCHAR(5), 
		icd9_dgns_cd_2 VARCHAR(5), 
		icd9_dgns_cd_3 VARCHAR(5), 
		icd9_dgns_cd_4 VARCHAR(5), 
		icd9_dgns_cd_5 VARCHAR(5), 
		icd9_dgns_cd_6 VARCHAR(5), 
		icd9_dgns_cd_7 VARCHAR(5), 
		icd9_dgns_cd_8 VARCHAR(5), 
	
		prf_physn_npi_1 BIGINT,
		prf_physn_npi_2 BIGINT,
		prf_physn_npi_3 BIGINT,
		prf_physn_npi_4 BIGINT,
		prf_physn_npi_5 BIGINT,
		prf_physn_npi_6 BIGINT,
		prf_physn_npi_7 BIGINT,
		prf_physn_npi_8 BIGINT,
		prf_physn_npi_9 BIGINT,
		prf_physn_npi_10 BIGINT,
		prf_physn_npi_11 BIGINT,
		prf_physn_npi_12 BIGINT,
		prf_physn_npi_13 BIGINT,
	
		tax_num_1 BIGINT,
		tax_num_2 BIGINT,
		tax_num_3 BIGINT,
		tax_num_4 BIGINT,
		tax_num_5 BIGINT,
		tax_num_6 BIGINT,
		tax_num_7 BIGINT,
		tax_num_8 BIGINT,
		tax_num_9 BIGINT,
		tax_num_10 BIGINT,
		tax_num_11 BIGINT,
		tax_num_12 BIGINT,
		tax_num_13 BIGINT,
	
		hcpcs_cd_1 VARCHAR(5), 
		hcpcs_cd_2 VARCHAR(5), 
		hcpcs_cd_3 VARCHAR(5), 
		hcpcs_cd_4 VARCHAR(5), 
		hcpcs_cd_5 VARCHAR(5), 
		hcpcs_cd_6 VARCHAR(5), 
		hcpcs_cd_7 VARCHAR(5), 
		hcpcs_cd_8 VARCHAR(5), 
		hcpcs_cd_9 VARCHAR(5), 
		hcpcs_cd_10 VARCHAR(5), 
		hcpcs_cd_11 VARCHAR(5), 
		hcpcs_cd_12 VARCHAR(5), 
		hcpcs_cd_13 VARCHAR(5), 
	
		line_nch_pmt_amt_1 NUMERIC(5, 2),
		line_nch_pmt_amt_2 NUMERIC(5, 2),
		line_nch_pmt_amt_3 NUMERIC(5, 2),
		line_nch_pmt_amt_4 NUMERIC(5, 2),
		line_nch_pmt_amt_5 NUMERIC(5, 2),
		line_nch_pmt_amt_6 NUMERIC(5, 2),
		line_nch_pmt_amt_7 NUMERIC(5, 2),
		line_nch_pmt_amt_8 NUMERIC(5, 2),
		line_nch_pmt_amt_9 NUMERIC(5, 2),
		line_nch_pmt_amt_10 NUMERIC(5, 2),
		line_nch_pmt_amt_11 NUMERIC(5, 2),
		line_nch_pmt_amt_12 NUMERIC(5, 2),
		line_nch_pmt_amt_13 NUMERIC(5, 2),
	
		line_bene_ptb_ddctbl_amt_1 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_2 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_3 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_4 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_5 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_6 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_7 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_8 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_9 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_10 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_11 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_12 NUMERIC(5, 2),
		line_bene_ptb_ddctbl_amt_13 NUMERIC(5, 2),
	
		line_bene_prmry_pyr_pd_amt_1 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_2 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_3 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_4 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_5 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_6 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_7 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_8 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_9 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_10 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_11 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_12 NUMERIC(6, 2),
		line_bene_prmry_pyr_pd_amt_13 NUMERIC(6, 2),
	
		line_coinsrnc_amt_1 NUMERIC(5, 2),
		line_coinsrnc_amt_2 NUMERIC(5, 2),
		line_coinsrnc_amt_3 NUMERIC(5, 2),
		line_coinsrnc_amt_4 NUMERIC(5, 2),
		line_coinsrnc_amt_5 NUMERIC(5, 2),
		line_coinsrnc_amt_6 NUMERIC(5, 2),
		line_coinsrnc_amt_7 NUMERIC(5, 2),
		line_coinsrnc_amt_8 NUMERIC(5, 2),
		line_coinsrnc_amt_9 NUMERIC(5, 2),
		line_coinsrnc_amt_10 NUMERIC(5, 2),
		line_coinsrnc_amt_11 NUMERIC(5, 2),
		line_coinsrnc_amt_12 NUMERIC(5, 2),
		line_coinsrnc_amt_13 NUMERIC(5, 2),
	
		line_alowd_chrg_amt_1 NUMERIC(5, 2),
		line_alowd_chrg_amt_2 NUMERIC(5, 2),
		line_alowd_chrg_amt_3 NUMERIC(5, 2),
		line_alowd_chrg_amt_4 NUMERIC(5, 2),
		line_alowd_chrg_amt_5 NUMERIC(5, 2),
		line_alowd_chrg_amt_6 NUMERIC(5, 2),
		line_alowd_chrg_amt_7 NUMERIC(5, 2),
		line_alowd_chrg_amt_8 NUMERIC(5, 2),
		line_alowd_chrg_amt_9 NUMERIC(5, 2),
		line_alowd_chrg_amt_10 NUMERIC(5, 2),
		line_alowd_chrg_amt_11 NUMERIC(5, 2),
		line_alowd_chrg_amt_12 NUMERIC(5, 2),
		line_alowd_chrg_amt_13 NUMERIC(5, 2),
	
		line_prcsg_ind_cd_1 CHAR(1),
		line_prcsg_ind_cd_2 CHAR(1),
		line_prcsg_ind_cd_3 CHAR(1),
		line_prcsg_ind_cd_4 CHAR(1),
		line_prcsg_ind_cd_5 CHAR(1),
		line_prcsg_ind_cd_6 CHAR(1),
		line_prcsg_ind_cd_7 CHAR(1),
		line_prcsg_ind_cd_8 CHAR(1),
		line_prcsg_ind_cd_9 CHAR(1),
		line_prcsg_ind_cd_10 CHAR(1),
		line_prcsg_ind_cd_11 CHAR(1),
		line_prcsg_ind_cd_12 CHAR(1),
		line_prcsg_ind_cd_13 CHAR(1),
	
		line_icd9_dgns_cd_1 VARCHAR(5), 
		line_icd9_dgns_cd_2 VARCHAR(5), 
		line_icd9_dgns_cd_3 VARCHAR(5), 
		line_icd9_dgns_cd_4 VARCHAR(5), 
		line_icd9_dgns_cd_5 VARCHAR(5), 
		line_icd9_dgns_cd_6 VARCHAR(5), 
		line_icd9_dgns_cd_7 VARCHAR(5), 
		line_icd9_dgns_cd_8 VARCHAR(5), 
		line_icd9_dgns_cd_9 VARCHAR(5), 
		line_icd9_dgns_cd_10 VARCHAR(5), 
		line_icd9_dgns_cd_11 VARCHAR(5), 
		line_icd9_dgns_cd_12 VARCHAR(5), 
		line_icd9_dgns_cd_13 VARCHAR(5)
	);
	
	COPY carrier_claims (
	
		desynpuf_id,
	 	clm_id,
		clm_from_dt,
		clm_thru_dt,
	
		icd9_dgns_cd_1,
		icd9_dgns_cd_2,
		icd9_dgns_cd_3,
		icd9_dgns_cd_4,
		icd9_dgns_cd_5,
		icd9_dgns_cd_6,
		icd9_dgns_cd_7,
		icd9_dgns_cd_8,
	
		prf_physn_npi_1,
		prf_physn_npi_2,
		prf_physn_npi_3,
		prf_physn_npi_4,
		prf_physn_npi_5,
		prf_physn_npi_6,
		prf_physn_npi_7,
		prf_physn_npi_8,
		prf_physn_npi_9,
		prf_physn_npi_10,
		prf_physn_npi_11,
		prf_physn_npi_12,
		prf_physn_npi_13,
	
		tax_num_1,
		tax_num_2,
		tax_num_3,
		tax_num_4,
		tax_num_5,
		tax_num_6,
		tax_num_7,
		tax_num_8,
		tax_num_9,
		tax_num_10,
		tax_num_11,
		tax_num_12,
		tax_num_13,
	
		hcpcs_cd_1,
		hcpcs_cd_2,
		hcpcs_cd_3,
		hcpcs_cd_4,
		hcpcs_cd_5,
		hcpcs_cd_6,
		hcpcs_cd_7,
		hcpcs_cd_8,
		hcpcs_cd_9,
		hcpcs_cd_10,
		hcpcs_cd_11,
		hcpcs_cd_12,
		hcpcs_cd_13,
	
		line_nch_pmt_amt_1,
		line_nch_pmt_amt_2,
		line_nch_pmt_amt_3,
		line_nch_pmt_amt_4,
		line_nch_pmt_amt_5,
		line_nch_pmt_amt_6,
		line_nch_pmt_amt_7,
		line_nch_pmt_amt_8,
		line_nch_pmt_amt_9,
		line_nch_pmt_amt_10,
		line_nch_pmt_amt_11,
		line_nch_pmt_amt_12,
		line_nch_pmt_amt_13,
	
		line_bene_ptb_ddctbl_amt_1,
		line_bene_ptb_ddctbl_amt_2,
		line_bene_ptb_ddctbl_amt_3,
		line_bene_ptb_ddctbl_amt_4,
		line_bene_ptb_ddctbl_amt_5,
		line_bene_ptb_ddctbl_amt_6,
		line_bene_ptb_ddctbl_amt_7,
		line_bene_ptb_ddctbl_amt_8,
		line_bene_ptb_ddctbl_amt_9,
		line_bene_ptb_ddctbl_amt_10,
		line_bene_ptb_ddctbl_amt_11,
		line_bene_ptb_ddctbl_amt_12,
		line_bene_ptb_ddctbl_amt_13,
	
		line_bene_prmry_pyr_pd_amt_1,
		line_bene_prmry_pyr_pd_amt_2,
		line_bene_prmry_pyr_pd_amt_3,
		line_bene_prmry_pyr_pd_amt_4,
		line_bene_prmry_pyr_pd_amt_5,
		line_bene_prmry_pyr_pd_amt_6,
		line_bene_prmry_pyr_pd_amt_7,
		line_bene_prmry_pyr_pd_amt_8,
		line_bene_prmry_pyr_pd_amt_9,
		line_bene_prmry_pyr_pd_amt_10,
		line_bene_prmry_pyr_pd_amt_11,
		line_bene_prmry_pyr_pd_amt_12,
		line_bene_prmry_pyr_pd_amt_13,
	
		line_coinsrnc_amt_1,
		line_coinsrnc_amt_2,
		line_coinsrnc_amt_3,
		line_coinsrnc_amt_4,
		line_coinsrnc_amt_5,
		line_coinsrnc_amt_6,
		line_coinsrnc_amt_7,
		line_coinsrnc_amt_8,
		line_coinsrnc_amt_9,
		line_coinsrnc_amt_10,
		line_coinsrnc_amt_11,
		line_coinsrnc_amt_12,
		line_coinsrnc_amt_13,
	
		line_alowd_chrg_amt_1,
		line_alowd_chrg_amt_2,
		line_alowd_chrg_amt_3,
		line_alowd_chrg_amt_4,
		line_alowd_chrg_amt_5,
		line_alowd_chrg_amt_6,
		line_alowd_chrg_amt_7,
		line_alowd_chrg_amt_8,
		line_alowd_chrg_amt_9,
		line_alowd_chrg_amt_10,
		line_alowd_chrg_amt_11,
		line_alowd_chrg_amt_12,
		line_alowd_chrg_amt_13,
	
		line_prcsg_ind_cd_1,
		line_prcsg_ind_cd_2,
		line_prcsg_ind_cd_3,
		line_prcsg_ind_cd_4,
		line_prcsg_ind_cd_5,
		line_prcsg_ind_cd_6,
		line_prcsg_ind_cd_7,
		line_prcsg_ind_cd_8,
		line_prcsg_ind_cd_9,
		line_prcsg_ind_cd_10,
		line_prcsg_ind_cd_11,
		line_prcsg_ind_cd_12,
		line_prcsg_ind_cd_13,
	
		line_icd9_dgns_cd_1,
		line_icd9_dgns_cd_2,
		line_icd9_dgns_cd_3,
		line_icd9_dgns_cd_4,
		line_icd9_dgns_cd_5,
		line_icd9_dgns_cd_6,
		line_icd9_dgns_cd_7,
		line_icd9_dgns_cd_8,
		line_icd9_dgns_cd_9,
		line_icd9_dgns_cd_10,
		line_icd9_dgns_cd_11,
		line_icd9_dgns_cd_12,
		line_icd9_dgns_cd_13
	)
	
	FROM 'F:\DE-SynPUFs\2008 to 2010 Carrier Claims\DE1_0_2008_to_2010_Carrier_Claims_Sample_1A.csv'
	DELIMITER ','
	CSV HEADER;
	
	
	RAISE INFO 'Import carrier_claims - Part B ...';
	
	COPY carrier_claims (
	
		desynpuf_id,
	 	clm_id,
		clm_from_dt,
		clm_thru_dt,
	
		icd9_dgns_cd_1,
		icd9_dgns_cd_2,
		icd9_dgns_cd_3,
		icd9_dgns_cd_4,
		icd9_dgns_cd_5,
		icd9_dgns_cd_6,
		icd9_dgns_cd_7,
		icd9_dgns_cd_8,
	
		prf_physn_npi_1,
		prf_physn_npi_2,
		prf_physn_npi_3,
		prf_physn_npi_4,
		prf_physn_npi_5,
		prf_physn_npi_6,
		prf_physn_npi_7,
		prf_physn_npi_8,
		prf_physn_npi_9,
		prf_physn_npi_10,
		prf_physn_npi_11,
		prf_physn_npi_12,
		prf_physn_npi_13,
	
		tax_num_1,
		tax_num_2,
		tax_num_3,
		tax_num_4,
		tax_num_5,
		tax_num_6,
		tax_num_7,
		tax_num_8,
		tax_num_9,
		tax_num_10,
		tax_num_11,
		tax_num_12,
		tax_num_13,
	
		hcpcs_cd_1,
		hcpcs_cd_2,
		hcpcs_cd_3,
		hcpcs_cd_4,
		hcpcs_cd_5,
		hcpcs_cd_6,
		hcpcs_cd_7,
		hcpcs_cd_8,
		hcpcs_cd_9,
		hcpcs_cd_10,
		hcpcs_cd_11,
		hcpcs_cd_12,
		hcpcs_cd_13,
	
		line_nch_pmt_amt_1,
		line_nch_pmt_amt_2,
		line_nch_pmt_amt_3,
		line_nch_pmt_amt_4,
		line_nch_pmt_amt_5,
		line_nch_pmt_amt_6,
		line_nch_pmt_amt_7,
		line_nch_pmt_amt_8,
		line_nch_pmt_amt_9,
		line_nch_pmt_amt_10,
		line_nch_pmt_amt_11,
		line_nch_pmt_amt_12,
		line_nch_pmt_amt_13,
	
		line_bene_ptb_ddctbl_amt_1,
		line_bene_ptb_ddctbl_amt_2,
		line_bene_ptb_ddctbl_amt_3,
		line_bene_ptb_ddctbl_amt_4,
		line_bene_ptb_ddctbl_amt_5,
		line_bene_ptb_ddctbl_amt_6,
		line_bene_ptb_ddctbl_amt_7,
		line_bene_ptb_ddctbl_amt_8,
		line_bene_ptb_ddctbl_amt_9,
		line_bene_ptb_ddctbl_amt_10,
		line_bene_ptb_ddctbl_amt_11,
		line_bene_ptb_ddctbl_amt_12,
		line_bene_ptb_ddctbl_amt_13,
	
		line_bene_prmry_pyr_pd_amt_1,
		line_bene_prmry_pyr_pd_amt_2,
		line_bene_prmry_pyr_pd_amt_3,
		line_bene_prmry_pyr_pd_amt_4,
		line_bene_prmry_pyr_pd_amt_5,
		line_bene_prmry_pyr_pd_amt_6,
		line_bene_prmry_pyr_pd_amt_7,
		line_bene_prmry_pyr_pd_amt_8,
		line_bene_prmry_pyr_pd_amt_9,
		line_bene_prmry_pyr_pd_amt_10,
		line_bene_prmry_pyr_pd_amt_11,
		line_bene_prmry_pyr_pd_amt_12,
		line_bene_prmry_pyr_pd_amt_13,
	
		line_coinsrnc_amt_1,
		line_coinsrnc_amt_2,
		line_coinsrnc_amt_3,
		line_coinsrnc_amt_4,
		line_coinsrnc_amt_5,
		line_coinsrnc_amt_6,
		line_coinsrnc_amt_7,
		line_coinsrnc_amt_8,
		line_coinsrnc_amt_9,
		line_coinsrnc_amt_10,
		line_coinsrnc_amt_11,
		line_coinsrnc_amt_12,
		line_coinsrnc_amt_13,
	
		line_alowd_chrg_amt_1,
		line_alowd_chrg_amt_2,
		line_alowd_chrg_amt_3,
		line_alowd_chrg_amt_4,
		line_alowd_chrg_amt_5,
		line_alowd_chrg_amt_6,
		line_alowd_chrg_amt_7,
		line_alowd_chrg_amt_8,
		line_alowd_chrg_amt_9,
		line_alowd_chrg_amt_10,
		line_alowd_chrg_amt_11,
		line_alowd_chrg_amt_12,
		line_alowd_chrg_amt_13,
	
		line_prcsg_ind_cd_1,
		line_prcsg_ind_cd_2,
		line_prcsg_ind_cd_3,
		line_prcsg_ind_cd_4,
		line_prcsg_ind_cd_5,
		line_prcsg_ind_cd_6,
		line_prcsg_ind_cd_7,
		line_prcsg_ind_cd_8,
		line_prcsg_ind_cd_9,
		line_prcsg_ind_cd_10,
		line_prcsg_ind_cd_11,
		line_prcsg_ind_cd_12,
		line_prcsg_ind_cd_13,
	
		line_icd9_dgns_cd_1,
		line_icd9_dgns_cd_2,
		line_icd9_dgns_cd_3,
		line_icd9_dgns_cd_4,
		line_icd9_dgns_cd_5,
		line_icd9_dgns_cd_6,
		line_icd9_dgns_cd_7,
		line_icd9_dgns_cd_8,
		line_icd9_dgns_cd_9,
		line_icd9_dgns_cd_10,
		line_icd9_dgns_cd_11,
		line_icd9_dgns_cd_12,
		line_icd9_dgns_cd_13
	)
	
	FROM 'F:\DE-SynPUFs\2008 to 2010 Carrier Claims\DE1_0_2008_to_2010_Carrier_Claims_Sample_1B.csv'
	DELIMITER ','
	CSV HEADER;
	
	RETURN TRUE;

END $$;
	
/*
-----------------------------------------------------------------------------------------------------------------------
   Import Prescription Drug Events
-----------------------------------------------------------------------------------------------------------------------
*/

CREATE OR REPLACE FUNCTION import_rx_drug_events ()
RETURNS BOOLEAN
LANGUAGE plpgsql
AS

$$
BEGIN

	DROP TABLE IF EXISTS rx_drug_events;
	
	RAISE INFO 'Import rx_drug_events ...';
	
	CREATE TABLE rx_drug_events (
	  
		desynpuf_id BYTEA, 
		pde_id BIGINT, 
		srvc_dt DATE, 
		prod_srvc_id CHAR(11), 
		qty_dspnsd_num NUMERIC(6, 3), 
		days_suply_num SMALLINT, 
		ptnt_pay_amt NUMERIC(6, 2), 
		tot_rx_cst_amt NUMERIC(6, 2)
	);
	
	COPY rx_drug_events (
	
		desynpuf_id, 
		pde_id, 
		srvc_dt, 
		prod_srvc_id, 
		qty_dspnsd_num, 
		days_suply_num, 
		ptnt_pay_amt, 
		tot_rx_cst_amt
	)
	
	FROM 'F:\DE-SynPUFs\Prescription Drug Events\DE1_0_2008_to_2010_Prescription_Drug_Events_Sample_1.csv'
	DELIMITER ','
	CSV HEADER;
	
	RETURN True;

END $$;


/*
-----------------------------------------------------------------------------------------------------------------------
   CALL ALL IMPORT FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------
*/


SELECT import_beneficiary_summaries();
SELECT import_inpatient_claims();
SELECT import_outpatient_claims();
SELECT import_carrier_claims();
SELECT import_rx_drug_events();


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Import NDC Descriptions
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE ndc_package (
	
	product_id VARCHAR(47), 
	product_ndc VARCHAR(10), 
	ndc_package_code VARCHAR(12),
	package_description VARCHAR(2429), 
	start_marketing_date DATE, 
	end_marketing_date DATE,
	ndc_exclude_flag CHAR(1), 
	sample_package CHAR(1)
);

COPY ndc_package (
	
	product_id, 
	product_ndc, 
	ndc_package_code, 
	package_description, 
	start_marketing_date, 
	end_marketing_date, 
	ndc_exclude_flag, 
	sample_package 
)

FROM 'F:\MedicareAnalysis\NDC_2025\NDC_package.csv'
DELIMITER ','
CSV HEADER;


CREATE TABLE ndc_product (
	
	product_id VARCHAR(47), 
	product_ndc VARCHAR(10), 
	product_type_name VARCHAR(27), 
	proprietary_name VARCHAR(257), 
	proprietary_name_suffix VARCHAR(125), 
	non_proprietary_name VARCHAR(512), 
	dosage_form_name VARCHAR(46), 
	route_name VARCHAR(122), 
	start_marketing_date DATE, 
	end_marketing_date DATE, 
	marketing_category_name VARCHAR(40), 
	application_number VARCHAR(12), 
	labeler_name VARCHAR(121), 
	substance_name VARCHAR(2560), 
	active_numerator_strength VARCHAR(399), 
	active_ingred_unit VARCHAR(1120), 
	pharm_classes VARCHAR(3997), 
	dea_schedule VARCHAR(4), 
	ndc_exclude_flag CHAR(1), 
	listing_record_certified_through DATE
);

COPY ndc_product (
	
	product_id, 
	product_ndc, 
	product_type_name, 
	proprietary_name, 
	proprietary_name_suffix, 
	non_proprietary_name, 
	dosage_form_name, 
	route_name, 
	start_marketing_date, 
	end_marketing_date, 
	marketing_category_name, 
	application_number, 
	labeler_name, 
	substance_name, 
	active_numerator_strength, 
	active_ingred_unit, 
	pharm_classes, 
	dea_schedule, 
	ndc_exclude_flag, 
	listing_record_certified_through 
)

FROM 'F:\MedicareAnalysis\NDC_2025\NDC_product.csv'
DELIMITER ','
CSV HEADER;



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Import ICD9 Descriptions
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

-- import the data from csv

CREATE TABLE icd9_included (
	
	code VARCHAR(5), 
	description VARCHAR(222)
);

COPY icd9_included (
	
	code, 
	description
)

FROM 'F:\MedicareAnalysis\ICD9_2025\ICD9_included_2025_01.csv'
DELIMITER ','
CSV;			-- no header in this csv file


CREATE TABLE icd9_excluded (
	
	code VARCHAR(5), 
	description VARCHAR(222)
);

COPY icd9_excluded (
	
	code, 
	description
)

FROM 'F:\MedicareAnalysis\ICD9_2025\ICD9_excluded_2025_01.csv'
DELIMITER ','
CSV;			-- no header in this csv file


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Import HCPCS-17 Descriptions
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE hcpcs17 (
	
	hcpc CHAR(5), 
	seq_num CHAR(4),
	rec_id CHAR(1),
	desc_long VARCHAR(1253),
	desc_short VARCHAR(28),
	add_dt DATE,
	act_eff_dt DATE,
	term_dt DATE,
	action_cd CHAR(1)
);

COPY hcpcs17 (
	
	hcpc, 
	seq_num,
	rec_id,
	desc_long,
	desc_short,
	add_dt,
	act_eff_dt,
	term_dt,
	action_cd
)

FROM 'F:\MedicareAnalysis\HCPCS_2017\HCPC17_CONTR_ANWEB.csv'
DELIMITER ','
CSV HEADER;


-- drop any columns with information that is not useful for this project

ALTER TABLE hcpcs17
DROP COLUMN seq_num;

ALTER TABLE hcpcs17
DROP COLUMN rec_id;



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	CMS Relative Value
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE cms_rvu_2010 (
	
	hcpcs CHAR(5), 
	modifier VARCHAR,
	description VARCHAR(28),
	status CHAR(1),
	not_used_for_medicare VARCHAR(1),
	work_rvu NUMERIC(8, 2),
	transitioned_nonfac_pe_rvu NUMERIC(8, 2),
	transitioned_nonfac_na VARCHAR(2),
	fully_implemented_nonfac_pe_rvu NUMERIC(8, 2),
	fully_implemented_nonfac VARCHAR(2),
	transitioned_facility_pe_rvu NUMERIC(8, 2),
	transitioned_facility VARCHAR(2),
	fully_implemented_facility_pe_rvu NUMERIC(8, 2),
	fully_implemented_facility VARCHAR(2),
	mp_rvu NUMERIC(8, 2),
	transitioned_nonfac_tot NUMERIC(8, 2),
	fully_implemented_nonfac_tot NUMERIC(8, 2),
	transitioned_facility_tot NUMERIC(8, 2),
	fully_implemented_facility_tot NUMERIC(8, 2),
	ptc_ind CHAR(1),
	glob_days CHAR(3),
	pre_op NUMERIC(3, 2),
	intra_op NUMERIC(3, 2),
	post_op NUMERIC(3, 2),
	multi_procedure SMALLINT,
	bilateral_surgery SMALLINT,
	asst_at_surgery SMALLINT,
	co_surgeons SMALLINT,
	team_surgery SMALLINT,
	endo_base_code VARCHAR(5),
	conversion_factor NUMERIC(6, 4),
	phys_supervised_diag CHAR(2),
	calc_flag SMALLINT,
	diag_img_fam SMALLINT,
	nonfac_pe_opp NUMERIC(8, 2),
	facility_pe_opp NUMERIC(8, 2),
	mp_opp NUMERIC(8, 2)
	
);

COPY cms_rvu_2010 (
	
	hcpcs,
	modifier,
	description,
	status,
	not_used_for_medicare,
	work_rvu,
	transitioned_nonfac_pe_rvu,
	transitioned_nonfac_na,
	fully_implemented_nonfac_pe_rvu,
	fully_implemented_nonfac,
	transitioned_facility_pe_rvu,
	transitioned_facility,
	fully_implemented_facility_pe_rvu,
	fully_implemented_facility,
	mp_rvu,
	transitioned_nonfac_tot,
	fully_implemented_nonfac_tot,
	transitioned_facility_tot,
	fully_implemented_facility_tot,
	ptc_ind,
	glob_days,
	pre_op,
	intra_op,
	post_op,
	multi_procedure,
	bilateral_surgery,
	asst_at_surgery,
	co_surgeons,
	team_surgery,
	endo_base_code,
	conversion_factor,
	phys_supervised_diag,
	calc_flag,
	diag_img_fam,
	nonfac_pe_opp,
	facility_pe_opp,
	mp_opp
)

-- The PPRRVU10_U22 file was edited to remove the first 9 descriptive rows that interfere with importing of data

FROM 'F:\MedicareAnalysis\CMS_Relative_Value_2010\PPRRVU10_U22_edited.csv'
DELIMITER ','
CSV HEADER;


