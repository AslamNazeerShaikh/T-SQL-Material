-- 17 — Temp tables vs table variables. Self-contained, F5 clean.
IF OBJECT_ID('tempdb..#Stage17') IS NOT NULL DROP TABLE #Stage17;
IF OBJECT_ID('tempdb..#Copy17') IS NOT NULL DROP TABLE #Copy17;

-- #temp: real indexes, session scope
CREATE TABLE #Stage17 (Id INT PRIMARY KEY, Name VARCHAR(50), Salary INT);
INSERT INTO #Stage17 VALUES (1, 'Asha', 90000),
(2, 'Dev', 80000),
(3, 'Ravi', 80000);
CREATE INDEX IX_Stage17_Sal ON #Stage17 (Salary);
SELECT * FROM #Stage17 WHERE Salary = 80000;

-- @var: inline key only, batch scope, tiny piles
DECLARE @Tiny17 TABLE (Id INT PRIMARY KEY, Name VARCHAR(50));
INSERT INTO @Tiny17 VALUES (1, 'Asha'), (2, 'Dev');
SELECT * FROM @Tiny17;

-- SELECT INTO WHERE 1=2: shape clone, zero rows
SELECT * INTO #Copy17 FROM #Stage17 WHERE 1 = 2;
SELECT COUNT(*) AS EmptyClone FROM #Copy17;

-- ##temp: shared door (create, show, drop fast)
CREATE TABLE ##Share17 (Id INT);
INSERT INTO ##Share17 VALUES (1);
SELECT * FROM ##Share17;
DROP TABLE ##Share17;

-- TempDB health (lives here: all three homes above allocate in tempdb).
-- How full is it right now, by what kind of use:
SELECT SUM(unallocated_extent_page_count) * 8 / 1024 AS FreeMB,
       SUM(version_store_reserved_page_count) * 8 / 1024 AS VersionStoreMB,
       SUM(internal_object_reserved_page_count) * 8 / 1024 AS InternalObjMB,
       SUM(user_object_reserved_page_count) * 8 / 1024 AS UserObjMB
FROM sys.dm_db_file_space_usage;
-- Ops rules: pre-size data+log (no autogrow storms), fast disk, one data file
-- per core up to 8 (allocation-page contention), DROP #temp fast.

DROP TABLE #Stage17; DROP TABLE #Copy17;
