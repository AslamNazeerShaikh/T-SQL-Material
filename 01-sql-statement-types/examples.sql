-- 01 — Statement types + DELETE vs TRUNCATE vs DROP
-- Run top-to-bottom in SSMS / ADS on SQL Server 2019+. Self-contained.

IF OBJECT_ID('dbo.Employees_01', 'U') IS NOT NULL DROP TABLE dbo.Employees_01;
CREATE TABLE dbo.Employees_01 (Id INT, Name VARCHAR(100));
GO

-- DML
INSERT INTO dbo.Employees_01 (Id, Name) VALUES (1, 'John'), (10, 'Sara');
UPDATE dbo.Employees_01 SET Name = 'Jon' WHERE Id = 1;
SELECT * FROM dbo.Employees_01;

-- DELETE (DML, WHERE allowed, fires triggers, keeps structure)
DELETE FROM dbo.Employees_01 WHERE Id = 10;
SELECT * FROM dbo.Employees_01;

-- DDL: ALTER + TRUNCATE (rollback-able inside explicit transaction)
ALTER TABLE dbo.Employees_01 ADD Salary DECIMAL(18,2);
BEGIN TRANSACTION;
    TRUNCATE TABLE dbo.Employees_01;
ROLLBACK;
SELECT * FROM dbo.Employees_01; -- rows still here: TRUNCATE was rolled back

-- DCL examples (commented: replace principal as needed)
-- GRANT SELECT ON dbo.Employees_01 TO AppReader;
-- DENY DELETE ON dbo.Employees_01 TO AppReader;
-- REVOKE SELECT ON dbo.Employees_01 TO AppReader;

-- TCL savepoint demo
BEGIN TRANSACTION;
    INSERT INTO dbo.Employees_01 (Id, Name) VALUES (99, 'Temp');
    SAVE TRANSACTION BeforeDelete;
    DELETE FROM dbo.Employees_01 WHERE Id = 99;
    ROLLBACK TRANSACTION BeforeDelete; -- undo only the delete
COMMIT;
SELECT * FROM dbo.Employees_01;

-- Cleanup
DROP TABLE dbo.Employees_01;
