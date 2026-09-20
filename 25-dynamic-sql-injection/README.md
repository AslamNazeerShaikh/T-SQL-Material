# 25 — Dynamic SQL + SQL Injection (Build Safe, Block Holes)

**Goal:** Build shifting SQL with sp_executesql + params, and shut the injection door full-stack.

## Definition (say this in the interview)

**What it is:** Dynamic SQL builds query text at run time for shifting shapes —
picked columns, dynamic pivot lists, admin scripts. Safe form:
`sp_executesql` with typed params (plan reuse + injection-proof values).
`QUOTENAME` shields object names. Pasted-text `EXEC(string)` with raw input is
the hole: input turns into code.

**Why it was introduced:** Still SQL can't take table names or column lists as
variables. Reports with user-picked sorts/filters/months need text-built
queries — dynamic SQL fills that gap by law, safely or not per shape.

**What problem it resolves:** Shift-without-redeploy. Safe dynamic keeps one
code path for many shapes with kept plans; pasted-text "flex" hands attackers
the keys (`' OR '1'='1` logs in as all users).

**Interview-ready answer:** *"Still SQL can't take table names as variables,
so shifting shapes need built text. Safe shape is sp-executesql with typed
params — values stay values, plans get reused. QUOTENAME shields object names.
Never paste raw input into EXEC strings — that hole lets OR-one-equals-one
turn login checks true. Full-stack I stack params, least rights, and checks."*

## 1. Sample table

```sql
CREATE TABLE #Emp (Id INT, Name VARCHAR(30), Salary INT);
INSERT INTO #Emp VALUES (1,'Asha',90000),(2,'Dev',80000);
```

## 2. Examples

```sql
-- SAFE: values ride as typed params (plan reused, input = data only)
DECLARE @Sql NVARCHAR(MAX), @MinPay INT = 80000;
SET @Sql = N'SELECT * FROM #Emp WHERE Salary >= @p;';
-- EXEC sp_executesql @Sql, N'@p INT', @p = @MinPay;  -- #temp dies across EXEC scope; demo with real tables in test DB

-- SAFE: shifting object names via QUOTENAME (brackets poisoned input)
DECLARE @Tbl SYSNAME = 'Emp';
SELECT QUOTENAME(@Tbl);  -- [Emp]; evil input 'x]; DROP...' becomes [x]]; DROP...] = one dead name

-- HOLE (never ship): pasted login check
-- DECLARE @u VARCHAR(50) = ''' OR ''1''=''1';
-- EXEC ('SELECT * FROM Users WHERE Name = ''' + @u + '''');  -- true for ALL rows = breach

-- Dynamic pivot list (ties to 14): build IN-list, then run param-safe
-- DECLARE @Cols NVARCHAR(MAX) = '[10],[20]';
-- SET @Sql = N'SELECT * FROM (SELECT DeptId, Salary FROM Emp) s PIVOT (AVG(Salary) FOR DeptId IN (' + @Cols + N')) p;';
-- Validate @Cols against sys.columns first, then EXEC sp_executesql @Sql;
```

## 3. Query breakdown (hole anatomy)

Pasted login: text becomes `... WHERE Name = '' OR '1'='1'` — OR-true swallows
the check, all rows back, app logs attacker in. Param form sends text once
(`@p` slot) + value apart — value can never turn code.

## 4. Edge cases

- `#temp` dies across EXEC/sp_executesql scope walls — stage in real or ##temp for dynamic reads.
- QUOTENAME shields names, never values — values ride params, names ride QUOTENAME.
- Dynamic-in-dynamic needs doubled quotes (`''''`) — count ticks or rot; print text while testing.
- Plan reuse needs still text — shifting text per call re-plans; param all shifting values.
- `EXEC(@s)` without sp_ loses output params + typed safety — default to sp_executesql.
- Least rights caps blast (see `01` DCL): dynamic runner with only EXEC + read rights can't DROP.

## 5. Interview scenario questions

1. "User picks sort column — safe shape?" → Allow-list column → QUOTENAME → sp_executesql.
2. "Login pasted-text breach — how?" → OR-1=1 turns check true. Cure: params alltown.
3. "Dynamic pivot months — safe?" → Build list from sys.columns (never raw input), run sp_executesql.
4. "Why sp_executesql over EXEC?" → Typed params, outputs, plan reuse, injection-proof values.
5. ".NET side stack?" → Param commands (Dapper/EF), never string-built SQL; least-rights login.

## Cheat recap

```text
Shift shapes → built text | sp_executesql + typed params = values stay values
QUOTENAME names | never paste input | #temp dies across scope | least rights caps blast
```
