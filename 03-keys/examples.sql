-- 03 — Keys. Self-contained.
IF OBJECT_ID('dbo.Employees_03', 'U') IS NOT NULL DROP TABLE dbo.Employees_03;
IF OBJECT_ID('dbo.Departments_03', 'U') IS NOT NULL DROP TABLE dbo.Departments_03;

CREATE TABLE dbo.Departments_03 (Id INT PRIMARY KEY, DeptName VARCHAR(50));
CREATE TABLE dbo.Employees_03
(
    EmployeeId INT PRIMARY KEY,
    Email VARCHAR(200) UNIQUE,       -- alternate key
    DepartmentId INT
        FOREIGN KEY REFERENCES dbo.Departments_03(Id)
);

INSERT INTO dbo.Departments_03 VALUES (10, 'IT'), (20, 'HR');
INSERT INTO dbo.Employees_03 VALUES (1, 'a@x.com', 10), (2, 'b@x.com', 20);

-- FK violation: DepartmentId 99 does not exist
-- INSERT INTO dbo.Employees_03 VALUES (3, 'c@x.com', 99); -- errors

-- UNIQUE violation: duplicate email
-- INSERT INTO dbo.Employees_03 VALUES (3, 'a@x.com', 10); -- errors

-- Composite key example
IF OBJECT_ID('dbo.Enrollments_03', 'U') IS NOT NULL DROP TABLE dbo.Enrollments_03;
CREATE TABLE dbo.Enrollments_03
(
    StudentId INT,
    CourseId INT,
    PRIMARY KEY (StudentId, CourseId)
);
INSERT INTO dbo.Enrollments_03 VALUES (1, 101), (1, 102), (2, 101);
-- INSERT INTO dbo.Enrollments_03 VALUES (1, 101); -- duplicate pair, errors
SELECT * FROM dbo.Enrollments_03;

DROP TABLE dbo.Employees_03;
DROP TABLE dbo.Enrollments_03;
DROP TABLE dbo.Departments_03;
