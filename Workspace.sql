


--  Add short descriptions

ALTER TABLE ma_hcpcs RENAME COLUMN description TO desc_long;
ALTER TABLE ma_icd ADD COLUMN desc_short VARCHAR;

UPDATE ma_icd
SET desc_short = desc_long
WHERE length(desc_long) <= 29;

UPDATE ma_icd
SET desc_short = SUBSTRING(desc_long, 1, 29) || '...'
WHERE length(desc_long) > 29;

UPDATE ma_icd
SET desc_short = icd9 || ' - unidentified',
    desc_long = icd9 || ' - unidentified'
WHERE matched = False;
