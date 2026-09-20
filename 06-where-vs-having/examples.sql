-- 06 — WHERE vs HAVING. Self-contained.
IF OBJECT_ID('tempdb..#Emp06') IS NOT NULL DROP TABLE #Emp06;
CREATE TABLE #Emp06 (Employee CHAR(1), Department VARCHAR(10), Salary INT);
INSERT INTO #Emp06 VALUES ('A','IT',80000),('B','IT',90000),('C','HR',40000),('D','HR',45000);

-- WHERE filters rows first
SELECT Department, AVG(Salary * 1.0) AS AvgSal
FROM #Emp06 WHERE Salary > 50000 GROUP BY Department;

-- HAVING filters groups after aggregation
SELECT Department, AVG(Salary * 1.0) AS AvgSal
FROM #Emp06 GROUP BY Department HAVING AVG(Salary * 1.0) > 50000;

-- Both together
SELECT Department, AVG(Salary * 1.0) AS AvgSal
FROM #Emp06 WHERE Salary > 50000 GROUP BY Department HAVING AVG(Salary * 1.0) > 75000;

-- HAVING without GROUP BY: empty set if predicate fails
SELECT COUNT(*) AS EmployeeCount FROM #Emp06 HAVING COUNT(*) > 100;

DROP TABLE #Emp06;
