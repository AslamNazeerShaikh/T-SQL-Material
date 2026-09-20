-- 21b — Temporal tables. Demo objects made + dropped. Run on scratch DB.
IF OBJECT_ID('dbo.Emp21t', 'U') IS NOT NULL
BEGIN ALTER TABLE dbo.Emp21t SET (SYSTEM_VERSIONING = OFF); DROP TABLE dbo.Emp21t; END
IF OBJECT_ID('dbo.EmpHist21t', 'U') IS NOT NULL DROP TABLE dbo.EmpHist21t;
GO
CREATE TABLE dbo.Emp21t
(
  Id INT PRIMARY KEY, Salary INT,
  ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
  ValidTo   DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
  PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmpHist21t));
GO
INSERT INTO dbo.Emp21t (Id, Salary) VALUES (1, 90000),(2, 80000);
WAITFOR DELAY '00:00:01';
UPDATE dbo.Emp21t SET Salary = 95000 WHERE Id = 1;
WAITFOR DELAY '00:00:01';
DELETE FROM dbo.Emp21t WHERE Id = 2;
GO
-- Past + now, wide bounds (clock-safe)
SELECT * FROM dbo.Emp21t FOR SYSTEM_TIME ALL ORDER BY Id, ValidFrom;
SELECT * FROM dbo.Emp21t FOR SYSTEM_TIME BETWEEN '2000-01-01' AND '2100-01-01' ORDER BY Id;
-- AS OF latest start = deterministic snapshot of newest versions
DECLARE @t DATETIME2 = (SELECT MAX(ValidFrom) FROM dbo.Emp21t FOR SYSTEM_TIME ALL);
SELECT * FROM dbo.Emp21t FOR SYSTEM_TIME AS OF @t;
GO
-- TRUNCATE is barred while versioned (kept as note — would error):
-- TRUNCATE TABLE dbo.Emp21t;
ALTER TABLE dbo.Emp21t SET (SYSTEM_VERSIONING = OFF);
DROP TABLE dbo.Emp21t; DROP TABLE dbo.EmpHist21t;
