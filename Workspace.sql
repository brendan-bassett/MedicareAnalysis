SELECT COUNT(DISTINCT i.icd9)
FROM ma_beneficiarysummary b 
    INNER JOIN ma_carrierclaims c 
        ON b.bs_id = c.bs_id
    INNER JOIN ma_cc_icd9_dgns d
        ON c.clm_id = d.clm_id
    INNER JOIN ma_icd i
        ON d.icd9_id = i.icd_id
WHERE b.sp_diabetes = True;
