-- 12 — NULL handling. Self-contained, F5 clean.
IF OBJECT_ID('tempdb..#Staff12') IS NOT NULL DROP TABLE #Staff12;
CREATE TABLE #Staff12 (Id INT, Name VARCHAR(20), Bonus INT NULL);
INSERT INTO #Staff12 VALUES (1, 'Asha', 100),
(2, 'Dev', NULL),
(3, 'Ravi', 200);

-- Right tests
SELECT * FROM #Staff12 WHERE Bonus IS NULL;
SELECT * FROM #Staff12 WHERE Bonus IS NOT NULL;
SELECT * FROM #Staff12 WHERE Bonus = NULL;  -- always zero rows (trap demo)

-- Fill-ins
SELECT
    Name,
    COALESCE(Bonus, 0) AS SafeBonus
FROM #Staff12;
SELECT
    Name,
    ISNULL(Bonus, 0) AS SafeBonus
FROM #Staff12;

-- NULL poisons math/concat
SELECT
    NULL + 100 AS M,
    'Hi ' + NULL AS C;

-- NOT IN + NULL wipeout vs NOT EXISTS safe form
SELECT * FROM #Staff12 WHERE Id NOT IN (1, NULL);  -- zero rows!
SELECT s.* FROM #Staff12 s
WHERE NOT EXISTS (SELECT 1 FROM (VALUES (1)) v (x) WHERE v.x = s.Id);

DROP TABLE #Staff12;
