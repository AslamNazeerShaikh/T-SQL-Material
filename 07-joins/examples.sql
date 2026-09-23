-- 07 — Joins. Self-contained.
IF OBJECT_ID('tempdb..#E07') IS NOT NULL DROP TABLE #E07;
IF OBJECT_ID('tempdb..#D07') IS NOT NULL DROP TABLE #D07;
CREATE TABLE #E07 (Id INT, Name VARCHAR(20), DepartmentId INT);
CREATE TABLE #D07 (Id INT, Department VARCHAR(20));
INSERT INTO #E07 VALUES (1, 'John', 10), (2, 'Sara', 20), (3, 'Mike', 30);
INSERT INTO #D07 VALUES (10, 'IT'), (20, 'HR'), (40, 'Finance');

-- INNER
SELECT
    e.Name,
    d.Department
FROM #E07 e
INNER JOIN #D07 d ON e.DepartmentId = d.Id;
-- LEFT (keeps Mike with NULL)
SELECT
    e.Name,
    d.Department
FROM #E07 e
LEFT JOIN #D07 d ON e.DepartmentId = d.Id;
-- Anti-join: departments with no employees
SELECT d.Department
FROM #D07 d
LEFT JOIN #E07 e ON e.DepartmentId = d.Id
WHERE e.Id IS NULL;
-- RIGHT
SELECT
    e.Name,
    d.Department
FROM #E07 e
RIGHT JOIN #D07 d ON e.DepartmentId = d.Id;
-- FULL OUTER
SELECT
    e.Name,
    d.Department
FROM #E07 e
FULL OUTER JOIN #D07 d ON e.DepartmentId = d.Id;
-- CROSS (3x3=9)
SELECT COUNT(*) AS CrossCount FROM #E07 CROSS JOIN #D07;

-- SELF JOIN (manager hierarchy)
IF OBJECT_ID('tempdb..#Emp07') IS NOT NULL DROP TABLE #Emp07;
CREATE TABLE #Emp07 (Id INT, Name VARCHAR(20), ManagerId INT NULL);
INSERT INTO #Emp07 VALUES (1, 'CEO', NULL), (2, 'MgrA', 1), (3, 'Emp1', 2);
SELECT
    e.Name AS Employee,
    m.Name AS Manager
FROM #Emp07 e LEFT JOIN #Emp07 m ON e.ManagerId = m.Id;

DROP TABLE #E07; DROP TABLE #D07; DROP TABLE #Emp07;
