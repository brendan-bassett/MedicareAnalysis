-- List and count every hcpcs code listed in outpatient_claims that does not correspond to an etry in hcpcs17

-- SELECT oc.hcpcs_cd_1, COUNT(*) FROM outpatient_claims oc LEFT JOIN hcpcs17 h ON oc.hcpcs_cd_1 = h.hcpc WHERE h.hcpc IS NULL GROUP BY oc.hcpcs_cd_1;

-- SELECT h.hcpc, h.desc_long, COUNT(*) FROM hcpcs17 h LEFT JOIN cms_rvu_2010 c ON h.hcpc = c.hcpcs WHERE c.hcpcs IS NULL GROUP BY h.hcpc, h.desc_long;

-- SELECT COUNT(*) FROM hcpcs17 h LEFT JOIN cms_rvu_2010 c ON h.hcpc = c.hcpcs WHERE c.hcpcs IS NULL;

-- SELECT * FROM hcpcs17 h INNER JOIN cms_rvu_2010 c ON h.hcpc = c.hcpcs LIMIT 50;

-- SELECT c.hcpcs, c.description, COUNT(*) FROM outpatient_claims oc RIGHT JOIN cms_rvu_2010 c ON oc.hcpcs_cd_1 = c.hcpcs WHERE c.hcpcs IS NULL GROUP BY c.hcpcs, c.description;

-- SELECT c.hcpcs, c.description, COUNT(*) FROM outpatient_claims oc INNER JOIN cms_rvu_2010 c ON oc.hcpcs_cd_1 = c.hcpcs GROUP BY c.hcpcs, c.description;

-- SELECT COUNT(*) FROM outpatient_claims oc RIGHT JOIN cms_rvu_2010 c ON oc.hcpcs_cd_1 = c.hcpcs WHERE c.hcpcs IS NULL;

-- SELECT COUNT(*) FROM outpatient_claims oc INNER JOIN cms_rvu_2010 c ON oc.hcpcs_cd_1 = c.hcpcs;


-- --------------------------------------------------------------------------------------------------------------------

-- ** TODO ** Merge ndc_product and ndc_package tables

-- ALTER TABLE rx_drug_events RENAME COLUMN prod_srvc_id TO ndc11;

-- SELECT LENGTH(product_ndc), COUNT(LENGTH(product_ndc)) FROM ndc_product GROUP BY LENGTH(product_ndc);


-- --------------------------------------------------------------------------------------------------------------------

-- ** TODO ** Handle duplicate entries in cms_rvu