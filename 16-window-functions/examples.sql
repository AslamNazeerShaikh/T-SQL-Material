-- 16 — Window functions. Self-contained, F5 clean.
IF OBJECT_ID('tempdb..#Emp16') IS NOT NULL DROP TABLE #Emp16;
CREATE TABLE #Emp16 (Id INT, Name VARCHAR(20), DeptId INT, Salary INT);
INSERT INTO #Emp16 VALUES (1,'Asha',10,90000),(2,'Dev',10,90000),(3,'Ravi',10,80000),
 (4,'Kiran',20,70000),(5,'Meena',20,70000),(6,'Tom',20,60000);

-- Rank trio per team
SELECT Name, DeptId, Salary,
  ROW_NUMBER() OVER (PARTITION BY DeptId ORDER BY Salary DESC) AS rn,
  RANK()       OVER (PARTITION BY DeptId ORDER BY Salary DESC) AS rnk,
  DENSE_RANK() OVER (PARTITION BY DeptId ORDER BY Salary DESC) AS drnk
FROM #Emp16;

-- Top 1 per team
WITH R AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY DeptId ORDER BY Salary DESC) AS rn
           FROM #Emp16)
SELECT Id, Name, DeptId, Salary FROM R WHERE rn = 1;

-- 2nd top distinct pay
WITH D AS (SELECT Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS dr FROM #Emp16)
SELECT DISTINCT Salary AS SecondTop FROM D WHERE dr = 2;

-- Run total per team
SELECT Name, Salary, SUM(Salary) OVER (PARTITION BY DeptId ORDER BY Salary) AS RunTotal
FROM #Emp16;

-- Grand total pasted per row (no ORDER BY = no running)
SELECT Name, Salary, SUM(Salary) OVER () AS GrandTotal FROM #Emp16;

-- Peek next/prev, gap math with fallback
SELECT Name, Salary,
  LEAD(Salary) OVER (ORDER BY Salary DESC) AS NextPay,
  Salary - LAG(Salary, 1, Salary) OVER (ORDER BY Salary DESC) AS GapVsPrev
FROM #Emp16;

-- De-dupe dry run: rows past rn=1 would be deleted
WITH D AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY Name, Salary ORDER BY Id) AS rn
           FROM #Emp16)
SELECT * FROM D WHERE rn > 1;  -- zero rows here; DELETE FROM D WHERE rn > 1 to kill dupes

-- NTILE quartiles per team (ties may split clubs)
SELECT Name, Salary, NTILE(4) OVER (PARTITION BY DeptId ORDER BY Salary DESC) AS Quart
FROM #Emp16;

DROP TABLE #Emp16;
