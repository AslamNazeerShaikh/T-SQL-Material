-- 11 — GROUP BY + aggregates. Self-contained, F5 clean.
IF OBJECT_ID('tempdb..#Sales11') IS NOT NULL DROP TABLE #Sales11;
CREATE TABLE #Sales11 (Region VARCHAR(10), Seller VARCHAR(20), Amt INT NULL);
INSERT INTO #Sales11 VALUES
('East', 'Asha', 100), ('East', 'Asha', 200), ('East', 'Dev', NULL),
('West', 'Ravi', 300), ('West', 'Ravi', 300), ('West', NULL, 150);

-- Totals per region: COUNT(*) vs COUNT(col), int-safe AVG
SELECT
    Region,
    COUNT(*) AS Rows,
    COUNT(Amt) AS Priced,
    SUM(Amt) AS Total,
    AVG(Amt * 1.0) AS AvgAmt,
    MIN(Amt) AS Lo,
    MAX(Amt) AS Hi
FROM #Sales11 GROUP BY Region;

-- Dupe keys
SELECT
    Seller,
    COUNT(*) AS Times
FROM #Sales11
GROUP BY Seller
HAVING COUNT(*) > 1;

-- SUM of zero rows is NULL, COUNT is 0
SELECT
    SUM(Amt) AS SumNone,
    COUNT(*) AS CntNone
FROM #Sales11 WHERE 1 = 2;

-- ROLLUP: per-group lines + grand total (NULL-key row)
SELECT
    Region,
    Seller,
    SUM(Amt) AS Total
FROM #Sales11 GROUP BY ROLLUP(Region, Seller);

DROP TABLE #Sales11;
