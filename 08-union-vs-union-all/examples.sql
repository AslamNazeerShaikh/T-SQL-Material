-- 08 — UNION vs UNION ALL. Self-contained.
IF OBJECT_ID('tempdb..#Emp08') IS NOT NULL DROP TABLE #Emp08;
IF OBJECT_ID('tempdb..#Con08') IS NOT NULL DROP TABLE #Con08;
CREATE TABLE #Emp08 (Name VARCHAR(20));
CREATE TABLE #Con08 (Name VARCHAR(20));
INSERT INTO #Emp08 VALUES ('John'),('Sara');
INSERT INTO #Con08 VALUES ('Sara'),('Mike');

-- Dedupes: John, Sara, Mike
SELECT Name FROM #Emp08 UNION SELECT Name FROM #Con08;
-- Keeps dupes: John, Sara, Sara, Mike
SELECT Name FROM #Emp08 UNION ALL SELECT Name FROM #Con08;

-- With source label + final ORDER BY
SELECT Name, 'Emp' AS Src FROM #Emp08
UNION ALL
SELECT Name, 'Con' FROM #Con08
ORDER BY Name;

DROP TABLE #Emp08; DROP TABLE #Con08;
