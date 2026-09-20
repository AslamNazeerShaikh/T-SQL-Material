-- 05 — Query vs Subquery. Self-contained.
IF OBJECT_ID('tempdb..#Emp05') IS NOT NULL DROP TABLE #Emp05;
IF OBJECT_ID('tempdb..#Dept05') IS NOT NULL DROP TABLE #Dept05;

CREATE TABLE #Dept05 (Id INT PRIMARY KEY, Location VARCHAR(50));
CREATE TABLE #Emp05 (Id INT PRIMARY KEY, Name VARCHAR(50), Salary INT, DepartmentId INT);

INSERT INTO #Dept05 VALUES (10, 'Pune'), (20, 'Mumbai');
INSERT INTO #Emp05 VALUES (1, 'John', 80000, 10), (2, 'Sara', 90000, 10), (3, 'Mike', 45000, 20);

-- Scalar: above company average
SELECT * FROM #Emp05 WHERE Salary > (SELECT AVG(Salary * 1.0) FROM #Emp05);

-- Multi-row: employees in Pune
SELECT * FROM #Emp05
WHERE DepartmentId IN (SELECT Id FROM #Dept05 WHERE Location = 'Pune');

-- Correlated: above own-department average
SELECT e1.*
FROM #Emp05 e1
WHERE Salary > (SELECT AVG(e2.Salary * 1.0) FROM #Emp05 e2
                WHERE e2.DepartmentId = e1.DepartmentId);

DROP TABLE #Emp05; DROP TABLE #Dept05;
