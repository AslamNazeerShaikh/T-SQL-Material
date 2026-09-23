-- 27 — Numbers, dates, specials. Self-contained, F5 clean.
-- IDENTITY/IDENT_* demos use a real dbo table (IDENT_CURRENT needs exact names;
-- #temp internal names carry suffixes, so it returns NULL on temp tables).
-- SET lines: SSMS has them ON already; sqlcmd defaults them OFF and XML
-- methods refuse to run without QUOTED_IDENTIFIER ON (Msg 1934).
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
IF OBJECT_ID('dbo.Key27', 'U') IS NOT NULL DROP TABLE dbo.Key27;
IF OBJECT_ID('dbo.Seq27', 'SO') IS NOT NULL DROP SEQUENCE dbo.Seq27;

-- Money exact vs float guess
SELECT
    CAST(0.1 + 0.2 AS DECIMAL(10, 2)) AS Exact,
    CAST(0.1 + 0.2 AS FLOAT) AS Guess;

-- Stamps
SELECT
    GETDATE() AS OldLocal,
    SYSDATETIME() AS Sharp,
    SYSUTCDATETIME() AS Utc,
    CAST(GETDATE() AS DATE) AS JustDay,
    CAST(GETDATE() AS TIME) AS JustTime;

-- IDENTITY per-table keys; gaps are law (delete 105, next is 110, not reuse)
CREATE TABLE dbo.Key27 (Id INT IDENTITY (100, 5) PRIMARY KEY, Name VARCHAR(20));
INSERT INTO dbo.Key27 (Name) VALUES ('Asha'), ('Dev');
SELECT * FROM dbo.Key27;  -- 100, 105
DELETE FROM dbo.Key27 WHERE Id = 105;
INSERT INTO dbo.Key27 (Name) VALUES ('Ravi');
SELECT * FROM dbo.Key27;  -- 100, 110: gap, never refilled
SELECT
    IDENT_CURRENT('dbo.Key27') AS AnyScope,  -- any scope/sitting peek
    IDENT_INCR('dbo.Key27') AS Step,
    IDENT_SEED('dbo.Key27') AS Seed;
GO
-- IDENTITY_INSERT hand-feed (one table per sitting; OFF right after)
SET IDENTITY_INSERT dbo.Key27 ON;
INSERT INTO dbo.Key27 (Id, Name) VALUES (1, 'Hand');
SET IDENTITY_INSERT dbo.Key27 OFF;
SELECT * FROM dbo.Key27;
GO

-- SEQUENCE shared keys with CACHE + CYCLE
CREATE SEQUENCE dbo.Seq27 START WITH 1000 INCREMENT BY 10
MINVALUE 1000 MAXVALUE 9999 CYCLE CACHE 20;
SELECT
    NEXT VALUE FOR dbo.Seq27 AS S1,
    NEXT VALUE FOR dbo.Seq27 AS S2;
DROP SEQUENCE dbo.Seq27;

-- GUIDs + ROWVERSION clash-stamp
SELECT NEWID() AS RandomGuid;
IF OBJECT_ID('tempdb..#Rv27') IS NOT NULL DROP TABLE #Rv27;
CREATE TABLE #Rv27 (Id INT, Bal INT, Rv ROWVERSION);
INSERT INTO #Rv27 (Id, Bal) VALUES (1, 100);
SELECT Rv AS Before FROM #Rv27;
UPDATE #Rv27 SET Bal = 200 WHERE Id = 1;
SELECT Rv AS After FROM #Rv27;  -- changed: clash-check reads compare this
DROP TABLE #Rv27;

-- XML teeth + glue trick
DECLARE @X XML = '<r><i>Asha</i><i>Dev</i></r>';
SELECT
    @X.value('(/r/i)[1]', 'VARCHAR(20)') AS First,
    @X.exist('/r/i[text()="Dev"]') AS HasDev;
SELECT Dev.query('.') FROM @X.nodes('/r/i') D (Dev);
SELECT
    (SELECT Name + ',' FROM (VALUES ('Asha'), ('Dev')) v (Name) FOR XML PATH ('')) AS Glue;

-- Bitwise flag pack
SELECT
    5 & 4 AS HasPaid,
    2 & 4 AS HasShip,
    5 | 2 AS Both,
    5 ^ 1 AS Toggle,
    ~5 AS Flip;

DROP TABLE dbo.Key27;
