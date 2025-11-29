# Medicare Analysis

##Process & File Structure

###STEP 0 - Create Tables

Initialize tables in Azure Postgresql database.

###STEP 1 - Extract, Transfer, Load Data

This step takes place entirely within Azure Cloud services, and does not have its own file in the Azure_Postgresql folder.

Several collections of CSV files are extracted from multiple sources listed in detail under “Sources” section of this document. They are uploaded to Azure Data Lake storage for efficient cloud access. Azure Data Factory then transfers and parses the data into appropriate data types, then loads them into the existing tables in Azure Postgresql.

###STEP 2 - Convert DeSynPUF

Many of the data types are converted in the synthetic Medicare DeSynPUF dataset for efficiency. Converting the unique desynpuf_id from 16-character to bigint reduces it from 16 bytes to 8. This id is used throughout the dataset so reducing its file size also reduces the storage requirements greatly. Boolean values that are originally represented as characters or integers are converted to booleans.

###STEP 3 - Merge ICD, NDC, HCPCS

The ICD, NDC, and HCPCS source datasets are merged together respectively. The ICD included and excluded tables are merged together. The National Drug Code sources have multiple standards between tables, so their codes are converted to NDC10, then the NDC11 standard that is currently used. The descriptions are parsed and separated into separate short and long formats. The HCPCS codes are partially public and partially proprietary to the American Medical Association, so their descriptions are obtained from two different sources. Those are also standardized and merged.

###STEP 4 - Restructure DeSynPUF (part 1)

Overall the DeSynPUF dataset is restructured from the original "flat" style to a more complex, relational database style. A new table of Line Processing Indicator Code definitions is created. The beneficiary summary tables are merged and a new id is created to relate individual claims to their corresponding patient descriptions in the beneficiary summary. New tables are created to collect the ICD, NDC, and HCPCS codes that are referred to in the DeSynPUF dataset. All other codes and descriptions can then be discarded to further improve efficiency. The desynpuf_id is then converted from bigint to int.

###STEP 5 - Truncate Numerics

Nearly all numeric columns are cast to integers. Since there is no cent-precision data in the DeSynPUF dataset, it is not necessary to use numeric data types for pricing and payment information. The process of converting from numeric to integer is extremely resource-heavy, so this step of the process is handled in a separate file from the restructuring steps.

###STEP 6 - Restructure DeSynPUF (part 2)

More restructuring of the DeSynPUF dataset is completed. The two-segment claims in inpatient and outpatient claims are merged together. The single claim line items in carrier claims are separated out, reducing the number of columns greatly. Then the NDC, ICD, and HCPCS codes are separated out into new tables that relate index ids to their corresponding insurance codes. This also greatly reduces number of columns in the claims tables.

###STEP 7 - Collect State & County Codes

Standardize SSA state & county codes, match with FIPS county codes and add in their latitude & longitude coordinates.


###OTHER SQL FILES

####Other Queries

Some advanced queries were used in assessing the data, but these often make the processing files dense and difficult to navigate. Many of these are saved in a separate file for future reference.

Configure Microsoft Fabric

In order to mirror the Azure Postgresql database in Power BI, some permissions have to be granted to a new role ms_fabric_user.

####Workspace

A staging area for queries when interacting with the database. This helps to run shorter sets of queries without using the terminal.


##Data Sources
	
**Medicare Claims Synthetic Public Use Files (SynPUFs)** - https://www.cms.gov/data-research/statistics-trends-and-reports/medicare-claims-synthetic-public-use-files

**CMS Relative Value Files** - https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files

**Alpha-Numeric HCPS File Content** - http://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets/Alpha-Numeric-HCPCS.html

**CURRENT National Drug Code (NDC) Directory** - https://www.fda.gov/drugs/drug-approvals-and-databases/national-drug-code-directory

**PAST National Drug Code (NDC) Data** - https://www.nber.org/research/data/national-drug-code

**ICD-9 Code Lists** - https://www.cms.gov/medicare/coordination-benefits-recovery/overview/icd-code-lists

**SSA County Codes** - https://www.cms.gov/data-research/statistics-trends-and-reports/health-plans-reports-files-data/state-county

**SSA-FIPS County Code Crosswalk** - https://www.nber.org/research/data/ssa-federal-information-processing-series-fips-state-and-county-crosswalk

**USA County Coordinates** - https://www.kaggle.com/datasets/alejopaullier/usa-counties-coordinates

**State Coordinates** - https://developers.google.com/public-data/docs/canonical/states_csv
