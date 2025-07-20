/*
-----------------------------------------------------------------------------------------------------------------------
   Prepare the data for Power BI by executing unique functions on each table
   (3-5 min processing time)
-----------------------------------------------------------------------------------------------------------------------
*/

/*
-----------------------------------------------------------------------------------------------------------------------
	Convert desynpuf_id from varchar to bigint

    	Saving beneficiary IDs as varchar uses a huge amount of storage space. 
    	The 16-digit hex-encoded IDs perfectly fill the 8 bytes encoded by a big integer (including the sign)
    	This conversion should save processing time as well as storage space because it is the foundational 
    	identifier used in the DeSynPUF database.
-----------------------------------------------------------------------------------------------------------------------
*/

CREATE OR REPLACE FUNCTION convert_desynpuf_id (
   table_name VARCHAR
)

RETURNS TABLE ( 
	desynpuf_id_bigint BIGINT
)

LANGUAGE plpgsql

AS $$
	
DECLARE

	s TEXT;

BEGIN

	RAISE INFO 'convert_desynpuf_id()      %    ...', table_name;

	-- create a temporary column for the type conversion

	EXECUTE format('ALTER TABLE %I RENAME %I TO col_old', table_name, 'desynpuf_id');
	EXECUTE format('ALTER TABLE %I ADD COLUMN %I BIGINT', table_name, 'desynpuf_id');

	-- conversion from bytea to bigint through a hexadecimal string
	
	EXECUTE format('UPDATE %I SET %I = (''x'' || lpad(%I, 16, ''0''::CHAR))::bit(64)::bigint', table_name, 'desynpuf_id', 'col_old');

	-- drop the old column

	EXECUTE format('ALTER TABLE %I DROP COLUMN %I', table_name, 'col_old');

	-- Return the first 20 entries of the reformatted desynpuf_id as proof the function worked as expected

	s := format('SELECT %I FROM %I LIMIT 20;', 'desynpuf_id', table_name);

	RETURN QUERY EXECUTE s;

END
$$;

-- Execute the function on each table

SELECT convert_desynpuf_id ('beneficiary_summary_2008');
SELECT convert_desynpuf_id ('beneficiary_summary_2009');
SELECT convert_desynpuf_id ('beneficiary_summary_2010');

SELECT convert_desynpuf_id ('carrier_claims');
SELECT convert_desynpuf_id ('inpatient_claims');
SELECT convert_desynpuf_id ('outpatient_claims');
SELECT convert_desynpuf_id ('rx_drug_events');


/*
-----------------------------------------------------------------------------------------------------------------------
   Convert from any two CHARACTERS to a boolean within a single column. Can be used on any given table.
-----------------------------------------------------------------------------------------------------------------------
*/

CREATE OR REPLACE FUNCTION convert_to_boolean (
   table_name VARCHAR,
   col_name VARCHAR,
   true_val CHAR,
   false_val CHAR
)

RETURNS TABLE ( 
	b BOOLEAN,
	c BIGINT
)

LANGUAGE plpgsql

AS $$

DECLARE
	
	t TEXT;
	f TEXT;

BEGIN

	RAISE INFO 'convert_to_boolean()      %    %      ...', table_name, col_name;
	
	-- create a temporary column for the type conversion

	EXECUTE format('ALTER TABLE %I RENAME %I TO col_old', table_name, col_name);
	EXECUTE format('ALTER TABLE %I ADD COLUMN %I BOOLEAN', table_name, col_name);

	-- convert the old column to true and false values
	
	t := format('UPDATE %I SET %I = True WHERE %I = ''%s''', table_name, col_name, 'col_old', true_val);
	RAISE INFO '%', t;
	EXECUTE t;

	f := format('UPDATE %I SET %I = False WHERE %I = ''%s''', table_name, col_name, 'col_old', false_val);
	RAISE INFO '%', f;
	EXECUTE f;

	EXECUTE format('ALTER TABLE %I DROP COLUMN %I', table_name, 'col_old');

	-- Return the total each of True and False rows as proof the function worked as expected

	RETURN QUERY EXECUTE format('SELECT %I, COUNT(%1$I) FROM %2$I GROUP BY %1$I;', col_name, table_name);

END
$$;

-- Execute the function on each table

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'bene_esrd_ind', 'Y', '0');
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'bene_esrd_ind', 'Y', '0');
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'bene_esrd_ind', 'Y', '0');


/*
-----------------------------------------------------------------------------------------------------------------------
   Convert from any two INTEGERS to a boolean within a single column. Can be used on any given table.
-----------------------------------------------------------------------------------------------------------------------
*/

CREATE OR REPLACE FUNCTION convert_to_boolean (
   table_name VARCHAR,
   col_name VARCHAR,
   true_val INT,
   false_val INT
)

RETURNS TABLE ( 
	b BOOLEAN,
	c BIGINT
)

LANGUAGE plpgsql

AS $$

DECLARE
	
	t TEXT;
	f TEXT;

BEGIN

	RAISE INFO 'convert_to_boolean()      %    %      ...', table_name, col_name;
	
	-- create a temporary column for the type conversion

	EXECUTE format('ALTER TABLE %I RENAME %I TO col_old', table_name, col_name);
	EXECUTE format('ALTER TABLE %I ADD COLUMN %I BOOLEAN', table_name, col_name);

	-- convert the old column to true and false values
	
	t := format('UPDATE %I SET %I = True WHERE %I = %s', table_name, col_name, 'col_old', true_val);
	RAISE INFO '%', t;
	EXECUTE t;

	f := format('UPDATE %I SET %I = False WHERE %I = %s', table_name, col_name, 'col_old', false_val);
	RAISE INFO '%', f;
	EXECUTE f;

	EXECUTE format('ALTER TABLE %I DROP COLUMN %I', table_name, 'col_old');

	-- Return the first 5 entries of the reformatted column as proof the function worked as expected

	RETURN QUERY EXECUTE format('SELECT %I, COUNT(%1$I) FROM %2$I GROUP BY %1$I;', col_name, table_name);

END
$$;

-- Execute the function on each table

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'sp_alzhdmta', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'sp_alzhdmta', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'sp_alzhdmta', 1, 2);

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'sp_chf', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'sp_chf', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'sp_chf', 1, 2);

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'sp_chrnkidn', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'sp_chrnkidn', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'sp_chrnkidn', 1, 2);

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'sp_cncr', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'sp_cncr', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'sp_cncr', 1, 2);

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'sp_copd', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'sp_copd', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'sp_copd', 1, 2);

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'sp_depressn', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'sp_depressn', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'sp_depressn', 1, 2);

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'sp_diabetes', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'sp_diabetes', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'sp_diabetes', 1, 2);

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'sp_ischmcht', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'sp_ischmcht', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'sp_ischmcht', 1, 2);

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'sp_osteoprs', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'sp_osteoprs', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'sp_osteoprs', 1, 2);

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'sp_ra_oa', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'sp_ra_oa', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'sp_ra_oa', 1, 2);

SELECT * FROM convert_to_boolean ('beneficiary_summary_2008', 'sp_strketia', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2009', 'sp_strketia', 1, 2);
SELECT * FROM convert_to_boolean ('beneficiary_summary_2010', 'sp_strketia', 1, 2);


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	Convert NDC-10 to NDC-11
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------


ALTER TABLE ndc_package
RENAME COLUMN ndc_package_code TO ndc_package10;


-- divide the NDC-10 package code into the 3 segments

ALTER TABLE ndc_package
ADD seg_1 VARCHAR(5);

UPDATE ndc_package
SET seg_1 = SUBSTRING( ndc_package10 FROM '^[0-9]*') ;


ALTER TABLE ndc_package
ADD seg_2 VARCHAR(4);

UPDATE ndc_package
SET seg_2 = TRIM(BOTH '-' FROM SUBSTRING( ndc_package10 FROM '-[0-9]*-'));


ALTER TABLE ndc_package
ADD seg_3 VARCHAR(2);

UPDATE ndc_package
SET seg_3 = SUBSTRING( ndc_package10 FROM '[0-9]*$');



-- combine the 3 segments into NDC-11

ALTER TABLE ndc_package
ADD ndc_package11 VARCHAR(13);

UPDATE ndc_package
SET ndc_package11 = '0' || seg_1 || seg_2 || seg_3
WHERE LENGTH(seg_1) = 4;

UPDATE ndc_package
SET ndc_package11 = seg_1 || '0' || seg_2 || seg_3
WHERE LENGTH(seg_2) = 3;

UPDATE ndc_package
SET ndc_package11 = seg_1 || seg_2 || '0' || seg_3
WHERE LENGTH(seg_3) = 1;


-- remove dashes in the NDC-10 column, then rename

UPDATE ndc_package
SET ndc_package10 = seg_1 || seg_2 || seg_3;


-- drop all single segment columns that were created for conversion

ALTER TABLE ndc_package
DROP COLUMN seg_1;

ALTER TABLE ndc_package
DROP COLUMN seg_2;

ALTER TABLE ndc_package
DROP COLUMN seg_3;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Merge the ICD9 included & excluded tables
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE icd9 (
	
	code VARCHAR(5), 
	description VARCHAR(222),
	included BOOLEAN
);

ALTER TABLE icd9_included
ADD COLUMN included BOOL;

ALTER TABLE icd9_excluded
ADD COLUMN included BOOL;

UPDATE icd9_included
SET included = TRUE;

UPDATE icd9_excluded
SET included = FALSE;

INSERT INTO icd9
SELECT * FROM icd9_included;

INSERT INTO icd9
SELECT * FROM icd9_excluded;

DROP TABLE icd9_included;
DROP TABLE icd9_excluded;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Run cleanup of dead tuples & maximize efficiency
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------

VACUUM FULL ANALYZE;