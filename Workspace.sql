
-- ** TODO ** Handle duplicate entries in cms_rvu

--      Show each hcpcs code that has multiple entries in the cms_rvu file

SELECT hcpcs, description, COUNT(hcpcs) FROM cms_rvu_2010 GROUP BY hcpcs, description HAVING COUNT(hcpcs) > 1
