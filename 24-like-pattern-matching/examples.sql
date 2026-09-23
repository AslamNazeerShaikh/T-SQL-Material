-- 24 — LIKE pattern matching. Self-contained, F5 clean.
IF OBJECT_ID('tempdb..#Emp24') IS NOT NULL DROP TABLE #Emp24;
CREATE TABLE #Emp24 (Id INT, Name VARCHAR(30), Mail VARCHAR(50));
INSERT INTO #Emp24 VALUES (1, 'Asha', 'asha@x.com'),
(2, 'Ashok', 'ashok@y.com'),
(3, 'Dev', 'dev@x.com'), (4, '100%Sure', 's@z.com');

SELECT * FROM #Emp24 WHERE Name LIKE 'Ash%';     -- head-pinned: seeks
SELECT * FROM #Emp24 WHERE Name LIKE '%sh%';     -- floating: scans
SELECT * FROM #Emp24 WHERE Name LIKE '___';      -- exactly 3 letters
SELECT * FROM #Emp24 WHERE Name LIKE 'Ash_k';    -- 5 letters, 4th any
SELECT * FROM #Emp24 WHERE Name LIKE '[AD]%';    -- A or D start
SELECT * FROM #Emp24 WHERE Name LIKE '[^A]%';    -- not-A start
SELECT * FROM #Emp24 WHERE Mail LIKE '%.com';    -- .com tail
SELECT * FROM #Emp24 WHERE Name LIKE '100\%%' ESCAPE '\';  -- real % mark
-- NULL-safety note: no NULLs here
SELECT * FROM #Emp24 WHERE Name NOT LIKE 'A%';

DROP TABLE #Emp24;
