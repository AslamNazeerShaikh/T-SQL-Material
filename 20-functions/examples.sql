-- 20 — Functions. Self-contained: creates demo objects, drops at end.
-- Run top-to-bottom on a scratch DB.
IF OBJECT_ID('dbo.fn_Bands20') IS NOT NULL DROP FUNCTION dbo.fn_Bands20;
IF OBJECT_ID('dbo.fn_Team20') IS NOT NULL DROP FUNCTION dbo.fn_Team20;
IF OBJECT_ID('dbo.fn_Tax20') IS NOT NULL DROP FUNCTION dbo.fn_Tax20;
IF OBJECT_ID('dbo.Emp20', 'U') IS NOT NULL DROP TABLE dbo.Emp20;
GO
CREATE TABLE dbo.Emp20 (Id INT, Salary INT, DeptId INT);
INSERT INTO dbo.Emp20 VALUES (1,90000,10),(2,80000,10),(3,45000,20);
GO

-- Scalar: one value back
CREATE FUNCTION dbo.fn_Tax20(@Pay INT) RETURNS DECIMAL(18,2) AS
BEGIN RETURN @Pay * 0.10; END;
GO
SELECT dbo.fn_Tax20(90000) AS Tax;                    -- 9000.00
SELECT Id, Salary, dbo.fn_Tax20(Salary) AS Tax FROM dbo.Emp20;
GO

-- Inline TVF: one SELECT + input (folds in plan)
CREATE FUNCTION dbo.fn_Team20(@D INT)
RETURNS TABLE AS RETURN (SELECT Id, Salary FROM dbo.Emp20 WHERE DeptId = @D);
GO
SELECT * FROM dbo.fn_Team20(10);
GO

-- Multi-step TVF: staged build
CREATE FUNCTION dbo.fn_Bands20()
RETURNS @Out TABLE (Band VARCHAR(10), Cnt INT) AS
BEGIN
  INSERT INTO @Out SELECT 'High', COUNT(*) FROM dbo.Emp20 WHERE Salary >= 100000;
  INSERT INTO @Out SELECT 'Rest', COUNT(*) FROM dbo.Emp20 WHERE Salary < 100000;
  RETURN;
END;
GO
SELECT * FROM dbo.fn_Bands20();
GO

DROP FUNCTION dbo.fn_Bands20; DROP FUNCTION dbo.fn_Team20;
DROP FUNCTION dbo.fn_Tax20; DROP TABLE dbo.Emp20;
