-- 23 — Normalization shapes. Self-contained, F5 clean.
IF OBJECT_ID('tempdb..#Phone23') IS NOT NULL DROP TABLE #Phone23;
IF OBJECT_ID('tempdb..#Staff23') IS NOT NULL DROP TABLE #Staff23;
IF OBJECT_ID('tempdb..#Team23') IS NOT NULL DROP TABLE #Team23;
IF OBJECT_ID('tempdb..#City23') IS NOT NULL DROP TABLE #City23;

-- 3NF split: each fact once
CREATE TABLE #City23 (
    CityId INT PRIMARY KEY, City VARCHAR(30), Pin VARCHAR(10)
);
CREATE TABLE #Team23 (TeamId INT PRIMARY KEY, TeamName VARCHAR(30), CityId INT);
CREATE TABLE #Staff23 (StaffId INT PRIMARY KEY, Name VARCHAR(30), TeamId INT);
CREATE TABLE #Phone23 (
    StaffId INT, Phone VARCHAR(15), PRIMARY KEY (StaffId, Phone)
);

INSERT INTO #City23 VALUES (1, 'Pune', '411001'), (2, 'Mumbai', '400001');
INSERT INTO #Team23 VALUES (10, 'IT', 1), (20, 'HR', 2);
INSERT INTO #Staff23 VALUES (1, 'Asha', 10), (2, 'Dev', 10), (3, 'Ravi', 20);
INSERT INTO #Phone23 VALUES (1, '98111'), (1, '98222'), (2, '98333');

-- Edit-once payoff: one city row shifts, all reads follow
UPDATE #City23 SET City = 'Pune City' WHERE CityId = 1;

-- Rebuild the flat view with joins
SELECT
    s.Name,
    t.TeamName,
    c.City,
    c.Pin,
    p.Phone
FROM #Staff23 s
JOIN #Team23 t ON t.TeamId = s.TeamId
JOIN #City23 c ON c.CityId = t.CityId
LEFT JOIN #Phone23 p ON p.StaffId = s.StaffId;

DROP TABLE #Phone23;
DROP TABLE #Staff23;
DROP TABLE #Team23;
DROP TABLE #City23;
