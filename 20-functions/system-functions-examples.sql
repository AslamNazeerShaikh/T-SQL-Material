-- 20b — System functions by category. SELECT-only, F5 clean on SQL Server 2019.
-- Notes: OPENJSON needs DB compat 130+; STRING_AGG needs compat 140+; FORMAT needs CLR.

-- 1. String
SELECT LEN('Asha ') AS L, SUBSTRING('Asha',2,2) AS Mid,
       CHARINDEX('@','a@x.com') AS At, STUFF('Asha',2,2,'XX') AS Splice,
       CONCAT_WS(',', 'a', NULL, 'b') AS Glue, REPLICATE('0', 3) AS Pad,
       PATINDEX('%[0-9]%', 'ab3') AS DigitAt, REVERSE('abc') AS Flip;
SELECT value AS Tag FROM STRING_SPLIT('x,y,z', ',');
SELECT STRING_AGG(G, ',') WITHIN GROUP (ORDER BY G) AS Csv
FROM (VALUES ('b'),('a')) v(G);

-- 2. Date and time
SELECT SYSDATETIME() AS SharpNow, SYSUTCDATETIME() AS UtcNow,
       DATEADD(MONTH, 1, '2026-01-31') AS Shift,
       DATEDIFF(DAY, '2026-01-01', '2026-02-01') AS Span,
       DATENAME(WEEKDAY, GETDATE()) AS Wd, EOMONTH(GETDATE()) AS MonthEnd,
       DATEFROMPARTS(2026, 2, 28) AS Built,
       CONVERT(VARCHAR(20), GETDATE(), 120) AS Odbc,
       CONVERT(VARCHAR(12), GETDATE(), 103) AS Uk,
       ISDATE('2026-02-30') AS Nope;

-- 3. Conversion
SELECT CAST('12' AS INT) AS Hard, TRY_CAST('12x' AS INT) AS Soft,
       TRY_CONVERT(INT, '12x') AS Soft2,
       TRY_PARSE('31/12/2026' AS DATE USING 'en-GB') AS UkDate;

-- 4. Math
SELECT ABS(-5) AS A, SIGN(-5) AS S, ROUND(3.567, 2) AS R,
       ROUND(3.567, 2, 1) AS Cut, CEILING(3.1) AS Up, FLOOR(3.9) AS Down,
       POWER(2, 10) AS P, SQRT(49) AS Sq;

-- 5. GROUPING with ROLLUP (marks total rows)
SELECT Region, SUM(Amt) AS Total, GROUPING(Region) AS IsTotal
FROM (VALUES ('E',100),('W',200)) v(Region, Amt)
GROUP BY ROLLUP (Region);

-- 6. JSON
DECLARE @J NVARCHAR(MAX) = '{"name":"Asha","tags":["x","y"]}';
SELECT ISJSON(@J) AS Ok, JSON_VALUE(@J, '$.name') AS Nm,
       JSON_QUERY(@J, '$.tags') AS Tg, JSON_MODIFY(@J, '$.name', 'Dev') AS New;
SELECT tag FROM OPENJSON(@J, '$.tags') WITH (tag VARCHAR(20) '$');

-- 7. Metadata
SELECT DB_NAME() AS Db, OBJECT_ID('dbo.Emp') AS Eid,
       TYPE_NAME(56) AS T, APP_NAME() AS App, HOST_NAME() AS Box;

-- 8. Security
SELECT SUSER_SNAME() AS Login, USER_NAME() AS DbUser,
       ORIGINAL_LOGIN() AS FirstLogin, IS_MEMBER('db_owner') AS Owner,
       HAS_PERMS_BY_NAME(DB_NAME(), 'DATABASE', 'SELECT') AS CanSelect;

-- 9. Configuration + state + stats
SELECT @@SERVERNAME AS Srv, @@SERVICENAME AS Svc,
       @@LANGUAGE AS Lang, @@DATEFIRST AS WeekStart;
SELECT @@ROWCOUNT AS Rows, @@TRANCOUNT AS Deals,
       @@CONNECTIONS AS Conns, @@CPU_BUSY AS Cpu;

-- 10. Message + misc
SELECT FORMATMESSAGE('Pay %i below %i.', 100, 200) AS Msg,
       SOUNDEX('Asha') AS Sdx, DIFFERENCE('Asha','Ashok') AS Diff,
       PARSENAME('db.sch.tbl.col', 1) AS Part1, PARSENAME('db.sch.tbl.col', 4) AS Part4,
       HASHBYTES('SHA2_256', 'x') AS H, CHOOSE(2, 'a', 'b') AS Pick, IIF(1 > 2, 'y', 'n') AS If2;
SELECT Id, Salary AS [emp.pay] FROM (VALUES (1,90000)) v(Id, Salary) FOR JSON PATH;
