-- 21 — Triggers. Self-contained: demo objects made + dropped. Run on scratch DB.
IF OBJECT_ID('dbo.trg_Emp21_Audit', 'TR') IS NOT NULL DROP TRIGGER dbo.trg_Emp21_Audit;
IF OBJECT_ID('dbo.trg_Emp21_NoCut', 'TR') IS NOT NULL DROP TRIGGER dbo.trg_Emp21_NoCut;
IF OBJECT_ID('dbo.Audit21', 'U') IS NOT NULL DROP TABLE dbo.Audit21;
IF OBJECT_ID('dbo.Emp21', 'U') IS NOT NULL DROP TABLE dbo.Emp21;
GO
CREATE TABLE dbo.Emp21 (Id INT PRIMARY KEY, Name VARCHAR(50), Salary INT);
CREATE TABLE dbo.Audit21 (Id INT IDENTITY PRIMARY KEY, Note VARCHAR(200),
  WhenAt DATETIME2 DEFAULT SYSUTCDATETIME());
INSERT INTO dbo.Emp21 VALUES (1,'Asha',90000),(2,'Dev',80000);
GO

-- AFTER audit: one run logs full sets
CREATE TRIGGER dbo.trg_Emp21_Audit ON dbo.Emp21
AFTER INSERT, UPDATE, DELETE AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO dbo.Audit21 (Note)
  SELECT CONCAT('ins:', i.Id) FROM inserted i
  UNION ALL
  SELECT CONCAT('del:', d.Id) FROM deleted d;
END;
GO
UPDATE dbo.Emp21 SET Salary = 95000 WHERE Id = 1;   -- one blast
INSERT INTO dbo.Emp21 VALUES (3,'Ravi',70000);
SELECT * FROM dbo.Audit21;                          -- 1 del + 1 ins + 1 ins
GO

-- INSTEAD OF veto: pay cuts blocked, fair writes pass
CREATE TRIGGER dbo.trg_Emp21_NoCut ON dbo.Emp21
INSTEAD OF UPDATE AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS (SELECT 1 FROM inserted i JOIN deleted d ON d.Id = i.Id
             WHERE i.Salary < d.Salary)
  BEGIN RAISERROR('Pay cuts blocked.', 16, 1); ROLLBACK; RETURN; END;
  UPDATE e SET e.Name = i.Name, e.Salary = i.Salary
  FROM dbo.Emp21 e JOIN inserted i ON i.Id = e.Id;
END;
GO
UPDATE dbo.Emp21 SET Salary = 96000 WHERE Id = 1;    -- passes
-- UPDATE dbo.Emp21 SET Salary = 10000 WHERE Id = 1; -- blocked (uncomment to test)
SELECT Id, Name, Salary FROM dbo.Emp21;
GO

DROP TRIGGER dbo.trg_Emp21_Audit; DROP TRIGGER dbo.trg_Emp21_NoCut;
DROP TABLE dbo.Audit21; DROP TABLE dbo.Emp21;
