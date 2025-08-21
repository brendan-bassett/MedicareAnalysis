

-- SELECT rde.ndc11, COUNT(*) FROM rx_drug_events rde LEFT JOIN ndc_package n ON rde.ndc11 = n.ndc_package11 WHERE n.ndc_package11 IS NULL GROUP BY rde.ndc11;
-- SELECT COUNT(*) FROM rx_drug_events rde LEFT JOIN ndc_package n ON rde.ndc11 = n.ndc_package11 WHERE n.ndc_package11 IS NULL;

--      RESULT: 5307893 results do not match between rx_drug_events and ndc_package

-- SELECT rde.ndc11, COUNT(*) FROM rx_drug_events rde INNER JOIN ndc_package n ON rde.ndc11 = n.ndc_package11 GROUP BY rde.ndc11;
-- SELECT COUNT(*) FROM rx_drug_events rde INNER JOIN ndc_package n ON rde.ndc11 = n.ndc_package11;

--      RESULT: 244528 results match between rx_drug_events and ndc_package

SELECT LENGTH(ndc11), COUNT(LENGTH(ndc11)) FROM rx_drug_events GROUP BY LENGTH(ndc11);