-- 10 — Clustered vs Non-clustered. Self-contained.
IF OBJECT_ID('dbo.Employees_10', 'U') IS NOT NULL DROP TABLE dbo.Employees_10;
CREATE TABLE dbo.Employees_10 (Id INT, Name VARCHAR(100), Salary INT);

CREATE CLUSTERED INDEX IX_Employees10_Id ON dbo.Employees_10 (Id);
CREATE NONCLUSTERED INDEX IX_Employees10_Name ON dbo.Employees_10 (Name);

INSERT INTO dbo.Employees_10 VALUES (1, 'John', 80000),
(2, 'Sara', 90000),
(3, 'Mike', 45000);

-- Clustered-friendly range seek
SELECT * FROM dbo.Employees_10 WHERE Id BETWEEN 1 AND 2;
-- Non-clustered seek + lookup
SELECT * FROM dbo.Employees_10 WHERE Name = 'Sara';

-- Covering index with INCLUDE (avoids key lookup for Salary)
CREATE NONCLUSTERED INDEX IX_Employees10_Name_Cover
    ON dbo.Employees_10 (Name) INCLUDE (Salary);
SELECT
    Name,
    Salary
FROM dbo.Employees_10 WHERE Name = 'Sara';
DROP INDEX IX_Employees10_Name_Cover ON dbo.Employees_10;

-- PK NONCLUSTERED + separate clustered (pattern)
IF OBJECT_ID('dbo.Orders_10', 'U') IS NOT NULL DROP TABLE dbo.Orders_10;
CREATE TABLE dbo.Orders_10
(
    OrderId INT NOT NULL CONSTRAINT PK_Orders10 PRIMARY KEY NONCLUSTERED,
    OrderDate DATE NOT NULL
);
CREATE CLUSTERED INDEX IX_Orders10_Date ON dbo.Orders_10 (OrderDate);

-- Composite: seeks on (Id) and (Id,Name); lone-Name seeks need their own index
CREATE NONCLUSTERED INDEX IX_Employees10_IdName ON dbo.Employees_10 (Id, Name);
SELECT * FROM dbo.Employees_10 WHERE Id = 1 AND Name = 'John';
DROP INDEX IX_Employees10_IdName ON dbo.Employees_10;

DROP TABLE dbo.Employees_10;
DROP TABLE dbo.Orders_10;
