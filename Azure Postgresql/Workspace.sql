
-- List the 20 most common ICD diagnosis codes used in carrier claims for patients with diabetes.

--      We have to create a table for this data so the descriptions can be shown with the icd9 
--          codes without creating issues with the 'group by' statement.

DROP TABLE IF EXISTS cc_icd_diabetes;
CREATE TABLE cc_icd_diabetes (
    icd_count BIGINT,
    icd9 VARCHAR,
    desc_long VARCHAR
);

INSERT INTO cc_icd_diabetes (icd9, icd_count)
SELECT i.icd9, COUNT(i.icd9) as icd_count
FROM ma_beneficiarysummary b 
    INNER JOIN ma_carrierclaims c 
        ON b.bs_id = c.bs_id
    INNER JOIN ma_cc_icd9_dgns d
        ON c.clm_id = d.clm_id
    INNER JOIN ma_icd i
        ON d.icd9_id = i.icd_id
WHERE b.sp_diabetes = True
GROUP BY i.icd9
ORDER BY icd_count DESC
LIMIT 20;

UPDATE cc_icd_diabetes c
SET desc_long = i.desc_long
FROM ma_icd i
WHERE c.icd9 = i.icd9;

SELECT * FROM cc_icd_diabetes ORDER BY icd_count DESC;

DROP TABLE IF EXISTS cc_icd_diabetes;

/*
        RESULT:

icd_count   icd9    desc_long

212969	4019	Unspecified essential hypertension
180226	4011	Benign hypertension
125372	25000	Diabetes mellitus without mention of complication, type II or unspecified type, not stated as uncontrolled
116808	2724	Other and unspecified hyperlipidemia
69138	2720	Pure hypercholesterolemia
58206	42731	Atrial fibrillation
49053	2449	Unspecified acquired hypothyroidism
49009	V5869	V5869 - unidentified
48031	78079	Other malaise and fatigue
47403	2859	Anemia, unspecified
43342	4280	Congestive heart failure, unspecified
43144	7295	Pain in limb
40710	496	Chronic airway obstruction, not elsewhere classified
40038	2722	Mixed hyperlipidemia
37739	41400	Coronary atherosclerosis of unspecified type of vessel, native or graft
37148	78650	Chest pain, unspecified
34132	41401	Coronary atherosclerosis of native coronary artery
33736	7242	Lumbago
31157	V5861	V5861 - unidentified
30476	5990	Urinary tract infection, site not specified

*/