-- 18 — Views. Self-contained: creates uniquely-named demo objects, drops them at end.
-- Run top-to-bottom in SSMS on a scratch DB (views can't sit on #temp tables,
-- so this script uses real demo tables it cleans up itself).
IF OBJECT_ID('dbo.vw_ITStaff18', 'V') IS NOT NULL DROP VIEW dbo.vw_ITStaff18;
IF OBJECT_ID('dbo.Emp18', 'U') IS NOT NULL DROP TABLE dbo.Emp18;
IF OBJECT_ID('dbo.Dept18', 'U') IS NOT NULL DROP TABLE dbo.Dept18;
GO
CREATE TABLE dbo.Dept18 (Id INT PRIMARY KEY, Name VARCHAR(20));
CREATE TABLE dbo.Emp18 (Id INT PRIMARY KEY, Name VARCHAR(20), Salary INT, DeptId INT);
INSERT INTO dbo.Dept18 VALUES (10,'IT'),(20,'HR');
INSERT INTO dbo.Emp18 VALUES (1,'Asha',90000,10),(2,'Dev',80000,10),(3,'Ravi',45000,20);
GO

-- View hides pay + join mess; readers query it like a table
CREATE VIEW dbo.vw_ITStaff18 AS
SELECT e.Id, e.Name, d.Name AS Dept
FROM dbo.Emp18 e JOIN dbo.Dept18 d ON d.Id = e.DeptId WHERE e.DeptId = 10;
GO
SELECT * FROM dbo.vw_ITStaff18;
GO

-- Change once (ALTER keeps rights; DROP+CREATE would wipe them)
ALTER VIEW dbo.vw_ITStaff18 AS
SELECT e.Id, e.Name, d.Name AS Dept, e.Salary
FROM dbo.Emp18 e JOIN dbo.Dept18 d ON d.Id = e.DeptId WHERE e.DeptId = 10;
GO
SELECT * FROM dbo.vw_ITStaff18;
GO

-- Rights wall shape (needs a real login/role; kept as notes):
-- CREATE ROLE ReportReader18;
-- GRANT SELECT ON dbo.vw_ITStaff18 TO ReportReader18;  -- view only, base shut
GO

DROP VIEW dbo.vw_ITStaff18;
DROP TABLE dbo.Emp18;
DROP TABLE dbo.Dept18;
