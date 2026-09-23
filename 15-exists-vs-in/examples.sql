-- 15 — EXISTS vs IN + anti-joins. Self-contained, F5 clean.
IF OBJECT_ID('tempdb..#Cust15') IS NOT NULL DROP TABLE #Cust15;
IF OBJECT_ID('tempdb..#Ord15') IS NOT NULL DROP TABLE #Ord15;
CREATE TABLE #Cust15 (Id INT, Name VARCHAR(20));
CREATE TABLE #Ord15 (Id INT, CustId INT NULL);
INSERT INTO #Cust15 VALUES (1, 'Asha'), (2, 'Dev'), (3, 'Ravi');
INSERT INTO #Ord15 VALUES (101, 1), (102, NULL);

-- Match tests
SELECT *
FROM #Cust15
WHERE Id IN (SELECT CustId FROM #Ord15 WHERE CustId IS NOT NULL);
SELECT c.*
FROM #Cust15 c
WHERE EXISTS (SELECT 1 FROM #Ord15 o WHERE o.CustId = c.Id);

-- Anti-joins: NOT EXISTS (safe), LEFT JOIN + IS NULL (safe), NOT IN (trap)
SELECT * FROM #Cust15 c
WHERE NOT EXISTS (SELECT 1 FROM #Ord15 o WHERE o.CustId = c.Id);
SELECT c.*
FROM #Cust15 c
LEFT JOIN #Ord15 o ON o.CustId = c.Id
WHERE o.Id IS NULL;
-- EMPTY (NULL trap)
SELECT * FROM #Cust15 WHERE Id NOT IN (SELECT CustId FROM #Ord15);

-- Still-list IN is fine
SELECT * FROM #Cust15 WHERE Id IN (1, 3);

DROP TABLE #Cust15; DROP TABLE #Ord15;
