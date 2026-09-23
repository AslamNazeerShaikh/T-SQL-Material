-- 14 — CASE expression + pivots. Self-contained, F5 clean.
IF OBJECT_ID('tempdb..#Emp14') IS NOT NULL DROP TABLE #Emp14;
CREATE TABLE #Emp14 (Id INT, Name VARCHAR(20), Salary INT NULL, DeptId INT);
INSERT INTO #Emp14 VALUES (1, 'Asha', 120000, 10), (2, 'Dev', 80000, 10),
(3, 'Ravi', 45000, 20), (4, 'Kiran', NULL, 20);

-- Bands (NULL lands on ELSE)
SELECT
    Name,
    Salary,
    CASE
        WHEN Salary >= 100000 THEN 'High'
        WHEN Salary >= 60000 THEN 'Med'
        ELSE 'Low'
    END AS Band
FROM #Emp14;

-- Simple form
SELECT
    Name,
    CASE DeptId WHEN 10 THEN 'IT' WHEN 20 THEN 'HR' ELSE 'Other' END AS Dept
FROM #Emp14;

-- Blanks-last sort
SELECT * FROM #Emp14
ORDER BY CASE WHEN Salary IS NULL THEN 1 ELSE 0 END, Salary DESC;

-- Pivot via SUM(CASE)
SELECT
    DeptId,
    SUM(CASE WHEN Salary >= 100000 THEN 1 ELSE 0 END) AS HighCnt,
    COUNT(*) AS Total
FROM #Emp14 GROUP BY DeptId;

-- PIVOT operator (fixed list)
SELECT
    [10] AS IT,
    [20] AS HR
FROM
    (SELECT
        DeptId,
        Salary
    FROM #Emp14 WHERE Salary IS NOT NULL) s
PIVOT (AVG(Salary) FOR DeptId IN ([10], [20])) p;

-- UNPIVOT: columns back to rows (PIVOT mirror)
SELECT
    Dept,
    Yr,
    Amt
FROM
    (
        SELECT
            'IT' AS Dept,
            100 AS Y2025,
            120 AS Y2026
    ) s
UNPIVOT (Amt FOR Yr IN (Y2025, Y2026)) u;

DROP TABLE #Emp14;
