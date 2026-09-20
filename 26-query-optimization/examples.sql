-- 26 — Query optimization basics. Self-contained, F5 clean.
-- Open with Ctrl+M (Include Actual Plan) to SEE seeks vs scans while running.
IF OBJECT_ID('tempdb..#Ord26') IS NOT NULL DROP TABLE #Ord26;
CREATE TABLE #Ord26 (Id INT PRIMARY KEY, CustId INT, Amt INT, ODate DATE);
INSERT INTO #Ord26 VALUES (1,1,100,'2026-01-05'),(2,1,200,'2026-02-05'),(3,2,150,'2026-01-20');
CREATE NONCLUSTERED INDEX IX_Ord26_Cust ON #Ord26(CustId) INCLUDE (Amt);

-- Seek-friendly: bare column + ranged dates + tight list
SELECT CustId, SUM(Amt) AS Total FROM #Ord26
WHERE CustId = 1 AND ODate >= '2026-01-01' AND ODate < '2026-03-01'
GROUP BY CustId;

-- Slow twins (run with plan to compare; keep commented in timed suites):
-- SELECT * FROM #Ord26 WHERE YEAR(ODate) = 2026;   -- func fence
-- SELECT * FROM #Ord26;                            -- star drag

-- Type-match matters: int-to-int seeks (watch plan warnings on mismatches)
SELECT CustId, Amt FROM #Ord26 WHERE CustId = 1;

DROP TABLE #Ord26;
