
/*
-----------------------------------------------------------------------------------------------------------------------
  Configure a new user for MS Fabric to access the Azure postgresql server

  https://learn.microsoft.com/en-us/fabric/database/mirrored-database/azure-database-postgresql-tutorial
  
-----------------------------------------------------------------------------------------------------------------------
*/

-- create a new user to connect from Fabric
CREATE ROLE ms_fabric_user CREATEDB CREATEROLE LOGIN REPLICATION PASSWORD 'vQnp9zYQxkiZWB';

-- grant role for replication management to the new user
GRANT azure_cdc_admin TO ms_fabric_user;

-- grant create permission on the database to mirror to the new user
GRANT CREATE ON DATABASE "DeSynPUF_DB" TO ms_fabric_user;

/*
-----------------------------------------------------------------------------------------------------------------------
  Further permission granting for ms_fabric_user as recommended by Fabic/Postgresql configuration tutorial

  https://stackoverflow.com/questions/10352695/grant-all-on-a-specific-schema-in-the-db-to-a-group-role-in-postgresql
  https://www.postgresql.org/docs/current/sql-alterdefaultprivileges.html#SQL-ALTERDEFAULTPRIVILEGES-NOTES

-----------------------------------------------------------------------------------------------------------------------
*/

-- grant new Fabric mirroring user all priviledges for existing tables
GRANT ALL ON SCHEMA public TO ms_fabric_user;
GRANT ALL ON ALL TABLES IN SCHEMA public TO ms_fabric_user;
GRANT ALL PRIVILEGES ON DATABASE "DeSynPUF_DB" TO ms_fabric_user;

-- grant new Fabric mirroring user priviledges on existing sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO ms_fabric_user;

-- grant SELECT privilege to everyone for all tables (and views) you subsequently create in schema public, 
--      and allow role ms_fabric_user to INSERT into them too
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT ON TABLES TO ms_fabric_user;


-- change the owner of all tables to the new user

GRANT ms_fabric_user TO "BBassett";

ALTER TABLE beneficiary_summary_2008 OWNER TO ms_fabric_user;
ALTER TABLE beneficiary_summary_2009 OWNER TO ms_fabric_user;
ALTER TABLE beneficiary_summary_2010 OWNER TO ms_fabric_user;
ALTER TABLE carrier_claims OWNER TO ms_fabric_user;
ALTER TABLE hcpcs17 OWNER TO ms_fabric_user;
ALTER TABLE icd9 OWNER TO ms_fabric_user;
ALTER TABLE inpatient_claims OWNER TO ms_fabric_user;
ALTER TABLE ndc2025_package OWNER TO ms_fabric_user;
ALTER TABLE ndc2025_product OWNER TO ms_fabric_user;
ALTER TABLE outpatient_claims OWNER TO ms_fabric_user;
ALTER TABLE rx_drug_events OWNER TO ms_fabric_user;

REVOKE ms_fabric_user FROM "BBassett";