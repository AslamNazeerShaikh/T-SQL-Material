-- 09 — CTE. Self-contained.
IF OBJECT_ID('tempdb..#Emp09') IS NOT NULL DROP TABLE #Emp09;
IF OBJECT_ID('tempdb..#Org09') IS NOT NULL DROP TABLE #Org09;
CREATE TABLE #Emp09 (Id INT, Name VARCHAR(50), Salary INT, DepartmentId INT);
INSERT INTO #Emp09 VALUES (1, 'John', 80000, 10),
(2, 'Sara', 120000, 10),
(3, 'Mike', 45000, 20);
CREATE TABLE #Org09 (Id INT, Name VARCHAR(20), ManagerId INT NULL);
INSERT INTO #Org09 VALUES (1, 'CEO', NULL),
(2, 'MgrA', 1),
(3, 'MgrB', 1),
(4, 'Emp1', 2),
(5, 'Emp2', 2),
(6, 'Emp3', 3);

-- Basic + chained
WITH EmployeeCTE AS (
    SELECT
        Id,
        Name,
        Salary
    FROM #Emp09 WHERE Salary > 50000
)

SELECT * FROM EmployeeCTE;

WITH HighPaid AS (SELECT * FROM #Emp09 WHERE Salary > 100000)

SELECT * FROM HighPaid WHERE DepartmentId = 10;

-- Recursive hierarchy
WITH OrgTree AS (
    SELECT
        Id,
        Name,
        ManagerId,
        0 AS Lvl
    FROM #Org09 WHERE ManagerId IS NULL
    UNION ALL
    SELECT
        o.Id,
        o.Name,
        o.ManagerId,
        t.Lvl + 1
    FROM #Org09 o JOIN OrgTree t ON o.ManagerId = t.Id
)

SELECT * FROM OrgTree ORDER BY Lvl, Id
OPTION (MAXRECURSION 100);

DROP TABLE #Emp09; DROP TABLE #Org09;
