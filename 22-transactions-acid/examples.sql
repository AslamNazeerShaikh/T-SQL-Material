-- 22 — Transactions + ACID. Self-contained, F5 clean.
-- (SNAPSHOT rung needs a DB flag; shown as notes. Deadlock demo is a shape — needs two sittings.)
IF OBJECT_ID('tempdb..#Acct22') IS NOT NULL DROP TABLE #Acct22;
CREATE TABLE #Acct22 (Id INT PRIMARY KEY, Bal INT);
INSERT INTO #Acct22 VALUES (1, 1000), (2, 500);

-- Money move: both legs or neither
SET XACT_ABORT ON;
BEGIN TRANSACTION;
UPDATE #Acct22 SET Bal = Bal - 200 WHERE Id = 1;
UPDATE #Acct22 SET Bal = Bal + 200 WHERE Id = 2;
COMMIT;
SELECT * FROM #Acct22;  -- 800 / 700

-- Rung demo: default sealed reads vs NOLOCK no-wait reads
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM #Acct22;
SELECT * FROM #Acct22 WITH (NOLOCK);
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  -- back to default

-- SNAPSHOT shape (needs once-per-DB: ALTER DATABASE ... SET ALLOW_SNAPSHOT_ISOLATION ON):
-- SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
-- SELECT * FROM #Acct22;  -- past-view read, blocks neither side

-- Deadlock shape (needs TWO sittings run together — notes only):
-- Sitting A: BEGIN TRAN; UPDATE #Acct22 SET Bal=Bal WHERE Id=1; WAITFOR DELAY '00:00:05'; UPDATE #Acct22 SET Bal=Bal WHERE Id=2; COMMIT;
-- Sitting B: BEGIN TRAN; UPDATE #Acct22 SET Bal=Bal WHERE Id=2; WAITFOR DELAY '00:00:05'; UPDATE #Acct22 SET Bal=Bal WHERE Id=1; COMMIT;
-- Cure: same lock order (1 then 2), short deals, indexed keys, retry full deal on 1205.

DROP TABLE #Acct22;
