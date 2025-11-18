/*
-----------------------------------------------------------------------------------------------------------------------
	Create tables in Azure postgresql server so that CSV files can be imported in Azure Data Factory.
   
	Uses only sample 1 of 20 in the De-SynPUF dataset
-----------------------------------------------------------------------------------------------------------------------
*/

-- --------------------------------------------------------------------------------------------------------------------
--   Create Beneficiary Summary Tables
-- --------------------------------------------------------------------------------------------------------------------
	
CREATE TABLE beneficiary_summary_2008 (

	-- No hex data type in postgresql, and cannot read from csv directly to bigint.
	-- Read as string, then convert later into bigint
	-- Will convert to bigint in later steps so it's more efficient in Power BI
	desynpuf_id VARCHAR(16), 
	
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
	benres_car NUMERIC(8, 2),
	pppymt_car NUMERIC(8, 2)
);


CREATE TABLE beneficiary_summary_2009 (

	desynpuf_id VARCHAR(16), 
	
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
	benres_car NUMERIC(8, 2),
	pppymt_car NUMERIC(8, 2)
);


CREATE TABLE beneficiary_summary_2010 (

	desynpuf_id VARCHAR(16), 
	
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
	benres_car NUMERIC(8, 2),
	pppymt_car NUMERIC(8, 2)
);


-- --------------------------------------------------------------------------------------------------------------------
--   Create Inpatient Claims Table
-- --------------------------------------------------------------------------------------------------------------------

CREATE TABLE inpatient_claims (

	desynpuf_id VARCHAR(16),
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


-- --------------------------------------------------------------------------------------------------------------------
--   Create Outpatient Claims Tables
-- --------------------------------------------------------------------------------------------------------------------

CREATE TABLE outpatient_claims (

	desynpuf_id VARCHAR(16),
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


-- --------------------------------------------------------------------------------------------------------------------
--   Create Carrier Claims Table
-- --------------------------------------------------------------------------------------------------------------------
		
	CREATE TABLE carrier_claims (
	  
		desynpuf_id VARCHAR(16),
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
	
		line_nch_pmt_amt_1 NUMERIC(8, 2),
		line_nch_pmt_amt_2 NUMERIC(8, 2),
		line_nch_pmt_amt_3 NUMERIC(8, 2),
		line_nch_pmt_amt_4 NUMERIC(8, 2),
		line_nch_pmt_amt_5 NUMERIC(8, 2),
		line_nch_pmt_amt_6 NUMERIC(8, 2),
		line_nch_pmt_amt_7 NUMERIC(8, 2),
		line_nch_pmt_amt_8 NUMERIC(8, 2),
		line_nch_pmt_amt_9 NUMERIC(8, 2),
		line_nch_pmt_amt_10 NUMERIC(8, 2),
		line_nch_pmt_amt_11 NUMERIC(8, 2),
		line_nch_pmt_amt_12 NUMERIC(8, 2),
		line_nch_pmt_amt_13 NUMERIC(8, 2),
	
		line_bene_ptb_ddctbl_amt_1 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_2 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_3 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_4 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_5 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_6 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_7 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_8 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_9 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_10 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_11 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_12 NUMERIC(8, 2),
		line_bene_ptb_ddctbl_amt_13 NUMERIC(8, 2),
	
		line_bene_prmry_pyr_pd_amt_1 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_2 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_3 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_4 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_5 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_6 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_7 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_8 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_9 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_10 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_11 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_12 NUMERIC(8, 2),
		line_bene_prmry_pyr_pd_amt_13 NUMERIC(8, 2),
	
		line_coinsrnc_amt_1 NUMERIC(8, 2),
		line_coinsrnc_amt_2 NUMERIC(8, 2),
		line_coinsrnc_amt_3 NUMERIC(8, 2),
		line_coinsrnc_amt_4 NUMERIC(8, 2),
		line_coinsrnc_amt_5 NUMERIC(8, 2),
		line_coinsrnc_amt_6 NUMERIC(8, 2),
		line_coinsrnc_amt_7 NUMERIC(8, 2),
		line_coinsrnc_amt_8 NUMERIC(8, 2),
		line_coinsrnc_amt_9 NUMERIC(8, 2),
		line_coinsrnc_amt_10 NUMERIC(8, 2),
		line_coinsrnc_amt_11 NUMERIC(8, 2),
		line_coinsrnc_amt_12 NUMERIC(8, 2),
		line_coinsrnc_amt_13 NUMERIC(8, 2),
	
		line_alowd_chrg_amt_1 NUMERIC(8, 2),
		line_alowd_chrg_amt_2 NUMERIC(8, 2),
		line_alowd_chrg_amt_3 NUMERIC(8, 2),
		line_alowd_chrg_amt_4 NUMERIC(8, 2),
		line_alowd_chrg_amt_5 NUMERIC(8, 2),
		line_alowd_chrg_amt_6 NUMERIC(8, 2),
		line_alowd_chrg_amt_7 NUMERIC(8, 2),
		line_alowd_chrg_amt_8 NUMERIC(8, 2),
		line_alowd_chrg_amt_9 NUMERIC(8, 2),
		line_alowd_chrg_amt_10 NUMERIC(8, 2),
		line_alowd_chrg_amt_11 NUMERIC(8, 2),
		line_alowd_chrg_amt_12 NUMERIC(8, 2),
		line_alowd_chrg_amt_13 NUMERIC(8, 2),
	
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
	

-- --------------------------------------------------------------------------------------------------------------------
--   Create Prescription Drug Events Table
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS rx_drug_events;
CREATE TABLE rx_drug_events (
	
	desynpuf_id VARCHAR(16), 
	pde_id BIGINT, 
	srvc_dt DATE, 					
	prod_srvc_id CHAR(11), 			-- RENAMED to ndc11 for National Drug Code (NDC) 11-digit standard
									-- Exceeds the limits of bigint. Must be char
	qty_dspnsd_num NUMERIC(6, 3), 	-- 0.000 precision 
	days_suply_num SMALLINT, 
	ptnt_pay_amt NUMERIC(8, 2), 
	tot_rx_cst_amt NUMERIC(8, 2)
);
	

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Create NDC 2018 & 2025 Tables
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ndc2018_package;
CREATE TABLE ndc2018_package (
	
	product_id VARCHAR, 
	product_ndc VARCHAR, 
	ndc10 VARCHAR,
	package_description VARCHAR, 
	start_marketing_date_str VARCHAR, 
	start_marketing_date DATE, 
	end_marketing_date_str VARCHAR,
	end_marketing_date DATE,
	exclude_flag CHAR(1), 
	sample_package CHAR(1)
);

DROP TABLE IF EXISTS ndc2018_product;
CREATE TABLE ndc2018_product (
	
	product_id VARCHAR, 
	product_ndc VARCHAR, 
	product_type_name VARCHAR, 
	proprietary_name VARCHAR, 
	proprietary_name_suffix VARCHAR, 
	non_proprietary_name VARCHAR, 
	dosage_form_name VARCHAR, 
	route_name VARCHAR, 
	start_marketing_date_str VARCHAR, 
	start_marketing_date DATE, 
	end_marketing_date_str VARCHAR, 
	end_marketing_date DATE, 
	marketing_category_name VARCHAR, 
	application_number VARCHAR, 
	labeler_name VARCHAR, 
	substance_name VARCHAR, 
	active_numerator_strength VARCHAR, 
	active_ingred_unit VARCHAR, 
	pharm_classes VARCHAR, 
	dea_schedule VARCHAR, 
	exclude_flag CHAR, 
	listing_record_certified_through_str VARCHAR,
	listing_record_certified_through DATE
);

DROP TABLE IF EXISTS ndc2025_package;
CREATE TABLE ndc2025_package (
	
	product_id VARCHAR, 
	product_ndc VARCHAR, 
	ndc10 VARCHAR,
	package_description VARCHAR, 
	start_marketing_date DATE, 
	end_marketing_date DATE,
	ndc_exclude_flag CHAR(1), 
	sample_package CHAR(1)
);

DROP TABLE IF EXISTS ndc2025_product;
CREATE TABLE ndc2025_product (
	
	product_id VARCHAR, 
	product_ndc VARCHAR, 
	product_type_name VARCHAR, 
	proprietary_name VARCHAR, 
	proprietary_name_suffix VARCHAR, 
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
	dea_schedule VARCHAR, 
	ndc_exclude_flag CHAR(1), 
	listing_record_certified_through DATE
);

-- --------------------------------------------------------------------------------------------------------------------
--  Create NDC 2008 & 2010 & 2012 Tables
-- --------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS NDC2008_listings;
CREATE TABLE NDC2008_listings (

    listing_seq_no INT,
    lblcode VARCHAR,
    prodcode VARCHAR,
    strength VARCHAR,
    unit VARCHAR,
    rx_otc VARCHAR,
    tradename VARCHAR
);

DROP TABLE IF EXISTS NDC2008_packages;
CREATE TABLE NDC2008_packages (

    listing_seq_no INT,
    pkgcode VARCHAR,
    packsize VARCHAR,
    packtype VARCHAR
);

DROP TABLE IF EXISTS NDC2010_listings;
CREATE TABLE NDC2010_listings (

    listing_seq_no INT,
    lblcode VARCHAR,
    prodcode VARCHAR,
    strength VARCHAR,
    unit VARCHAR,
    rx_otc VARCHAR,
    tradename VARCHAR
);

DROP TABLE IF EXISTS NDC2010_packages;
CREATE TABLE NDC2010_packages (

    listing_seq_no INT,
    pkgcode VARCHAR,
    packsize VARCHAR,
    packtype VARCHAR
);

DROP TABLE IF EXISTS NDC2012_listings;
CREATE TABLE NDC2012_listings (

    listing_seq_no INT,
    lblcode VARCHAR,
    prodcode VARCHAR,
    strength VARCHAR,
    unit VARCHAR,
    rx_otc VARCHAR,
    tradename VARCHAR
);

DROP TABLE IF EXISTS NDC2012_packages;
CREATE TABLE NDC2012_packages (

    listing_seq_no INT,
    pkgcode VARCHAR,
    packsize VARCHAR,
    packtype VARCHAR
);


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Create ICD9 Descriptions Tables
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

-- import the data from csv

CREATE TABLE icd9_included (
	
	code VARCHAR, 
	description VARCHAR
);


CREATE TABLE icd9_excluded (
	
	code VARCHAR, 
	description VARCHAR
);


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Create HCPCS-17 Table
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


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Create CMS Relative Value Table
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
	pre_op NUMERIC(8, 2),
	intra_op NUMERIC(8, 2),
	post_op NUMERIC(8, 2),
	multi_procedure SMALLINT,
	bilateral_surgery SMALLINT,
	asst_at_surgery SMALLINT,
	co_surgeons SMALLINT,
	team_surgery SMALLINT,
	endo_base_code VARCHAR(5),
	conversion_factor NUMERIC(8, 4),
	phys_supervised_diag CHAR(2),
	calc_flag SMALLINT,
	diag_img_fam SMALLINT,
	nonfac_pe_opp NUMERIC(8, 2),
	facility_pe_opp NUMERIC(8, 2),
	mp_opp NUMERIC(8, 2)
	
);


/*
-----------------------------------------------------------------------------------------------------------------------
   Create State & County Codes Tables
-----------------------------------------------------------------------------------------------------------------------
*/

DROP TABLE IF EXISTS state_codes;
CREATE TABLE state_codes (
	
	state_code SMALLINT, 
	abbreviation VARCHAR(2),
	state VARCHAR
);
	
DROP TABLE IF EXISTS county_codes;
CREATE TABLE county_codes (
	
	state VARCHAR(2), 
	county VARCHAR, 
	eligibles INT,
	enrollees INT,
	penetration NUMERIC(8, 2),
	part_a_aged NUMERIC(8, 2), 
	part_b_aged NUMERIC(8, 2), 
	part_ab_aged NUMERIC(8, 2),
    ssa_county_code VARCHAR(5)
);

DROP TABLE IF EXISTS state_coordinates;
CREATE TABLE state_coordinates (
	
	state_territory VARCHAR, 
	latitude REAL,
	longitude REAL,
	name VARCHAR
);
	
DROP TABLE IF EXISTS county_coordinates_fips;
CREATE TABLE county_coordinates_fips (
	
	cfips VARCHAR, 
	name VARCHAR,
	longitude REAL,
	latitude REAL
);
	

DROP TABLE IF EXISTS county_ssa_fips_crosswalk;
CREATE TABLE county_ssa_fips_crosswalk (
	
	county VARCHAR, 
	state VARCHAR, 
	ssacounty VARCHAR, 
	fipscounty VARCHAR, 
	cbsa VARCHAR, 
	cbsaname VARCHAR, 
	ssastate VARCHAR, 
	fipsstate VARCHAR
);
	
