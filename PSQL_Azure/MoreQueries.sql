
--      List and count every hcpcs code listed in outpatient_claims that does not correspond to an etry in the hcpcs17 table

SELECT oc.hcpcs_cd_1, COUNT(*) FROM outpatient_claims oc LEFT JOIN hcpcs17 h ON oc.hcpcs_cd_1 = h.hcpc WHERE h.hcpc IS NULL GROUP BY oc.hcpcs_cd_1;

--      That's a lot of entries that do not occur in hcpcs 17

--      Show all the hcpcs codes from hcpcs17 table that DO NOT appear in the cms_rvu table

SELECT h.hcpc, h.desc_long FROM hcpcs17 h LEFT JOIN cms_rvu_2010 c ON h.hcpc = c.hcpcs WHERE c.hcpcs IS NULL GROUP BY h.hcpc, h.desc_long;

--      Count how many entries in the hcpcs17 table DO NOT appear in the cms_rvu

SELECT COUNT(*) FROM hcpcs17 h LEFT JOIN cms_rvu_2010 c ON h.hcpc = c.hcpcs WHERE c.hcpcs IS NULL;

--      RESULT: 3767

--      Show all the hcpcs codes from hcpcs17 table that do appear in the cms_rvu table

SELECT h.hcpc, h.desc_long FROM hcpcs17 h INNER JOIN cms_rvu_2010 c ON h.hcpc = c.hcpcs GROUP BY h.hcpc, h.desc_long;

--      Count how many entries in the hcpcs17 table do appear in the cms_rvu

SELECT COUNT(*) FROM hcpcs17 h INNER JOIN cms_rvu_2010 c ON h.hcpc = c.hcpcs;

--      RESULT: 2775

--      There is a lot of overlap between the hcpcs17 list of hcpcs codes, but it doesnt cover all the codes present 
--      in the Medicare DeSynPUF dataset.

--      Show and count each hcpcs code from outpatient claims that does not appear in cms_rvu

SELECT c.hcpcs, c.description, COUNT(*) FROM outpatient_claims oc RIGHT JOIN cms_rvu_2010 c ON oc.hcpcs_cd_1 = c.hcpcs WHERE c.hcpcs IS NULL GROUP BY c.hcpcs, c.description;

--      RESULT: -- no rows --

--      The cms_rvu table has hcpcs descriptions for every code in the Medicare DeSynPUF dataset

--      Just to double-check. Let's count the number of hcpcs codes in the outpatient claims that do not appear in the cms_rvu

SELECT COUNT(*) FROM outpatient_claims oc RIGHT JOIN cms_rvu_2010 c ON oc.hcpcs_cd_1 = c.hcpcs WHERE c.hcpcs IS NULL;

--      RESULT: 0


--      --------------------------------------------

--      Now the cms_rvu dataset may be comprehensive, but the descriptions are short and not as easy to understand
--      as those in the hcpcs17 data. We should combine the two datasets.


--      Populate a new hcpcs table with the descriptions from hcpcs17

CREATE TABLE hcpcs_desc (
    hcpcs VARCHAR(5) UNIQUE,
    desc_short VARCHAR,
    desc_long VARCHAR
);

INSERT INTO hcpcs_desc (hcpcs, desc_short, desc_long)
SELECT h.hcpc, h.desc_short, h.desc_long
FROM hcpcs17 h;


--      Add any additional hcpcs codes and descriptions from cms_rvu that are not already in the description list

INSERT INTO hcpcs_desc (hcpcs, desc_short, desc_long)
SELECT cr.hcpcs, cr.description, cr.description
FROM cms_rvu_2010 cr
ON CONFLICT (hcpcs)
DO NOTHING;

--      Get rid of the old hcpcs17 table. It doesnt have any other information we will need.

DROP TABLE hcpcs17;


-- --------------------------------------------------------------------------------------------------------------------
