
--  There are duplicates in the icd9 dataset. Lets take a look at them.

SELECT code, COUNT(*)
FROM icd9
GROUP BY code
HAVING COUNT(*) > 1;

SELECT * FROM icd9 WHERE code = '2449';
SELECT * FROM icd9 WHERE code = '40390';
SELECT * FROM icd9 WHERE code = '30002';

--  These appear to be labeled as both 'included' and 'excluded. Remove all the duplicates, getting rid of 
--  the 'excluded' ones in these cases. The 'lncluded' ones all have lower primary keys than their 
--  'excluded' counterparts.

DELETE FROM icd9
WHERE primary_key IN
    (SELECT primary_key
    FROM 
        (SELECT primary_key,
         ROW_NUMBER() OVER( PARTITION BY code ORDER BY  primary_key ) AS row_num
        FROM icd9 ) t
        WHERE t.row_num > 1 );


SELECT * FROM icd9 WHERE code = '2449';
SELECT * FROM icd9 WHERE code = '40390';
SELECT * FROM icd9 WHERE code = '30002';
