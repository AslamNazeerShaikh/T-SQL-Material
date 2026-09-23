-- 19 — Stored procedures. Shapes run in YOUR test DB (procs can't see #temp
-- created outside cleanly across batches, so demo flow is: read shape, then run).
-- Paste each block alone in SSMS on a scratch DB to run live.

-- Demo table (run first, same batch as calls below is fine for ad-hoc procs)
IF OBJECT_ID('dbo.Emp19', 'U') IS NOT NULL DROP TABLE dbo.Emp19;
CREATE TABLE dbo.Emp19 (
    Id INT PRIMARY KEY, Name VARCHAR(50), Salary INT, DeptId INT
);
INSERT INTO dbo.Emp19 VALUES (1, 'Asha', 90000, 10), (2, 'Dev', 80000, 10);
GO

-- Read proc with default param
IF
    OBJECT_ID('dbo.usp_GetStaff19', 'P') IS NOT NULL
    DROP PROC dbo.usp_GetStaff19;
GO
CREATE PROC dbo.usp_GetStaff19 @DeptId INT = NULL AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        Id,
        Name,
        Salary
    FROM dbo.Emp19
    WHERE @DeptId IS NULL OR DeptId = @DeptId;
END;
GO
EXEC dbo.usp_GetStaff19;
EXEC dbo.usp_GetStaff19 @DeptId = 10;
GO

-- Write proc: OUTPUT + TRY-CATCH deal
IF OBJECT_ID('dbo.usp_Hire19', 'P') IS NOT NULL DROP PROC dbo.usp_Hire19;
GO
CREATE PROC dbo.usp_Hire19
    @Name VARCHAR(50), @Salary INT, @NewId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        SELECT @NewId = ISNULL(MAX(Id), 0) + 1 FROM dbo.Emp19;
        INSERT INTO dbo.Emp19 (Id, Name, Salary) VALUES (
            @NewId, @Name, @Salary
        );
        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO
DECLARE @nid INT, @rc INT;
EXEC @rc = dbo.usp_Hire19 @Name = 'Ravi', @Salary = 75000, @NewId = @nid OUTPUT;
SELECT
    @rc AS Status,
    @nid AS NewId;
SELECT * FROM dbo.Emp19;
GO

-- Cursor: last-resort serial walk (FAST_FORWARD), then cleanup
DECLARE @n VARCHAR(50);
DECLARE c CURSOR FAST_FORWARD FOR SELECT Name FROM dbo.Emp19;
OPEN c; FETCH NEXT FROM c INTO @n;
WHILE @@FETCH_STATUS = 0 BEGIN PRINT @n; FETCH NEXT FROM c INTO @n; END;
CLOSE c; DEALLOCATE c;
GO

DROP PROC dbo.usp_GetStaff19; DROP PROC dbo.usp_Hire19; DROP TABLE dbo.Emp19;
