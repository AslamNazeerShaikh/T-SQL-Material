-- 04 — Constraints. Self-contained.
IF OBJECT_ID('dbo.Departments_04', 'U') IS NOT NULL DROP TABLE dbo.Departments_04;
IF OBJECT_ID('dbo.Employees_04', 'U') IS NOT NULL DROP TABLE dbo.Employees_04;

CREATE TABLE dbo.Departments_04 (Id INT PRIMARY KEY, DeptName VARCHAR(50));
CREATE TABLE dbo.Employees_04
(
    EmployeeId INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(200) UNIQUE,
    Age INT CHECK (Age >= 18),
    DepartmentId INT FOREIGN KEY REFERENCES dbo.Departments_04(Id),
    CreatedDate DATETIME2 DEFAULT SYSUTCDATETIME()
);

INSERT INTO dbo.Departments_04 VALUES (10, 'IT');
INSERT INTO dbo.Employees_04 (EmployeeId, Name, Email, Age, DepartmentId)
VALUES (1, 'John', 'j@x.com', 30, 10);

-- DEFAULT fires (CreatedDate auto-filled)
SELECT EmployeeId, Name, CreatedDate FROM dbo.Employees_04;

-- CHECK violation (uncomment to see error):
-- INSERT INTO dbo.Employees_04 (EmployeeId, Name, Age) VALUES (2, 'Kid', 15);

-- NOT NULL violation (uncomment to see error):
-- INSERT INTO dbo.Employees_04 (EmployeeId) VALUES (3);

DROP TABLE dbo.Employees_04;
DROP TABLE dbo.Departments_04;
