-- 25 — Dynamic SQL + injection. Self-contained, F5 clean.
-- (#temp dies across EXEC scope, so dynamic demos print text; live runs use real tables.)
IF OBJECT_ID('tempdb..#Emp25') IS NOT NULL DROP TABLE #Emp25;
CREATE TABLE #Emp25 (Id INT, Name VARCHAR(30), Salary INT);
INSERT INTO #Emp25 VALUES (1,'Asha',90000),(2,'Dev',80000);

-- SAFE shape: text once, values as typed params (print-then-run habit)
DECLARE @Sql NVARCHAR(MAX) = N'SELECT * FROM dbo.Emp WHERE Salary >= @p;';
PRINT @Sql;
-- Live on real table: EXEC sp_executesql @Sql, N'@p INT', @p = 80000;

-- QUOTENAME shields object names (poison input becomes one dead name)
DECLARE @Tbl SYSNAME = 'Emp]; DROP TABLE Users;--';
SELECT QUOTENAME(@Tbl) AS SafeName;

-- HOLE anatomy, printed not run: pasted input turns code
DECLARE @u VARCHAR(50) = ''' OR ''1''=''1';
PRINT 'SELECT * FROM Users WHERE Name = ''' + @u + ''';';
-- NEVER: EXEC ('SELECT * FROM Users WHERE Name = ''' + @u + '''');

-- Allow-list + QUOTENAME for user-picked sort (safe dynamic sort)
DECLARE @Sort SYSNAME = 'Salary';
IF @Sort IN ('Id','Name','Salary')
  PRINT 'SELECT * FROM dbo.Emp ORDER BY ' + QUOTENAME(@Sort) + ';';

-- Dynamic PIVOT list: build text, validate vs sys.columns live, print-then-run
DECLARE @Cols25 NVARCHAR(MAX) = '[10],[20]';
PRINT 'SELECT * FROM (SELECT DeptId, Salary FROM dbo.Emp) s PIVOT (AVG(Salary) FOR DeptId IN ('
  + @Cols25 + ')) p;';

DROP TABLE #Emp25;
