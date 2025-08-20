# Medicare De-SynPUF Analysis

## Skill Keywords

**SQL** - Database management
**PostgreSQL** - Locally run database management system
**PL/PgSQL** - Procedural programming language used for dynamic SQL

## Limitations

CPT codes are copyrighted by the American Medical Association. Detailed, comprehensive descriptions of the full CPT dataset are only available directly from the AMA. Only public sources available from the Center for Medicare Services were used in this dataset.

Specific versions for the CPT, ICD-9, and NDC codes are not specified. The Medicare Claims Synthetic Public Use Files (SynPUFs) were released in 2013, so it is assumed that some versions around that time period was used. For some sources like the National Drug Code directory, only the current 2025 versions are publicly available. Therefore some drug, diagnostic, or procedure codes may not be identifiable and must be discarded.

## Data Sources
	
**Medicare Claims Synthetic Public Use Files (SynPUFs)** - https://www.cms.gov/data-research/statistics-trends-and-reports/medicare-claims-synthetic-public-use-files
**CMS Relative Value Files** - https://www.cms.gov/medicare/payment/fee-schedules/physician/pfs-relative-value-files
**Alpha-Numeric HCPS File Content** - http://www.cms.gov/Medicare/Coding/HCPCSReleaseCodeSets/Alpha-Numeric-HCPCS.html
**National Drug Code (NDC) Directory** - https://www.fda.gov/drugs/drug-approvals-and-databases/national-drug-code-directory
**ICD-9 Code Lists** - https://www.cms.gov/medicare/coordination-benefits-recovery/overview/icd-code-lists
**SSA County Codes** - https://www.cms.gov/data-research/statistics-trends-and-reports/health-plans-reports-files-data/state-county