-- 26 — Query optimization basics. Self-contained, F5 clean.
-- Open with Ctrl+M (Include Actual Plan) to SEE seeks vs scans while running.
-- SET lines: SSMS has them ON already; sqlcmd defaults them OFF and filtered
-- indexes refuse to build without QUOTED_IDENTIFIER ON (Msg 1934).
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
IF OBJECT_ID('tempdb..#Ord26') IS NOT NULL DROP TABLE #Ord26;
CREATE TABLE #Ord26 (Id INT PRIMARY KEY, CustId INT, Amt INT, ODate DATE);
INSERT INTO #Ord26 VALUES (1, 1, 100, '2026-01-05'),
(2, 1, 200, '2026-02-05'),
(3, 2, 150, '2026-01-20');
CREATE NONCLUSTERED INDEX IX_Ord26_Cust ON #Ord26 (CustId) INCLUDE (Amt);

-- Seek-friendly: bare column + ranged dates + tight list
SELECT
    CustId,
    SUM(Amt) AS Total
FROM #Ord26
WHERE CustId = 1 AND ODate >= '2026-01-01' AND ODate < '2026-03-01'
GROUP BY CustId;

-- Slow twins (run with plan to compare; keep commented in timed suites):
-- SELECT * FROM #Ord26 WHERE YEAR(ODate) = 2026;   -- func fence
-- SELECT * FROM #Ord26;                            -- star drag

-- Type-match matters: int-to-int seeks (watch plan warnings on mismatches)
SELECT
    CustId,
    Amt
FROM #Ord26 WHERE CustId = 1;

-- Filtered index: small + sharp (used only when WHERE matches the filter)
CREATE NONCLUSTERED INDEX IX_Ord26_Big ON #Ord26 (CustId) WHERE Amt >= 200;
SELECT CustId FROM #Ord26 WHERE Amt >= 200 AND CustId = 1;
DROP INDEX IX_Ord26_Big ON #Ord26;
UPDATE STATISTICS #Ord26;  -- fresh stats past big loads
-- Fragment check shape (live on real tables):
-- SELECT avg_fragmentation_in_percent FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.Ord'), NULL, NULL, 'LIMITED');

-- Ops shapes (live — needs VIEW SERVER STATE / Query Store ON / server perms):
-- Top-burn queries by average CPU:
-- SELECT TOP 5 total_worker_time / NULLIF(execution_count, 0) AS AvgCPU,
--        total_logical_reads / NULLIF(execution_count, 0) AS AvgReads,
--        total_elapsed_time / NULLIF(execution_count, 0) AS AvgDuration,
--        SUBSTRING(qt.text, 1, 200) AS QueryText
-- FROM sys.dm_exec_query_stats AS qs
-- CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
-- ORDER BY AvgCPU DESC;
-- Query Store regression trend:
-- SELECT q.query_id, p.plan_id, rs.avg_duration
-- FROM sys.query_store_query AS q
-- JOIN sys.query_store_plan AS p ON q.query_id = p.query_id
-- JOIN sys.query_store_runtime_stats AS rs ON p.plan_id = rs.plan_id
-- ORDER BY rs.avg_duration DESC;
-- Extended Events slow-query trace template (Profiler is dead road):
-- CREATE EVENT SESSION TrackSlow26 ON SERVER
-- ADD EVENT sqlserver.sql_statement_completed (WHERE duration > 1000000)
-- ADD TARGET package0.event_file (SET filename = N'C:\Temp\Slow26.xel');
-- ALTER EVENT SESSION TrackSlow26 ON SERVER STATE = START;

-- Partitioning skeleton: giants split by date (prune scans, swap loads).
-- Runs on PRIMARY here; grade work maps partitions to own filegroups.
IF OBJECT_ID('dbo.OrdPart26', 'U') IS NOT NULL DROP TABLE dbo.OrdPart26;
IF EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'PS_Ord26') DROP PARTITION SCHEME PS_Ord26;
IF EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'PF_Ord26') DROP PARTITION FUNCTION PF_Ord26;
GO
CREATE PARTITION FUNCTION PF_Ord26 (DATE)
    AS RANGE RIGHT FOR VALUES ('2026-01-01', '2026-07-01');
GO
CREATE PARTITION SCHEME PS_Ord26 AS PARTITION PF_Ord26 ALL TO ([PRIMARY]);
GO
CREATE TABLE dbo.OrdPart26 (Id INT, ODate DATE, Amt INT) ON PS_Ord26 (ODate);
INSERT INTO dbo.OrdPart26 VALUES (1, '2025-12-15', 100),
(2, '2026-02-05', 200),
(3, '2026-09-01', 150);
SELECT $PARTITION.PF_Ord26(ODate) AS P, COUNT(*) AS N
FROM dbo.OrdPart26 GROUP BY $PARTITION.PF_Ord26(ODate);
GO
DROP TABLE dbo.OrdPart26;
GO
DROP PARTITION SCHEME PS_Ord26;
GO
DROP PARTITION FUNCTION PF_Ord26;
GO

DROP TABLE #Ord26;
